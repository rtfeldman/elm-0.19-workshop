# Part 7

Once again, we'll be building `src/Main.elm`, but editing different files.

To build everything, `cd` into the `part7/` directory and run:

```shell
elm make src/Main.elm --output ../server/public/elm.js
```

Then open `http://localhost:3000` in your browser.

## Exercise

The articles in the feed don't quite look right!

We'll fix them by editing `src/Article.elm` and resolving the TODO there.
