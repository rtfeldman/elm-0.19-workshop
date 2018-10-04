<i>This workshop is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International License</a>. The `server/` directories use [`moleculer-node-realworld-example`](https://github.com/gothinkster/moleculer-node-realworld-example-app), which has its own license. The JavaScript interop example uses [`localForage`](https://github.com/localForage/localForage), which is (c) 2013-2017 Mozilla, under the Apache License 2.0. The rest of the code is a variation on [`elm-spa-example`](https://github.com/rtfeldman/elm-spa-example/), an [MIT-licensed](https://github.com/rtfeldman/elm-spa-example/blob/master/LICENSE) implementation of the [`realworld`](https://github.com/gothinkster/realworld) front-end. Many thanks to the authors of these projects!</i>

Getting Started
===============

1. Install [Node.js](http://nodejs.org) 7.0.0 or higher

2. Install the `elm` binary for [Mac](https://github.com/elm/compiler/releases/download/0.19.0/installer-for-mac.pkg), [Windows](https://github.com/elm/compiler/releases/download/0.19.0/installer-for-windows.exe), or [Linux](https://gist.github.com/evancz/442b56717b528f913d1717f2342a295d).

3. Add a plugin for your editor of choice: [Atom](https://atom.io/packages/language-elm), [Sublime Text](https://packagecontrol.io/packages/Elm%20Language%20Support), [VS Code](https://github.com/sbrink/vscode-elm), [Light Table](https://github.com/rundis/elm-light), [Vim](https://github.com/lambdatoast/elm.vim), [Emacs](https://github.com/jcollard/elm-mode), [Brackets](https://github.com/lepinay/elm-brackets)

4. Not required, but **highly** recommended: enable "[`elm-format`](https://github.com/avh4/elm-format) on save" in your editor.

5. Run the following command to install all the other Elm tools:

> **Note:** Make sure not to run this command with `sudo`! If it gives you an `EACCESS` error, apply [**this fix**](https://docs.npmjs.com/getting-started/fixing-npm-permissions#option-two-change-npms-default-directory) and then re-run the command (still without `sudo`).

```shell
npm install -g elm-test@beta elm-format
```

6. Clone this repository

Run this at the terminal:

```shell
git clone https://github.com/rtfeldman/elm-0.19-workshop.git
cd elm-0.19-workshop
```

7. Continue with either the [`intro`](https://github.com/rtfeldman/elm-0.19-workshop/blob/master/intro/README.md) or [`advanced`](https://github.com/rtfeldman/elm-0.19-workshop/blob/master/advanced/README.md) instructions, depending on which workshop you're doing!
