# Parser Primitives

**In 99.9999% of cases, you do not want this.**

When creating a parser combinator library like [`elm-tools/parser`](https://github.com/elm-tools/parser), you want lower-level access to strings to get better performance.

This package exposes these low-level functions so that `elm-tools/parser` does not have an unfair performance advantage.
