<i>This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International License</a>. Enjoy!</i>

Getting Started
===============

## Installation

1. Install [Node.js](http://nodejs.org) 6.9.2 or higher

2. Add a plugin for your editor of choice: [Atom](https://atom.io/packages/language-elm), [Sublime Text](https://packagecontrol.io/packages/Elm%20Language%20Support), [VS Code](https://github.com/sbrink/vscode-elm), [Light Table](https://github.com/rundis/elm-light), [Vim](https://github.com/lambdatoast/elm.vim), [Emacs](https://github.com/jcollard/elm-mode), [Brackets](https://github.com/lepinay/elm-brackets)

3. Not required, but **highly** recommended: enable "[`elm-format`](https://github.com/avh4/elm-format) on save" in your editor.

4. Run the following command to install everything else:

```bash
npm install -g elm elm-test elm-css elm-live@2.6.1 elm-format@exp
```
**Note to macOS users:** If step 4 gives you an `EACCESS` error, try [this fix](https://docs.npmjs.com/getting-started/fixing-npm-permissions):


```
sudo chown -R $(whoami) $(npm config get prefix)/{lib/node_modules,bin,share}
```

Then re-run step 4.

## Clone this repository

Run this at the terminal:

```bash
git clone https://github.com/rtfeldman/elm-workshop.git
cd elm-workshop
```

**Note:** Tab characters are syntax errors in Elm code, so if your editor uses them for indentation, definitely switch it to spaces for this workshop!

## Create a GitHub Personal Access Token

We'll be using GitHub's [Search API](https://developer.github.com/v3/search/), and authenticated API access lets us experiment without worrying about the default rate limit. Since we'll only be accessing the Search API, these steps can be done either on your personal GitHub account or on a throwaway account created for this workshop; either way will work just as well.

1. Visit https://github.com/settings/tokens/new
2. Enter "Elm Workshop" under "Token description" and leave everything else blank.
3. Create the token and copy it into a new file called `Auth.elm`:

#### Auth.elm

```elm
module Auth exposing (token)


token =
    -- Your token should go here instead of this sample token:
    "abcdef1234567890abcdef1234567890abcdef12"
```

**Note:** Even for a token that has no permissions, good security habits are
still important! `Auth.elm` is in `.gitignore` to avoid accidentally checking in
an API secret, and you should [delete this token](https://github.com/settings/tokens) when the workshop is over.


## Verify Setup

Run this to install packages:

```bash
elm-package install --yes
```

Once that succeeds, run this to verify everything:

```bash
elm-live Main.elm --open --output=elm.js
```

A browser should open, and you should see this in it:

![](https://cloud.githubusercontent.com/assets/1094080/14227327/db89d3a0-f8af-11e5-8c37-c3e8afaa9d03.png)

If things aren't working, the instructor will be happy to help!

## Start with Part 1

Run this at the terminal:

```bash
cd part1
```

Now head over to the [README for Part 1](https://github.com/rtfeldman/elm-workshop/tree/master/part1)!
