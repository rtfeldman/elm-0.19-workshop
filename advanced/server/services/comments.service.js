"use strict";

const { ForbiddenError } = require("moleculer-web").Errors;
const DbService = require("../mixins/db.mixin");

module.exports = {
	name: "comments",
	mixins: [DbService("comments")],

	/**
	 * Default settings
	 */
	settings: {
		fields: ["_id", "author", "article", "body", "createdAt", "updatedAt"],
		populates: {
			"author": {
				action: "users.get",
				params: {
					fields: ["_id", "username", "bio", "image"]
				}
			}
		},
		entityValidator: {
			article: { type: "string" },
			body: { type: "string", min: 1 },
		}
	},

	/**
	 * Actions
	 */
	actions: {
		/**
		 * Create a comment.
		 * Auth is required!
		 * 
		 * @actions
		 * @param {String} article - Article ID
		 * @param {Object} comment - Comment entity
		 * 
		 * @returns {Object} Created comment entity
		 */
		create: {
			auth: "required",
			params: {
				article: { type: "string" },
				comment: { type: "object" }
			},
			handler(ctx) {
				let entity = ctx.params.comment;
				entity.article = ctx.params.article;
				entity.author = ctx.meta.user._id.toString();
				
				return this.validateEntity(entity)
					.then(() => {

						entity.createdAt = new Date();
						entity.updatedAt = new Date();

						return this.adapter.insert(entity)
							.then(doc => this.transformDocuments(ctx, { populate: ["author"]}, doc))
							.then(entity => this.transformResult(ctx, entity, ctx.meta.user))
							.then(json => this.entityChanged("created", json, ctx).then(() => json));
					});
			}
		},

		/**
		 * Update a comment.
		 * Auth is required!
		 * 
		 * @actions
		 * @param {String} id - Comment ID
		 * @param {Object} comment - Comment modified fields
		 * 
		 * @returns {Object} Updated comment entity
		 */
		update: {
			auth: "required",
			params: {
				id: { type: "string" },
				comment: { type: "object", props: {
					body: { type: "string", min: 1 },
				} }
			},
			handler(ctx) {
				let newData = ctx.params.comment;
				newData.updatedAt = new Date();
				
				return this.getById(ctx.params.id)
					.then(comment => {
						if (comment.author !== ctx.meta.user._id.toString())
							return this.Promise.reject(new ForbiddenError());
						
						const update = {
							"$set": newData
						};

						return this.adapter.updateById(ctx.params.id, update);
					})
					.then(doc => this.transformDocuments(ctx, { populate: ["author"]}, doc))
					.then(entity => this.transformResult(ctx, entity, ctx.meta.user))
					.then(json => this.entityChanged("updated", json, ctx).then(() => json));
			}
		},

		/**
		 * List of comments by article.
		 * 
		 * @actions
		 * @param {String} article - Article ID
		 * @param {Number} limit - Pagination limit
		 * @param {Number} offset - Pagination offset
		 * 
		 * @returns {Object} List of comments
		 */
		list: {
			cache: {
				keys: ["#token", "article", "limit", "offset"]
			},
			params: {
				article: { type: "string" },
				limit: { type: "number", optional: true, convert: true },
				offset: { type: "number", optional: true, convert: true },
			},
			handler(ctx) {
				const limit = ctx.params.limit ? Number(ctx.params.limit) : 20;
				const offset = ctx.params.offset ? Number(ctx.params.offset) : 0;

				let params = {
					limit,
					offset,
					sort: ["-createdAt"],
					populate: ["author"],
					query: {
						article: ctx.params.article
					}
				};
				let countParams;

				return this.Promise.resolve()
					.then(() => {
						countParams = Object.assign({}, params);
						// Remove pagination params
						if (countParams && countParams.limit)
							countParams.limit = null;
						if (countParams && countParams.offset)
							countParams.offset = null;						
					})				
					.then(() => this.Promise.all([
						// Get rows
						this.adapter.find(params),

						// Get count of all rows
						this.adapter.count(countParams)

					])).then(res => {
						return this.transformDocuments(ctx, params, res[0])
							.then(docs => this.transformResult(ctx, docs, ctx.meta.user))
							.then(r => {
								r.commentsCount = res[1];
								return r;
							});
					});

			}
		},

		/**
		 * Remove a comment
		 * Auth is required!
		 * 
		 * @actions
		 * @param {String} id - Comment ID
		 * 
		 * @returns {Number} Count of removed comments
		 */
		remove: {
			auth: "required",
			params: {
				id: { type: "any" }
			},
			handler(ctx) {
				return this.getById(ctx.params.id)
					.then(comment => {
						if (comment.author !== ctx.meta.user._id.toString())
							return this.Promise.reject(new ForbiddenError());

						return this.adapter.removeById(ctx.params.id)
							.then(json => this.entityChanged("updated", json, ctx).then(() => json));
					});	
			}
		}
	},

	/**
	 * Methods
	 */
	methods: {

		/**
		 * Transform the result entities to follow the RealWorld API spec
		 * 
		 * @param {Context} ctx 
		 * @param {Array} entities 
		 * @param {Object} user - Logged in user
		 */
		transformResult(ctx, entities, user) {
			if (Array.isArray(entities)) {
				return this.Promise.map(entities, item => this.transformEntity(ctx, item, user))
					.then(comments => ({ comments }));
			} else {
				return this.transformEntity(ctx, entities, user)
					.then(comment => ({ comment }));
			}
		},

		/**
		 * Transform a result entity to follow the RealWorld API spec 
		 * 
		 * @param {Context} ctx 
		 * @param {Object} entity 
		 * @param {Object} user - Logged in user
		 */
		transformEntity(ctx, entity, loggedInUser) {
			if (!entity) return this.Promise.resolve();

			return this.Promise.resolve(entity)
				.then(entity => {
					entity.id = entity._id;

					if (loggedInUser) {
						return ctx.call("follows.has", { user: loggedInUser._id.toString(), follow: entity.author._id })
							.then(res => {
								entity.author.following = res;
								return entity;
							});
					}

					entity.author.following = false;					

					return entity;
				});

		}
	},

	events: {
		"cache.clean.comments"() {
			if (this.broker.cacher)
				this.broker.cacher.clean(`${this.name}.*`);
		},
		"cache.clean.users"() {
			if (this.broker.cacher)
				this.broker.cacher.clean(`${this.name}.*`);
		},
		"cache.clean.follows"() {
			if (this.broker.cacher)
				this.broker.cacher.clean(`${this.name}.*`);
		},
		"cache.clean.articles"() {
			if (this.broker.cacher)
				this.broker.cacher.clean(`${this.name}.*`);
		}
	}
};