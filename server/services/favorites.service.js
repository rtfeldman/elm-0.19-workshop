"use strict";

const { MoleculerClientError } = require("moleculer").Errors;
const DbService = require("../mixins/db.mixin");


module.exports = {
	name: "favorites",
	mixins: [DbService("favorites")],

	/**
	 * Default settings
	 */
	settings: {

	},

	/**
	 * Actions
	 */
	actions: {

		/**
		 * Create a new favorite record
		 * 
		 * @actions
		 * 
		 * @param {String} article - Article ID
		 * @param {String} user - User ID
		 * @returns {Object} Created favorite record
		 */		
		add: {
			params: {
				article: { type: "string" },
				user: { type: "string" },
			},
			handler(ctx) {
				const { article, user } = ctx.params;
				return this.findByArticleAndUser(article, user)
					.then(item => {
						if (item)
							return this.Promise.reject(new MoleculerClientError("Articles has already favorited"));

						return this.adapter.insert({ article, user, createdAt: new Date() })
							.then(json => this.entityChanged("created", json, ctx).then(() => json));

					});
			}
		},

		/**
		 * Check the given 'article' is followed by 'user'.
		 * 
		 * @actions
		 * 
		 * @param {String} article - Article ID
		 * @param {String} user - User ID
		 * @returns {Boolean}
		 */		
		has: {
			cache: {
				keys: ["article", "user"]
			},
			params: {
				article: { type: "string" },
				user: { type: "string" },
			},
			handler(ctx) {
				const { article, user } = ctx.params;
				return this.findByArticleAndUser(article, user)
					.then(item => !!item);
			}
		},

		/**
		 * Count of favorites.
		 * 
		 * @actions
		 * 
		 * @param {String?} article - Article ID
		 * @param {String?} user - User ID
		 * @returns {Number}
		 */		
		count: {
			cache: {
				keys: ["article", "user"]
			},
			params: {
				article: { type: "string", optional: true },
				user: { type: "string", optional: true },
			},
			handler(ctx) {
				let query = {};
				if (ctx.params.article) 
					query = { article: ctx.params.article };
				
				if (ctx.params.user) 
					query = { user: ctx.params.user };

				return this.adapter.count({ query });
			}
		},

		/**
		 * Delete a favorite record
		 * 
		 * @actions
		 * 
		 * @param {String} article - Article ID
		 * @param {String} user - User ID
		 * @returns {Number} Count of removed records
		 */		
		delete: {
			params: {
				article: { type: "string" },
				user: { type: "string" },
			},
			handler(ctx) {
				const { article, user } = ctx.params;
				return this.findByArticleAndUser(article, user)
					.then(item => {
						if (!item)
							return this.Promise.reject(new MoleculerClientError("Articles has not favorited yet"));

						return this.adapter.removeById(item._id)
							.then(json => this.entityChanged("removed", json, ctx).then(() => json));
					});
			}
		},

		/**
		 * Remove all favorites by article
		 * 
		 * @actions
		 * 
		 * @param {String} article - Article ID
		 * @returns {Number} Count of removed records
		 */		
		removeByArticle: {
			params: {
				article: { type: "string" }
			},
			handler(ctx) {
				return this.adapter.removeMany(ctx.params);
			}
		}
	},

	/**
	 * Methods
	 */
	methods: {
		/**
		 * Find the first favorite record by 'article' or 'user' 
		 * @param {String} article - Article ID
		 * @param {String} user - User ID
		 */
		findByArticleAndUser(article, user) {
			return this.adapter.findOne({ article, user });
		},
	},

	events: {
		"cache.clean.favorites"() {
			if (this.broker.cacher)
				this.broker.cacher.clean(`${this.name}.*`);
		},
		"cache.clean.users"() {
			if (this.broker.cacher)
				this.broker.cacher.clean(`${this.name}.*`);
		},
		"cache.clean.articles"() {
			if (this.broker.cacher)
				this.broker.cacher.clean(`${this.name}.*`);
		}
	}
};