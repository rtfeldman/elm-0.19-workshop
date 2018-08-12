# Part 8

Once again, we'll be building `src/Main.elm`, but editing a different file.

To build everything, `cd` into the `part8/` directory and run8

```shell
elm make src/Main.elm --output ../server/public/elm.js
```

Then open `http://localhost:3000` in your browser.

## Exercise

We need to make login work. Currently it doesn't actually send a HTTP request to the server.

We'll fix this by editing `src/Page/Login.elm` and resolving the TODOs there.
