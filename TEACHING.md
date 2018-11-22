## Running this workshop

Hi there! 👋

I’m [Richard](https://twitter.com/rtfeldman), and I made this workshop. I hope
you like it! I’ve [run it for Frontend Masters](https://frontendmasters.com/courses/elm/)
as well as [for Pluralsight](https://www.pluralsight.com/courses/elm), and
in person at a bunch of conferences. (If you’d like me to run it at a particular
conference, have the organizers [ping me](https://twitter.com/rtfeldman)!)

I released the material I’ve made here under
<a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons</a>
so others can use it to run their own workshops. If that’s you, great! Here’s
some info about it that may be helpful in teaching this workshop.

## Slides

The [slides](https://docs.google.com/presentation/d/1LM_W2BRs_ItT-SPDe70C10cbwhGNHGQlJ1fVnAdnRIY/edit?usp=sharing)
I use with the workshop include speaker notes. If you’ve seen me give this
workshop before, you may notice that I’m not following these notes very closely.

This is because I made the notes for other teachers, not for myself. In general
I prefer not to use speaker notes, but I thought it would be unreasonable to
expect other teachers who wanted to use this material to watch hours of video
to figure out what words the slides were designed to complement. Writing speaker
notes seemed like a nice way to save other teachers a bunch of time, so
that’s what I did!

If you spot any mistakes in the speaker notes, or have any questions about them,
please don’t hesitate to ask me in the
[`#teaching` channel](https://elmlang.slack.com/messages/C0MF3BQ7K/)
on [Elm Slack](http://elmlang.herokuapp.com/).

## Schedule

The Intro and Advanced courses are each designed to be a full-day workshop.
You may not have a full day to work with, but I figure it’ll be helpful to cover
how I use this material. The schedule I follow is typically something like:

* 30 minutes - help everyone get set up, buffer for late arrivals
* 2.5 hours - cover parts 1-4
* 1 hour - lunch
* 4 hours - cover parts 5-10, with a couple of 10 minute breaks sprinkled in

Definitely get through part 4 before lunch if possible. Teaching gets harder
after lunch because [humans are programmed to get sleepy in the early
afternoon](https://www.webmd.com/balance/features/afternoon-energy-boosters#1).
Part 4 introduces types in the Intro workshop, and you don’t want to introduce
types to sleepy students.

## Teaching Tips for the Intro Workshop

I gave a talk about [teaching Elm to beginners](https://www.youtube.com/watch?v=G-GhUxeYc1U)
which has a bunch of my thoughts on the subject.  The
[`#teaching` channel](https://elmlang.slack.com/messages/C0MF3BQ7K/)
on [Elm Slack](http://elmlang.herokuapp.com/)
is a great place to chat about workshops, exchange tips, etc. Come say hi!

One big piece of advice I have for this workshop is to
**minimize the number of new concepts you introduce**.

The goal of the workshop is that students will be able to build Elm applications
on their own. This requires digesting a **ton** of new information,
and piling on even more on top of what’s absolutely necessary is harmful to
those students who are already struggling to keep up.

For example, I only use the term “partial application” to explain that concept.
I very deliberately do **not** introduce the term “currying.” If a student asks
“is this currying?” I give a short answer like “Yep!” and move on quickly.

Why not mention it, though? What could it hurt to throw that in?

Students who have been cruising through material might easily absorb this info
and move on, but imagine a student who’s really struggled to keep up.
Imagine them thinking “wait, I already don’t understand partial application -
and now I need to learn currying too? What’s the difference? *Is* there a
difference? Should I raise my hand and ask, or is that a stupid question?
Argh, this is so frustrating!”

It can feel shameful to admit publicly that you don’t understand what the
teacher just covered. Especially when everyone else seems to have gotten it.
Double especially if you’re sitting near that one student who’s always raising
their hand and asking stuff like “so it’s an applicative functor, right?”
They make it sound like this is the easiest stuff in the world! Are they
going to laugh if you raise your hand and say “I still don’t get why
`(List.map negate)` compiles. Can you explain how that works again?”

If a student is struggling, they generally won’t say so out loud. You won’t
find out until you see the mistakes they make on the exercises. Just know that
some students in every class will struggle, and that extraneous info that’s a
nice-to-have for students who are cruising through the workshop may be
detrimental to those who are barely hanging in there.

Remember, the goal is that students will be able to build Elm applications on
their own. **Minimize the number of new concepts you introduce** so you minimize
the chance that they’ll get overwhelmed and give up before reaching that goal!
