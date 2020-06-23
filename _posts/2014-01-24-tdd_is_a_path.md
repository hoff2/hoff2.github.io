---
layout: post
title:  "The TDD That Can be Spoken Is Not the Eternal TDD"
description: A rant about TDD
date: 2014-01-24 12:00
modified: 2014-01-24
tags: [rails, tdd]
---

For all the talk on the interbutts about TDD and related topics, it
sure seems like as a working programmer I run into a startling amount
of projects -- a great majority, really -- that either have no tests,
or have old useless tests that were abandoned long ago; and a
startling number of developers who still don't write any tests at all,
let alone practice a TDD style of work. It's as if as an industry
we're all putting up a big front about how important testing and TDD
is to us but then when the fingers hit the keyboard, it's all lies.
That's probably not really the case, but rather that test-infected
developers are a small but vocal minority -- that developers that test
tend to also be the kinds of developers that blog, make podcasts,
present at conferences, write books, and so on, but these happen to
only be a sadly small percentage of all the developers out there
cranking out code. But this minority has been talking about testing
for what, a decade now at least? So why hasn't the portion of
developers seriously testing grown faster?

Once you've got going with TDD or even just a little automated
testing, and have come to rely on it, one of the most frustrating
things is to find yourself having to collaborate with others who have
not, and have no interest in it. You really don't want to leave an
only partly-tested system, meanwhile these other developers on your
project will make changes that break your tests with impunity. The
path of least resistance is to fall back in line with the rest of your
team and go back to what one of my professors back at UNI referred to
as the "compile-crap" cycle -- a loop of add or change some code, try
to compile it, say "crap" when fails, repeat -- except for interpreted
languages, substitute in place of the compile step, running the
application and trying to "use" it, so maybe call it the "run-crap"
cycle. This friction may well be one of the biggest factors slowing
the adoption of TDD; but the less developers are testing, the more it
will happen, so it's also an effect. It's a vicious feedback loop.

Then there's maintenance, and/or working with "legacy" code, without
tests, or with bad tests. Many a project is written with no tests ever
-- just banging out code in a run-crap loop.

Others start out with tests, but somewhere during the development
process something changes and the team reverts back to run-crap. Why
do they do this? It may be that members of the development team have
been swapped out for some, shall we say, ahem, "cheaper" ones; this
might happen when the product is launched and comes to be seen as in
"maintenance" phase, but it also happens earlier on. Or it may be that
the developers reverted to comfortable old habits in the face of
schedule pressure from management -- after all TDD can be slower in
the short-term, especially when you're new at it, and it's easy to
lose focus on careful discipline in favor of short-term speed (or at
least the _appearance_ thereof) when the management is breathing down
your neck or freaking out at you.

In any case, the eventual result is either no tests, or tests that are
no help because most of them are failing because they express
requirements that have since changed -- which might be even worse than
no tests at all; it can look like the best way to deal with it is to
just nuke the whole suite.

But then what? Touching on how TDD informs design, it's well
established that code written without TDD is likely to contain design
that is much harder to write tests for, with lots more coupling and
dependency snarls. As requests for bug fixes and new features come in
for such a system, how do you work on it in a test-driven manner?
Stopping the world long enough to retrofit a complete suite of
difficult-to-write tests isn't feasible and chances are there's no
documentation you can consult when you hit all those ambiguities in
what some code _should_ be doing, so you're likely not to even know
what exactly to test for -- the definition of "legacy code" as being
that for which requirements have been lost. Practicing TDD on
greenfield projects is relatively obvious; but the vast majority of
development time is spent in maintenance, and legacy/maintenance is
"advanced" TDD. I'm probably not telling you anything you don't
already know. Michael Feathers' book _Working Effectively With Legacy
Code_ is the authoritative source on the subject, but if it's not
feasible to halt work long enough to Test All The Things, then is it
feasible to halt work long enough to read a book, especially if you're
a painfully slow ADHD-stricken reader like myself? Yet again, it's
much easier to go back to the good old irritating-but-familiar
run-crap loop.

