`Day 1 Hour 1 - h1.mp4 @ 05:11`
Now the _relevant_ part is that
this entire chunk of code is an expression;
it evaluates to a single value which means it's "_portable_".
You can pick it up and just drop it somewhere else
and just say "`foo` equals `if quantity == 1 then singular else plural`..."
You can do that anywhere you would have any single value.
You can just drop in this entire `if` expression,
perhaps with parentheses around it to disambiguate.
And it's exactly the same thing with the ternary
and so you need this both `if` and `else`
because it needs to be _clear_ what value is going to be substituted in there
if you do drop this in place of any other value.

![elm-workshop-call-pluralize-passing-3-arguments](https://cloud.githubusercontent.com/assets/194400/21498925/1d67a084-cc29-11e6-915e-00bb2161a019.png)

So here's how function _calling_ works
this was the code we had in "try `elm`"
slightly below the definition of `pluralize`
_calling_ a function is just done with
[`whitespace`](https://en.wikipedia.org/wiki/Whitespace_character)
so we are going to say `pluralize` followed by some `whitespace`
followed by its' `arguments`.

Also note that there are no commas between the arguments
so it's just `pluralize "leaf" "leaves" 1`
the parentheses here in _this_ case are to disambiguate
between two function calls that we are making
so this right here, that's all one function call:

![elm-workshop-one-function-call](https://cloud.githubusercontent.com/assets/194400/21499255/2ace3064-cc2c-11e6-9fce-0fc4c2ec1a9c.png)

and this is actually a _second_ function call,
we're calling a function called `text`:

![elm-workshop-second-function-call](https://cloud.githubusercontent.com/assets/194400/21499028/18602ac4-cc2a-11e6-8272-10ef12f68662.png)

and what we're _passing_ to `text` is the _result_ of
calling `pluralize` passing `"leaf"` `"leaves"` and `1`

so this is calling a function (_`pluralize`_) passing 3 arguments:
![elm-workshop-call-pluralize-passing-3-arguments-cropped](https://cloud.githubusercontent.com/assets/194400/21499171/7e2d426e-cc2b-11e6-804f-624e39cfb72c.png)

and this is calling another function (_`text`_) passing 1 argument:
![elm-workshop-function-call-text-one-argument](https://cloud.githubusercontent.com/assets/194400/21499188/a0738e64-cc2b-11e6-83a1-1da36551ef34.png)

the one argument we are passing is the result of the other function.
note that this is a case of the parentheses serving to disambiguate.
if we did not have the parentheses here
this would be indistinguishable from calling `text` passing in _four_ arguments.
the first is the function `pluralize`
and then `"leaf"` `"leaves"` and `1`
is the other three.
So parentheses for disambiguation
but otherwise whitespace is just what you do for calling functions.

Finally we have at the top
we have this `import Html` exposing `..`
![elm-workshop-import-html-exposing-dot-dot](https://cloud.githubusercontent.com/assets/194400/21499344/e8e4ea84-cc2c-11e6-8bde-26a426e00a06.png)
we'll get into **modules** a little more later,
but it's basically just saying:
"_Hey, bring in the `Html` module and expose all of the stuff in there._"
such as this `text` function and we will make use of those.

`Day 1 Hour 1 - h1.mp4 @ 07:15`
OK, so "***why bother?***"

![elm-workshop-why-bother](https://cloud.githubusercontent.com/assets/194400/21499402/56e173fe-cc2d-11e6-9e0b-bf4fa6cd2989.png)

I just taught you a _bunch_ of new syntax,
and showed you how you can write the same thing in `JavaScript`
***why bother*** learning a _whole different language_...?
is it just learning _syntax_ for _nothing_?

What can you do in `elm`, like what does it _get_ you that `Babel` does _not_?
That's a _great_ question.
So, let's say we've got this implementation
and we `build` it and we're going to use it in `production`
and _hopefully_ we write tests for it,
_hopefully_ those tests do a good job covering the different cases.
But let's say we make a _mistake_ in our implementation here:

So we're like:
`pluralize "leaf" "leaves" 1`
![babel-pluralize-leaf-leaves-1--leaf](https://cloud.githubusercontent.com/assets/194400/21518751/6efa32ba-cce0-11e6-82f6-d945d6e6de01.png)
and it gives us "leaf" down here (_refering to the `console.log` output at the bottom of the Babel page_)

If we call `pluralize` passing `"leaf"` `"leaves"` and `3`
![babel-pluralize-leaf-leaves-3--leaves](https://cloud.githubusercontent.com/assets/194400/21518825/db66b090-cce0-11e6-97d7-1513a4d52c70.png)
It gives us "leaves".
Great! that's what we _expect_!
Any number over 1 should give us the `plural` form.

And then let's say,
when we implemented this we _accidentally_ made a typo here:

Instead of `singular` we said `singula` ...

Ok, so, as we can see, this code _still works_!
