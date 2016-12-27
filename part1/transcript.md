# Transcript [![contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat)](https://github.com/rtfeldman/elm-workshop/issues)

> The purpose of this transcript is to:
+ make the video content ***accessible*** to **hearing impaired** people.
+ give ***non-english speakers*** a reference they can _read_
in case they **don't understand** what is being said.
(_in some cases the speech is too fast..._)
+ let people run the content through a ***translation*** service
when they _really_ don't understand what has been said.
This can often greatly enhance the learning experience for non-native learners.
And if FrontendMasters ever decide to add a "_subtitles_" feature,
having human-written transcript is still _much_ better than
computer-generated subtitles.
+ (100% Optional) ***enhance*** the content with hyperlinks on specific terms
so people don't have to google for ages to understand things.

This is `elm`. I'm Richard Feldman @rtfeldman

So we're going to start with just the absolute basics,
just **Rendering a Page**. but before we can do that,
we kind of need to understand a few things.

One thing to understand is that `elm` compiles to `JavaScript`.
So what does that mean?
To explain this, I want to start by looking at something else
that compiles to `JavaScriot`, namely `Babel`.

> https://babeljs.io/repl/

So this is `Babel`, probably you are familiar with this,
but for those that are not the basic idea is that
`Babel` compiles future (_or current_) `JavaScriot` spec to
backwards-compatible `JavaScript` for older browsers.

ES2015 Code:
```js
let pluralize =
  (singular, plural, quantity) => {
    if (quantity === 1) {
      return singular;
    } else {
      return plural;
    }
  }

console.log(pluralize("leaf", "leaves", 1));
```