It's clear that as an industry we only stand to benefit by spreading
the good word of TDD far and wide. The more it's being done, the
better. But the factors I've just outlined present very real obstacles
to its adoption. It's a long-term project of raising awareness and
educating the developer public. Meanwhile, what can you as an
individual developer do? For starters, if you really want to do TDD
but are stuck in a job where everyone's oblivious to the concept, it's
probably not worth your time trying to force that kind of sea change
on your own. You're swimming against a torrent. My advice? Find a
company that's as serious about it as you are, and go work there
instead.

I myself don't even consider my work to be test-driven. I'm a
_believer_ in TDD, and I make the best, sincerest attempts at it I can
relative to the time and energy constraints within which I am working.
I certainly don't consider myself an enlightened TDD guru. I even come
out and say just that right in the introduction to my résumé. What's
that, you're supposed to talk yourself up in a résumé and make
yourself sound like the answer to all a company's prayers so that you
get the job? I don't believe in that. I'm hoping to score a gig
working with test-driven developers but I don't want to be expected to
be perfect at it from day one if such a company hires me; I want such
a job because I know I have a lot to learn and am looking for
advantageous situations in which to learn. It pains me that such
honesty should seem radical, but in my experience, the pains that come
from getting oneself into the wrong situations are worse.

Developers can also tend to be a prickly lot with a healthy distrust
of dogma. And sometimes the practices of what I might call "strong" or
"pure" TDD can feel like a dogma, especially when delivered in a kind
of hellfire-and-brimstone way a la your average Bob Martin conference
talk. I don't care for the idea that you cannot be considered a
professional developer if you don't practice TDD (and by whose
standard/definition of TDD anyway?).

As I have begin to view it, TDD isn't something you just start doing
and are able to do all of it flawlessly from the get-go. Among the
many concepts and tools you'll need in order to be able to completely
test-drive all parts of a system, there's things like the delicate art
of mocking, how to fake a logged-in user, how to make a unit test
truly isolated, how to mock a collaborator without making the test
useless, what different kinds of tests there are, and a lot of
subjective experience-based intuition about what tools and techniques
are best suited for what kinds of tests and situations. It can all
feel really daunting.

Especially in the context of a web applications, and then especially
when you're working with a framework such as Rails, there's a big
learning curve, one that I think would be better viewed as a long
process of continual improvement. There will be difficulties along the
way, but in the meantime you still have to get work done and people
are still paying you. To say you can't call yourself a professional
until you've already mastered every aspect of TDD feels, frankly,
insultingly elitist. You have to crawl before you can walk before you
can run before you can fly. Doing some testing still beats the pants
off not doing any. I don't think agile development processes was ever
meant to be dogmatic. The processes should be flexible, adaptable,
pragmatic -- just like the code you hope to write when you use TDD to
guide the design.

The problem so far is that too seldom is TDD presented in this way.
Instead it's usually framed as, you're either TDD or you're not. (And
by the way what constitutes TDD is a constantly moving target.) That
way of looking at TDD isn't going to help you or anybody else adopt
it. All it does is feed into your impostor syndrome.

I think it's worth reminding oneself that guys like [Corey
Haines][bawch] took years to get that good at a totally test-driven
style. I mean just watch that video. He's test-driving every little
piece of a Rails application totally outside-in, that is, starting
with the "outermost" layers, what the user sees, the GUI, the views,
and working inward towards the hard candy database center. There are
so many points where he shows techniques for isolating the piece he's
working on, hacks to circumvent the coupling inherent in Rails's
architecture in order to get Rails to let him keep working at an upper
level of the application instead of bombing out with an error about
some lower-level piece not existing yet. Techniques that I just don't
think I would be able to absorb by rote, that he seems to have arrived
at on his own through leaps of intuition and experience that I don't
see myself being able to duplicate. It's quite beautiful but even
though I know he wants to sell these videos, I concluded that this
wasn't going to work for me. We all gotta find our own way, I guess.

