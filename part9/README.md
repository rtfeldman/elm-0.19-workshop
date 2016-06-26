Part 9
======

The instructor will paste notes from the lesson, including code examples from
Q&A, in [this document](https://docs.google.com/document/d/1ApuSOk9DP0YsQrxhW7-WE8UOEAV4PPnLDDeqUOL2o5k/edit?usp=sharing).

## Installation

```bash
elm-package install
```

(Answer `y` at the prompt. In rare cases a known issue can cause the download
to fail; in that case, just run `elm-package install` again.)

## Building

```bash
elm-live Main.elm --open --output=elm.js
```

## Running Tests

First do this:

```bash
cd test
elm-package install
```

Then do either (or both!) of the following:

#### Running tests on the command line

```bash
elm-test NodeRunner.elm
```

#### Running tests in a browser

```bash
elm-reactor
```

Then visit [localhost:8000](http://localhost:8000) and choose `Html.elm`.
