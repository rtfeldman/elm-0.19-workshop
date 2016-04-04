Part 3
======

## Installation

```bash
elm package install
```

(Answer `y` at the prompt. In rare cases a known issue can cause the download
to fail; in that case, just run `elm package install` again.)

## Building

```bash
elm live Main.elm --open -- --output=elm.js
```

## References

* [`onClick` documentation](http://package.elm-lang.org/packages/evancz/elm-html/4.0.2/Html-Events#onClick)
* [record update syntax reference](http://elm-lang.org/docs/syntax#records) (e.g. `{ model | query = "foo" }`)
