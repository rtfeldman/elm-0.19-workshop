var fs = require("fs");
var execSync = require("child_process").execSync;
var path = require("path");
var testDir = path.join(__dirname, "test");
var binPath = path.join(__dirname, "..", "..", "node_modules", ".bin");
var elmTestPath = path.join(binPath, "elm-test");

execSync(elmTestPath + " TestRunner.elm", { cwd: testDir, stdio: "inherit" });
