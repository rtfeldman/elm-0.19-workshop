Introduction to Elm Workshop
============================

If you haven't already, follow the [Getting Started instructions](https://github.com/rtfeldman/elm-0.19-workshop#getting-started
) at the root of this repository, then continue here!

## Start the server

We'll be running a local server for our Elm UI to use. Let's get it set up.

```shell
cd intro/server
npm install
npm start
```

If the server started up successfully, you should see
`> moleculer-runner services` at the end of your terminal.

We're going to leave this server running and not touch it again for the duration
of the workshop, so **don't close it** until the workshop is over!

## Build the Elm UI

Leave the existing terminal running, and open a **second** terminal.

In the new termnal, `cd` into the `elm-0.19-workshop/intro/server/` directory again.

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

* [The solutions to these exercises](https://github.com/rtfeldman/elm-0.19-workshop/tree/solutions/intro)
* [Slides for the Frontend Masters workshop that goes with this repo](https://docs.google.com/presentation/d/1LM_W2BRs_ItT-SPDe70C10cbwhGNHGQlJ1fVnAdnRIY/edit?usp=sharing)
* [Elm in Action](https://www.manning.com/books/elm-in-action?a_aid=elm_in_action&a_bid=b15edc5c), a book by [Richard Feldman](https://twitter.com/rtfeldman), creator of this workshop
* [Official Elm Guide](https://guide.elm-lang.org/) by [Evan Czaplicki](https://twitter.com/czaplic), creator of Elm
* [Elm Slack](http://elmlang.herokuapp.com/) - amazingly helpful chat community. People in [the `#beginners` channel](https://elmlang.slack.com/messages/C192T0Q1E/) are happy to answer questions!
* [Elm Discourse](https://discourse.elm-lang.org/) - for longer-form discussions.
