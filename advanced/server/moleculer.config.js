"use strict";

const os = require("os");

module.exports = {
	// It will be unique when scale up instances in Docker or on local computer
	nodeID: os.hostname().toLowerCase() + "-" + process.pid,

	logger: false,
	logLevel: "info",

	cacher: "memory",

	metrics: false
};
