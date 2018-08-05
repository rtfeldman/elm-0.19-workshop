<i>This workshop is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International License</a>. The `server/` directory uses [`moleculer-node-realworld-example`](https://github.com/gothinkster/moleculer-node-realworld-example-app), which has its own license. The rest of the code is a variation on [`elm-spa-example`](https://github.com/rtfeldman/elm-spa-example/), an [MIT-licensed](https://github.com/rtfeldman/elm-spa-example/blob/master/LICENSE) implementation of the [`realworld`](https://github.com/gothinkster/realworld) front-end. Many thanks to the authors of these projects!</i>

Getting Started
===============

1. Install [Node.js](http://nodejs.org) 7.0.0 or higher

2. Clone this repository

Run this at the terminal:

```shell
git clone https://github.com/rtfeldman/elm-0.19-workshop.git
cd elm-workshop
```

3. Start the server

We'll be running a local server for our Elm UI to use. Let's get it set up.

```shell
cd server
npm install
npm start
```

If the server started up successfully, you should see
`> moleculer-runner services` at the end of your terminal.

We're going to leave this server running and not touch it again for the duration
of the workshop, so **don't close it** until the workshop is over!

## Build the Elm UI

Leave the existing terminal running, and open a **second** terminal.

In the new termnal, `cd` into the `elm-workshop/server/` directory again.

Then run this to build the Elm code for the first time:

```shell
elm make src/Main.elm --output=../server/public/elm.js
```

If things aren’t working, the instructor will be happy to help!

## Links

* [Elm in Action](https://www.manning.com/books/elm-in-action?a_aid=elm_in_action&a_bid=b15edc5c), a book by [Richard Feldman](https://twitter.com/rtfeldman), creator of this workshop
* [Official Elm Guide](https://guide.elm-lang.org/) by [Evan Czaplicki](https://twitter.com/czaplic), creator of Elm
* [Elm Slack](http://elmlang.herokuapp.com/) - amazingly helpful chat community. People in [the `#beginners` channel](https://elmlang.slack.com/messages/C192T0Q1E/) are happy to answer questions!
* [Elm Discourse](https://discourse.elm-lang.org/) - for longer-form discussions.
