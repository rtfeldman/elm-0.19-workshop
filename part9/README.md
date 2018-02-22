Part 9
======

## Installation

```bash
elm-package install
```

(Answer `y` when prompted.)


## Building

```bash
elm-live Main.elm --open --output=elm.js
```

## Running Tests

Do either (or both!) of the following:

#### Running tests on the command line

```bash
elm-test
```

#### Running tests in a browser

```bash
cd tests
elm-reactor
```

Then visit [localhost:8000](http://localhost:8000) and choose `HtmlRunner.elm`.

## References

* [Using Elm packages](https://github.com/elm-lang/elm-package/blob/master/README.md#basic-usage)
* [elm-test documentation](http://package.elm-lang.org/packages/elm-community/elm-test/latest)
* [`(<|)` documentation](http://package.elm-lang.org/packages/elm-lang/core/latest/Basics#<|)
