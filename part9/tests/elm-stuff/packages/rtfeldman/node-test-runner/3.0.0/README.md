# node-test-runner [![Version](https://img.shields.io/npm/v/elm-test.svg)](https://www.npmjs.com/package/elm-test) [![Travis build Status](https://travis-ci.org/rtfeldman/node-test-runner.svg?branch=master)](http://travis-ci.org/rtfeldman/node-test-runner) [![AppVeyor build status](https://ci.appveyor.com/api/projects/status/fixcy4ko78di0l31/branch/master?svg=true)](https://ci.appveyor.com/project/rtfeldman/node-test-runner/branch/master)

Runs [elm-test](https://github.com/elm-community/elm-test) suites from Node.js

## Installation

```bash
npm install -g elm-test
```

## Usage

```bash
elm-test init  # Adds the elm-test dependency and creates Main.elm and Tests.elm
elm-test       # Runs the tests
```

Then add your tests to Tests.elm.


### Configuration

The `--compiler` flag can be used to use a version of the Elm compiler that
has not been install globally.

```
npm install elm
elm-test --compiler ./node_modules/.bin/elm-make
```


### Travis CI

If you want to run your tests on Travis CI, here's a good starter `.travis.yml`:

```yml
language: node_js
node_js:
  - "5"
install:
  - npm install -g elm
  - npm install -g elm-test
  - elm-package install -y
  - pushd tests && elm-package install -y && popd
script:
  - elm-test
```
