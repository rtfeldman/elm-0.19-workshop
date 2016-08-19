Part 8
======

The instructor will paste notes from the lesson, including code examples from
Q&A, in [this document](https://docs.google.com/document/d/1ApuSOk9DP0YsQrxhW7-WE8UOEAV4PPnLDDeqUOL2o5k/edit?usp=sharing).

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

Then visit [localhost:8000](http://localhost:8000) and choose `Html.elm`.

## References

* [Using Elm packages](https://github.com/elm-lang/elm-package/blob/master/README.md#basic-usage)
* [elm-test documentation](http://package.elm-lang.org/packages/project-fuzzball/test/latest)
* [`(<|)` documentation](http://package.elm-lang.org/packages/elm-lang/core/4.0.0/Basics#<|)
