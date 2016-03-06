var fs = require("fs");
var execSync = require("child_process").execSync;
var path = require("path");

fs.readdirSync("stages").forEach(function(stage) {
  var cwd = path.join(__dirname, "stages", stage);

  console.log("Installing packages for " + cwd);
  execSync("elm-package install --yes", { cwd: cwd });

  var testCwd = path.join(cwd, "test");

  if (fs.existsSync(testCwd)) {
    execSync("elm-package install --yes", { cwd: testCwd });
  }
});