That kind of outside-in TDD approach is very much in-vogue right now,
though. And another thing that's very in-vogue at the moment, and a
very useful guiding concept, is the [Rails Testing Pyramid][pyramid].
The tl;dr of it is that your unit tests are the most important, and
should be the type of test you have the most of; and as you look up
the Rails stack each kind of test is slower and more integrated and
rests on the foundation of those below it.

The mosaic of types of tests you might use in a Rails application is
larger than they present in that article, and I think several of them
can be grouped together in the "service tests" category, but you can
see approximately where they would live in the pyramid relative to
each other -- in order starting from the bottom: unit tests, model
tests, controller tests, request tests, helper tests, view tests,
client-side/javascript tests (which might be a whole other pyramid
actually), and finally acceptance tests/features. As you go up the
pyramid in this way too, you find that the tools and techniques become
more advanced in skill, or at least are usually assumed to be and
presented as such: testing literature usually begins with unit tests,
and Rails-oriented testing literature usually begins with what the
Rails community have traditionally _called_ "unit tests," which are
tests at the model layer, which might be integrated with related
models and might be tied to the database, or might be totally isolated
from both, depending on how well you've gotten the hang of the
higher-level skills of mocking and isolating from the database.

But here's what I realized a while ago: when you put the outside-in
approach together with the Rails Testing Pyramid, the implication is
that you are building a pyramid top-first.

Does that even make sense? I mean, I realize we're talking about
software here, not big blocks of stone. It's a metaphor, but I think
there's useful insight to be gotten from metaphors. The Agile and XP
literature [says so too][metaphor].

You've got a pyramid of your _own_ to build: your repertoire of
testing skills. And if building a pyramid it top-first seems
counterintuitive, building all of it at once certainly should.

All your favorite TDD gurus had to have started somewhere -- probably
with a few simple unit or model tests just like most of us probably
did. If you get too attached to an ideal of TDD enlightenment, it can
be discouraging. Better to keep TDD in mind as a guiding principle, an
ideal, then just _start testing_. As you progress, keep a sharp eye on
ways to get _more_ test-driven -- places where more testing, new kinds
of tests, new techniques and tools, can help you be more confident in
your code with more ease. Tackle learning those as you feel yourself
become ready for them.

I recently had this idea for a presentation that would bring
together concepts from [Testivus][testivus] with a sprinkling of
Buddhist philosophy. The saying "[if you meet the Buddha on the road,
kill him][cloudhammer]" seemed prescient, but I wouldn't want to be
misinterpreted as advocating anyone's murder.

I think it can be pretty easy to sell developers on _some_ kind of
automated testing. There's a big win right away in that you can spend
more time writing useful code versus less time filling out the same
web form over and over like a trained monkey. That's already going to
make you more productive and your day more enjoyable. Traditionally
the introduction to testing has been at the unit test level, but I
almost wonder whether it would be better, now that there are good
tools for it, to start from full-stack acceptance tests right away and
go as far with that as you can. You may end up with slow, very
coarse-grained tests this way (and it's for this reason that so many
testing advocates will tell you it's wrong), but at least they will
exercise most of the system and you will catch defects and regressions
you were likely to miss otherwise. Of course any developer/team
working in this way will end up experiencing some pain when the test
uncovers a bug but can't pinpoint where in the system it is
originating; but that's a good pain point to have if it can be turned
into a motivation to dig into those deeper levels of testing.

Convincing developers to test shouldn't be as hard as it looks like
it's been made. It's time to simplify the pitch: Testing is a path to
reduce suffering. You will be learning it forever.

[testivus]: http://www.artima.com/weblogs/viewpost.jsp?thread=194506
[cloudhammer]: http://www.thebigdrumintheskyreligion.com/1/post/2013/10/cloud-hammer.html
[bawch]: http://cleancoders.com/codecast/bawch-episode-1/show
[pyramid]: http://blog.codeclimate.com/blog/2013/10/09/rails-testing-pyramid/
[metaphor]: http://reports-archive.adm.cs.cmu.edu/anon/isri/CMU-ISRI-03-100.pdf
