Part 1
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

## References
* [html-to-elm](http://mbylstra.github.io/html-to-elm/) - paste in HTML, get elm-html code
* [elm-html documentation](http://package.elm-lang.org/packages/evancz/elm-html/4.0.2/)
* [record syntax](http://elm-lang.org/docs/syntax#records) (e.g. `{ foo = 1, bar = 2 }`)
