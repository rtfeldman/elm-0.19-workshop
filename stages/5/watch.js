var fs = require("fs");
var execSync = require("child_process").execSync;
var path = require("path");
var binPath = path.join(__dirname, "..", "..", "node_modules", ".bin");
var watchPath = path.join(binPath, "elm-live");

execSync(watchPath + " src/Main.elm --open -- --output=elm.js", { stdio: "inherit" });
