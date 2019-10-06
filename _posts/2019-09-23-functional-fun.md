---
layout: post
title:  "A fun tidbit of functional programming"
date: 2019-10-06
---

The problem: You've got a bunch of text replacements you'd like to make in
strings. Practical application, if you need one: You're generating messages to
be read by a speech-to-text system and there are certain words or names that
come up often that it doesn't pronounce very well, so you'd like to replace them
with alternate "phonetic" spellings.

This example is in Javascript but the concepts are broadly applicable. The list
of replacements you want to make is stored in key-value pairs, the key being
what to replace and the value being what to replace it with: we have them in a
Javascript object. Your favorite language's equivalent might be a `Hash`, a
`Dictionary`, a `Map<String, String>`, etc.

Here's a totally reasonable imperative-OO solution one might come up with:[^1]

{% highlight javascript %}
class MessageTransformer {
  constructor(replacements) {
    this.replacements = replacements;
  }

  transform(text) {
    for (let str in this.replacements) {
      text = input.replace(
        RegExp(`\\b${str}\\b`, 'gi'),
        this.replacements[str]);
    }
    return text;
  }
}
{% endhighlight %}


[//]: # TODO: reformat footnotes once github pages supports jekyll 4 and kramdown 2.
[^1]:  The only thing slightly esoteric here is maybe the regular expression stuff. `\b` is just a regex thing that matches a "boundary", that is, a word boundary, since we want to replace whole words; it matches the beginning or end of the string, or of a line, or of a word. The flags `gi` stand for "global" (replace all occurrences, not just the first one found) and "insensitive" (to letter case).

To use this you'd create a `MessageTransformer` instance during the
initialization of your program like `const transformer = new
MessageTransformer(replacements)` and then use it to transform your message like
`const fixedMessage = transformer.transform(message)`.

Now, I have a slightly funny history with functional programming. In college I
learned some Scheme and thought FP was just about the coolest thing ever, but
almost nobody was using it in industry in those days, Java didn't even have
lambdas yet. Then I got a job where I was writing quite a bit of Actionscript
and upon discovering that, being a ECMAscript dialect, it has closures, I went
on to write some of the worst wannabe-Lisp-in-Actionscript ever, and had great
fun doing it. More recently however, I was traumatized at a previous workplace
by "pure" FP Scala. There's a great community to hang out if you really want to
get your impostor syndrome fired up. I now require trigger warnings for
terminology like "kleisli arrow" and "final tagless." I'm undergoing a long slow
recovery. But I got some good things out of it, like an appreciation for
immutability. And looking at this solution made that particular spot in my brain
itch a little: we keep reassigning new values to the `text` variable (some
languages won't even let you do this to function parameters, not that you can't
get around it easily enough with a local variable). And then this came to me --
or rather the idea for it did; it took some work to get the actual code right:

{% highlight javascript %}
function messageTransformer(replacements) {
  return Object.keys(replacements).map(str =>
    text => text.replace(
      RegExp(`\\b${str}\\b`, 'ig'),
      replacements[str])
  ).reduce((acc, f) => text => f(acc(text)), _ => _);
}
{% endhighlight %}

There's actually two significant and completely independent refactors applied
here, relative to the first version. First is that I moved away from using a
class. The function accepts your replacements object as a parameter, analogous
to the constructor, and returns a function that does the transformations,
analogous to the method. In my head I think of this as the "objects are just a
poor-man's closures/closures are just a poor-man's objects" pattern, after
something I heard in that class where I learned Scheme. It could probably use a
shorter name. It changes the usage syntax a bit: to initialize it, you'd go
`const transform = messageTransformer(replacements)` and then use it like `const
fixedMessage = transform(message)`, or if you want to do both all in one go,
`const fixedMessage = messageTransformer(replacements)(message)`. This is
potentially a pretty handy pattern you can use anytime you might create a class
with only one public method.

The second and weirder refactor is that I replaced looping through the
replacements and assigning the result of performing each replacement back to the
variable with... something else. It has two parts and they are a "map" and a
"reduce". You might have heard of MapReduce during the Big Data craze a few
years back. This is literally the same concept, but with small data, and turns
out it's a really common FP pattern. "Map" can mean taking a collection of
something and turning it into a collection of something else by applying the
same function to each element[^2]; "reduce" would then mean taking that
collection and reducing it down to one value, for example summing a list of
numbers, or even just counting how many things are in the list.

[^2]: Technically the "context" in which a map occurs doesn't have to be that it's a collection, there are lots of other uses; but collections are commonly most people's first introduction to some of these FP concepts. To give you some idea what other things map can operate on, the `then` method of a `Promise` is also basically a map; you give it a function that accepts `A` and returns `B`, and it uses it to turn a `Promise` with `A` in it into a `Promise` with `B` in it.

In the map stage, each item in `replacements` (or more precisely, the array if
`replacements`'s keys) is mapped to a function that performs that replacement.
By the end of it we have an array of functions. Each function in that array is
analogous to one iteration of the `for` loop in the first version.

The reduce stage rolls all those functions into one single function by "folding"
function composition over it. This is the conceptually densest part of this
whole thing, but I'll try my best. Imperatively speaking, it sort of loops
through the array of functions and adds them all together, so that by the end we
have a kind of chain of functions that the text gets piped through, but all in
one function. How does this work?

Any time you have some function that accepts two parameters of some type and
returns something of that same type -- its type signature is of the form `(A, A)
=> A` -- you can use that function over a whole _list_ of `A`s by using what's
called reducing or folding; it's done by successively applying that function to
each item in the collection and the "so far" value. To analogize to the example
of summing a list of numbers, if you were doing it with a for-loop, each time
through the loop you add the next number in the list to the sum so far; to do
the same thing with `reduce`, you just give it a function that does that, `(x,
y) => x + y`. Given a function that adds two numbers, `reduce` can use it to add
a whole bunch of numbers. Give `reduce` a function that returns the larger of
two numbers and it can use it to find the largest of several numbers. Give
`reduce` a function that just returns 1 and you'll end up with a count of how
many numbers were in the list. And so on.

Function composition is what it's called when you make a new function out of two
functions -- all this new function has to do is pass its argument to one of the
two functions and then pass the result of that on to the other one. This is
especially easy to do with two functions where their parameters and return
values are all the same type -- that is, they both have a type signature of the
form `B => B` (the actual letter doesn't matter, but I don't want to get too
confusing by re-using `A`). If you have two such functions `f` and `g`, the
composition of them is `x => g(f(x))`. You can write a function to do it:
`compose(f, g) = x => f(g(x))`. Anything about this sound familiar?

Yes! You can "compose" the concepts of the previous two paragraphs! A function
that accepts two functions and returns the same kind of function, like our
`compose`, is yet another example of a function of the form `(A, A) => A` -- it
just so happens that its parameters are functions too -- `A = B => B` -- making
function composition _yet another_ thing we can use in a `reduce`! And that's
exactly what we've done in the `reduce` above: `(acc, f) => text =>
f(acc(text))`, that is, given two functions `acc` and `f`, return a function
that takes `text` and returns `f(acc(text))`. Since we're working with a
collection of `B => B` functions (where `B` means strings in our example), with
function composition we can roll them all up into one single `B => B` function.

Oh, but there's still that other weird looking parameter I've been glossing
over, `_ => _`. That's just a function that takes one parameter and just returns
it. `_` is a valid Javascript identifier, so this is just a little style choice
on my part. But why does this need to be here? Because a reduce needs a starting
value. In yet another analogy to summing a list of numbers with a loop: you need
to initialize the sum to 0 before starting the loop. `_ => _` is actually a
pretty special function to FP heads: they call it the "identity function". It
comes in handy for just this sort of thing, because the identity function is to
function composition what 0 is to adding numbers. There's a scary FP terminology
for this that's hopefully about to be a bit less scary if I can explain it well
enough.

It's a concept borrowed from abstract algebra, a term for things that you can
put two of together and get the same kind of thing, and hence, things you can
reduce with: they're called _monoids_. For example, to speak yet again of
summing numbers, they say in algebra that "the set of real numbers under
addition forms a monoid." A monoid is made up of a set, analogous to a type in
programming; a binary operation on that set ("binary" in the sense that it has
two operands), analogous to our `(A, A) => A`; and an _identity element_. The
identity element is that member of `A` where, when used in the binary operation,
the result is equal to the other argument -- like how in real numbers, `x + 0 ==
0 + x == x`.[^3] In the same way, functions like `B => B` form a monoid under
function-composition having the identity function, often called `i`, as its
identity element, because composing some `f` with `i` gets you, for all
practical purposes, the same function: `i(f(x)) == f(i(x)) == f(x)`.[^4]

[^3]: There's a whole lot of other nuances I'm glossing over that you're likely to run into and understand eventually. For instance, there is such a thing as a monoid _without_ an identity element, except it's called a _semigroup_ (In fact I've made reference to one earlier, I'll leave it as a challenge for the reader to spot it). And sometimes the order of arguments to the operation matters; when it doesn't, you have a _commutative_ monoid, like with numbers under addition, but sometimes it does, like with strings under concatenation, and in some of those type of cases you have elements that are only a _left identity_ or _right identity_... it's a whole deep and fascinating branch of mathematics that's totally worth exploring further but I'm trying to keep this article from going off the rails, and this footnote is mostly here for the benefit of the Well-Actually Brigade.

[^4]: I'm intentionally using notation here aimed at programmers rather than proper mathematical notation, don't @ me.

Anyway, to get back to our little example, I thought this functional version
turned out pretty slick, it's a neat way to conceptualize the problem, the code
is really succinct and clean, and there's no mutability to think about. I
decided to write up a post about it for the benefit of functional programming
fans who might appreciate it the way I do, and for folks who are in the early
stages of exploring functional programming for whom all this explanation might
be educational.

Now, I hear a couple of you in the back of the room there grumbling that this
implementation is probably terrible on memory usage. There's something to that.
If your list of replacements is big enough (and that would probably have to be
pretty big), this thing could overflow the stack. It's a common issue with
highly functional programming style, because you build just about everything out
of functions, and function calls use stack space. That said, you know what they
say about micro-optimizations. And besides, that sort of thing is quite
dependent on the language implementation. If nothing else, this was a cool
illustration of the power of functional abstractions.

Implementations for pure functional languages, and others that make a priority
of enabling use of functional features, have ways of dealing with this stack
usage issue. You've probably heard of the optimization of tail-recursion, which
can be generalized to tail-calls. This is when a function calls another function
as the last thing it does before itself returning to its caller. If call A's
last thing to do is to call function B (which in the case of recursion is the
same function as A), and has no further work to do afterwards, then as soon as
B's stack frame is popped off, A's will be too, so there wasn't much point in
keeping the A stack frame around. Tail-call optimization basically consists of
popping off that stack frame pre-emptively. When this can be done for a
recursive function, the resulting memory usage is essentially the same as for
having used a loop. Downsides can include losing debugging information (think
stack traces). There's also a techique called trampolining that I don't
understand very well except that it somehow results in the memory allocation
happening on the heap instead.

Anyway, hope this was interesting.