![elm-workshop-babel-example](https://cloud.githubusercontent.com/assets/194400/21490535/5c10c0d6-cbed-11e6-94f9-560f9cb470a9.png)

So here on the _left_ we are using
[`let`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/let)
and we're using an
[arrow function `->`](https://developer.mozilla.org/en/docs/Web/JavaScript/Reference/Functions/Arrow_functions)
Those are _new_ things to `JavaScript`
if you are Internet Explorer 10
you don't _know_ about these things.
So in order to write code like this,
and end up with code that can run on
Internet Explorer 10, for example,
you could run it through something like `Babel`.
So `Bable` will take this code
and it will generate _this_ code (_gestures to the code on the right side_)
It will _compile_ to this `JavaScript` (_on the right_).
The basic idea here is that you write this code on the left
and you give the browser this code on the right.
So you can see that it's pretty much the same stuff,
just that it's added in a `"use strict";`
and it's changed the
[arrow function `->`](https://developer.mozilla.org/en/docs/Web/JavaScript/Reference/Functions/Arrow_functions)
to the _word_ `function`
and it's changed the `let` to a `var`.

So what is this function actually _doing_?
This function is called pluralize.
So this is something you might use if you've got say
a table full of things, let's say leaves in this case.
And you want to, at the bottom (_referring to the `console.log`_)
tell the user how many things are in this list.
So you could just say the `number` followed by the word "**leaves**"
but that will be kind of _embarassing_ if there happens
to only be _one thing_ in the list.
Because then we will say "**One _leaves_**"
and people will say: "_what is this?
[**Amateur Hour?**](http://www.urbandictionary.com/define.php?term=Amateur%20Hour)_"
You just use a `pluralize` function
so that's all this does; it looks at what you give it
takes a _singular_ form so "**leaf**"
and a _plural_ form "**leaves**"
and says: "_if the **quantity** that you gave me
is **exactly** one then we will use the **singular**
otherwise we will use the **plural**_."

Ok, so this is what that looks like in `Babel`,
here's what that looks like in `Elm`:

```elm-lang
import Html exposing (..)
import Html.Attributes exposing (..)

pluralize singular plural quantity =
  if quantity == 1 then
      singular
  else
      plural

main =
    text (pluralize "leaf" "leaves" 1)
```

![elm-workshop-pluralize](https://cloud.githubusercontent.com/assets/194400/21490825/319cdcc4-cbf0-11e6-9857-01dac3978ab2.png)

This is essentially the same thing,
this is "try `elm`": http://elm-lang.org/examples/hello-html

The only difference is that instead of showing you the _compiled_ `JavaScript`
on the _right_, it's instead just running it through the browser.
So on the _left_ we have the `elm` code
it's _getting_ compiled to `JavaScript` in the same way that `Babel` does,
and then "try `elm`" is _immeadiately_ handing that off to the browser
so the browser can _run_ it.
And this right here is the same function we had over there,
it's the same implementation except instead of writing in "ES6"
we're writing it in `elm`.

So let's talk through what this code does.


![elm-workshop-compiles-to-javascript](https://cloud.githubusercontent.com/assets/194400/21490962/036968f8-cbf1-11e6-95b5-e89dcb3b32eb.png)

So, first thing to note is a few differences
in the definition of this function by its' self.
So we can see that in `Babel` we are writing
`let` and then `pluralize` _equals_
whereas in `elm` we are writing `pluralize`
followed by the _arguments_ followed by the equals (`=`);
the arguments go to the _left_ of the quals sign.
Where as in `Babel` (_ES2015_) they are in parentheses with commas
after the the name of the function.


![elm-workshop-pluralize-function-comparison](https://cloud.githubusercontent.com/assets/194400/21491586/c8452adc-cbf5-11e6-99d5-531643ff091e.png)

There are _other_ ways you can write this,
but for the purposes of this comparison,
the relevant thing to note is that in `elm`
if you are defining a function like this,
the name of the function
then whatever arguments you want it to have
no commas in between, just whitespace
and then the equals sign.

Next thing to note is that we have got this comparison here
so `if`, `if` on the _left_ if on the _right_
we see a couple of differences with the curly braces versus `then`
still just comparing the `quantity` equal to 1
`singular` versus `plural`.

So let's break down those differences a little more.
We talked about the _arguments_ being different:


![elm-workshop-arguments](https://cloud.githubusercontent.com/assets/194400/21491544/7a8d8b7c-cbf5-11e6-8d16-faddbfde6b65.png)


Also note that there are no parentheses around the `if`.

![elm-workshop-no-parentheses](https://cloud.githubusercontent.com/assets/194400/21491636/00c333b8-cbf6-11e6-8b6b-d5c175118539.png)

so in `elm` you don't _need_ to put parentheses around there
if you _want_ you can always _introduce_ parentheses
in order to _group_ things and _disambiguate_,
so if you _wanted_ to you could put parentheses around
`if quantity == 1` e.g: `(if quantity == 1) then`
but you typically _wouldn't_, you don't need to
and it's considered "**best practices**" to only put in parentheses
when you're actually disambiguating something.

![elm-workshop-double-equals](https://cloud.githubusercontent.com/assets/194400/21491663/3f3d0cc2-cbf6-11e6-84d4-6b1cb97ed775.png)

Also note that in `elm` we use _double_ equals (`==`) instead of _tripple_ equals (`===`),
there actually is _no_ triple equals operator built-in to `elm`
because _double_ equals (`==`) just works the way you want it to.
So there is no
[rule of thumb](http://stackoverflow.com/questions/359494/which-equals-operator-vs-should-be-used-in-javascript-comparisons)
(_like there is in `JavaScript`_)
of use one vs. the other,
just use _double_ equals (`==`) and it will "_do the right thing_".

![elm-workshop-else-is-required](https://cloud.githubusercontent.com/assets/194400/21491673/5c6a7d84-cbf6-11e6-8051-7c52a46ff12f.png)

Another thing to know about `elm` is that `else` is ***required***.
In `JavaScript` it's perfectly _acceptable_ to write an `if` statement
that does not have a a corresponding `else`
but in `elm` you ***always*** need an `else`; every `if` must come with an `else`

That's _because_ this whole thing is an _expression_.

![elm-workshop-function-expression](https://cloud.githubusercontent.com/assets/194400/21491690/7b13f332-cbf6-11e6-80fb-a164f67c53ac.png)

In `JavaScript` you can have a
[_ternary expression_](https://developer.mozilla.org/en/docs/Web/JavaScript/Reference/Operators/Conditional_Operator)
like this _instead_ of an `if`:
```js
quantity === 1 ? singular : plural
```
and that is what this is properly,
this refers to, the `JavaScript` _equvalent_ of this `elm` code really
is not an `if` statement but rather a
[_ternary expression_](https://developer.mozilla.org/en/docs/Web/JavaScript/Reference/Operators/Conditional_Operator)
like this.
So in `JavaScript` you would say "_quantity triple equals 1_" (_the condition_)
in `elm` you say: "_if quantity double-equals 1 then here's what
you do if that's `True` and here's what you do if that's `False`_"
So, _same_ basic idea.
