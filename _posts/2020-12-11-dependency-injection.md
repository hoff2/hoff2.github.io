---
layout: post
title: "Notes on Dependency Injection"
tags: [Dependency Injection]
---

 > Recently I was given some job interview questions to prepare for. I decided
 > to try writing my thoughts on the subjects. I had fun with it so I decided to
 > clean them up a bit and make them blog posts.

Q: "Can you explain what inversion of control or dependency injection is and
what benefit it provides?"

Dependency Injection/Inversion Of Control is a concept that came up in the
theory around object-oriented programming some years back. The general idea is,
you have some procedure in your program that needs to get at some data values,
system resources, and other procedures to be able to do its job. When or how you
specify all these things are a matter of how you design your code. Given an OO
programming language, this procedure is probably a method on some class, so some
things may have been specified to the objects' constructor; others might be
given as arguments to the method call. Or they may have been calculated,
provided through setter methods, or constructed from other things in the
meantime. The constructor is itself a method with parameters, whose job is to
give you a new instance of this class, and those parameters can technically be
anything or nothing, just like any other method. In between the constructor,
other setup of state done beforehand within the class scope, and parameters,
eventually the method has everything it needs if it is to work.

You find that in purely Functional Programming circles you rarely hear
dependency injection talked about, let alone stressed about, the way it has in
OO programming. At a basic level one could say that this because in these
languages everything is made out of pure functions, so technically the only way
to get things into a function is through its parameters, so you don't have all
these choices to weigh. This might sound like a nightmare if you care much about
functions having a lot of parameters. But then that's what closures are for,
[which are how FP "does" objects](/2019-10-06-functional-fun/), as it turns out,
and out of them you also get currying and monads.

In the early days of object orientation, as its dominance in industry was new,
many design principles, patterns, and practices we've since come to take for
granted were yet to grow. Much of the field was still thinking in Procedural or
Structured Programming terms and was still figuring out how to use the tool of
OO _well_. This is normal. I've since seen it happen with Actors and
Microservices and arguably even Functional Programming, with three-quarters of a
century of history behind it, is still lacking in some of this area.

Object Oriented programming languages' native facility for invoking an object is
to call a class constructor. Often there is a special language keyword to do
this, such as `new`. If you need some kind of object, this is supposedly how you
get it. If that constructor needs some other objects though, what does it do?
It's not entirely unreasonable to think that that constructor would go off and
call other constructors and so people did that sort of thing a lot.

However, this started to lead to some nasty smells. One would find oneself
writing constructors that need a whole lot of parameters, even if it's just so
it can pass most of those parameters on to other constructors; writing out the
very long calls to those many-parametered constructors, "threading through"
parameters from one class to another to another, and probably getting parameters
in the wrong order several times and other prosaic human errors that happen when
you're dealing with complicated code. To make matters worse, you ended up with
classes and methods that are bound to specific context-dependent things in your
application and don't easily generalize to other circumstances; OO's promise of
reusable code fails to come through. This got especially hairy with the growing
popularity of unit testing and test-driven development -- you would try to set
up a test suite for some class in your code and find that you had to build out a
whole hairball of stuff just to set up an instance to test on, and then someone
would tell you that if you were doing that then it wasn't true "unit" testing,
and you'd throw up your hands and go back to your old ways.

Eventually some genius remembered that we can pass _objects_ along as parameters
too, so we could just build those downstream dependencies ahead of time and pass
them in. "Injecting" your dependencies' dependencies into them, instead of just
letting your dependencies build all their own dependencies, this "inversion" of
the "control" over dependencies, passed for enough of a mindshift to make it a
buzzword.

Indeed, it was considered such a mindshift that people decided they couldn't
handle the responsibility themselves and needed to have frameworks called
Dependency Injection "Containers" to do the heavy lifting. It was `new`'s fault
for letting us call it wherever we want; instead we should let this container
use reflection and/or big XML configuration files to find all the right things
to plug into all the constructors for us so that wherever we wrote methods,
whatever they needed could just be there. After all, "dependency resolution" was
something of a solved problem in the realm of the _installation_ of software. We
had package systems for Linux distros, as well as those to manage library code
our projects depend on. They build a data representation of what depends on
what, and what other whats those whats depend on, on down to the whats that
don't depend on any other whats, and go and find the right versions of the right
things and put them where they're needed.

DI/IoC Containers caught on widely in the worlds of enterprise Java and C#. This
way of handling dependencies within a project had apparent time-saving benefits
due to what it lets you avoid thinking about, against the tradeoff that it gives
you an incentive to not think about those things. When you write a class you
simply stick on the annotation that plugs it into the DI container, and now you
don't have to think much about how to structure dependencies.

In practice, how this often plays out is that if you're coding in some new
functionality and want some dependency the class doesn't already have in scope,
you just add it to the constructor and keep going. Heck, often the IDE will just
do it for you with a keyboard shortcut. You don't care how long that constructor
signature gets because you never have to write a call to it anyway. The
constructor's signatures get bigger and bigger and the import lists at the top
of the files get longer and longer and your unit tests have to set up more and
more mocks but because all this grew a little at a time you've stopped noticing
it, like the people on Hoarders who are immune to the smell of their own homes.
Without applying some design discipline, at the end of the day, this state of
affairs is not only hardly better than just cramming a lot of stuff into a
global namespace, it's worse because it fills your code with boilerplate, and
your classes lose all cohesion or real meaning beyond being arbitrary bags of
dependencies. What's a separation of concerns?

In Scala's early days of aiming to be a "better Java", they tried to improve on
this with a scoping feature called `implicit` that ended up replicating similar
problems in the form of a certain crime against humanity called the Cake
Pattern. Implicits came to be widely hated, though maybe not always fairly; they
ended up being repurposed to build out an FP concept called typeclasses, which
sound awesome until you realize they're kind of just interfaces.

DI/IoC containers continue to be popular, especially in the context of
opinionated-architecture application frameworks in popular enterprise
platforms/languages, and I'm able to work with them. When it's up to me,
however, I prefer to use basic constructor- or setter-based DI methods in a
manner influenced by things like hexagonal/ports-and-adapters or DCI
architectures. Even then, messes get made.

 > Got a programming topic you'd like me to rant on? Send it to hoff2 at HEY dot
 > com.
