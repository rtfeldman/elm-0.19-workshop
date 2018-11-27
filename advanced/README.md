Advanced Elm Workshop
=====================

If you haven't already, follow the [Getting Started instructions](https://github.com/rtfeldman/elm-0.19-workshop/blob/master/README.md
) at the root of this repository, then continue here!

## Start the server

We'll be running a local server for our Elm UI to use. Let's get it set up.

```shell
cd advanced/server
npm install
npm start
```

If the server started up successfully, you should see
`> moleculer-runner services` at the end of your terminal.

We're going to leave this server running and not touch it again for the duration
of the workshop, so **don't close it** until the workshop is over!

## Build the Elm UI

Leave the existing terminal running, and open a **second** terminal.

In the new termnal, `cd` into the `elm-0.19-workshop/advanced/server/` directory again.

Then run this to build the Elm code for the first time:

```shell
elm make src/Main.elm --output=../server/public/elm.js
```

## Verify your setup

Open [http://localhost:3000](http://localhost:3000)
in your browser. You should see this in it:

<img width="375" alt="A screenshot showing “You’re all set!”" src="https://user-images.githubusercontent.com/1094080/39399636-63605a72-4aef-11e8-82bc-2b94e85369d1.png">

If things aren’t working, the instructor will be happy to help!

## Links

* [The solutions to these exercises](https://github.com/rtfeldman/elm-0.19-workshop/tree/solutions/advanced)
* [Slides for the Frontend Masters workshop that goes with this repo](https://docs.google.com/presentation/d/1aFZBXs9kzlZww2JN6iDmrYiQaxKlCAz6a5zpt882GHk/edit?usp=sharing)
* [Advanced Elm Video Course](https://frontendmasters.com/courses/advanced-elm/) that goes with this repo
* [The Life of a File](https://www.youtube.com/watch?v=XpDsk374LDE) - Evan Czaplicki
* [The Importance of Ports](https://www.youtube.com/watch?v=P3pL85n9_5s) - Murphy Randle
* [Working with Maybe](https://www.youtube.com/watch?v=43eM4kNbb6c) - Joël Quenneville
* [Making Impossible States Impossible](https://www.youtube.com/watch?v=IcgmSRJHu_8) - Richard Feldman
* [Scaling Elm Apps](https://www.youtube.com/watch?v=DoA4Txr4GUs) - Richard Feldman
* [Make Data Structures](https://www.youtube.com/watch?v=x1FU3e0sT1I) - Richard Feldman
