# Part 5

This time, we'll still be *building* `src/Main.elm`, but a few things will be different:

1. We'll be *editing* a different file. (`elm make` will figure out it needs to compile our edited file as well, because `src/Main.elm` imports it!)
2. We'll open `localhost:3000` instead of `index.html`.
3. We'll specify a different `--output` target. (Explained next.)

To build everything, `cd` into the `part5/` directory and run:

```shell
elm make src/Main.elm --output ../server/public/elm.js
```

Then open `http://localhost:3000/#/register` in your browser. (Opening `index.html` will not work anymore; from now on we'll be using the server we set up at the beginning of the workshop!)

## Exercise

Open `src/Page/Register.elm` in your editor and resolve the TODO there.

This time we'll be fixing a bug in an existing code base! It's only one TODO,
so that you have time to orient yourself in an unfamiliar code base.

Because this is a more real-world code base, it uses some concepts we haven't
covered yet. For example, you may be wondering things like "What does Cmd.none
do?" This is okay! You won't need to know those concepts to complete the exercise.

You may surprise yourself at how well you can already navigate around an Elm
code base, despite not knowing 100% of what the code is doing. As you'll
see, the compiler has your back!


