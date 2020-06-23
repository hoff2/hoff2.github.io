---
layout: post
title: "Ending the indentation argument"
date: 2017-11-01 21:25:02 -0500
modified: 2017-11-01 21:25:02 -0500
tags: [code,style]
---

![original dank memeage](/images/line-break-after.jpg)

I'm just going to come out and say it. I hate parameter aligning and I think it
looks like crap. Especially for functions with long names. Nothing should be
indented that far in the first place, but so much the less so when it's just
suddenly shunted over 20+ spaces rather than the product of a series of
increasingly indented lines.

This is really just an extension of my distaste for long lines. They tire my
eyes out. There is [science][1] about this. It's why newspapers and magazines
are printed in columns. But also, when reading code, I should have to use my
horizontal scroll bar as little as possible. I used to be hardcore about an 80
column limit but with some programming languages that gets very restricting, and
then there are the matters of long names, literal strings, or long complex type
annotations, second parameter lists, implicits, and so on. There should probably
be some maximum to which only certain exceptions are allowed but I don't have a
definite number offhand. But if I have to scroll horizontally to even _see_ the
arguments you're passing instead of thinking I'm looking at blank lines, I'm
going to be annoyed. And if I can't fit your code within the width of my screen,
you should really re-evaluate your life choices. Preferably I should be able to
read it fairly easily when I have two emacs buffers or Intellij editors up
side-by-side, subject to choice of a reasonable font size.

This is one of those dumb holy-war issues. People are irrationally attached to
their coding styles, which themselves are a set of irrational aesthetic
preferences onto which people subconsciously hang ideas about their identity and
artistry. I think this is mostly a product of insecurity. As for
parameter-aligning, as far as I can guess, it's an idea people get from Lisp,
and being a Lispy thing, it makes people feel smart. (Programmers do an awful
lot of terrible things for that reason, like writing needlessly complex code
where they should be abstracting something so it's more readable, or
gratuitously using esoteric language features or idioms. I used to do a hell of
a lot of this kind of thing.) Well a lot of ideas people have gotten from Lisp
have been bad ideas, and this would be one of them.

If your argument/parameter list is long enough that you don't want to put it all
on the same line with the function name and whatever else, it's fine to split it
over more lines. I quite like one parameter per line, especially with case
classes, but if the names are short I don't mind grouping a few together on the
same line either -- more commonly so for arguments at a function call than for
parameters at the function declaration. But you should usually start it by
line-breaking after the opening paren of the list and then just indent it a
normal indentation amount. It still reflects that you're continuing from the
previous line, but now you won't have to realign them all everywhere if you
change the function's name. People seem to feel weird about line-breaking after
an opening paren even though they have no qualms about doing so after an opening
curly. Well, if this was Lisp they would _all_ be parens, so stop worrying.

There's something to be said for having consistent style in a codebase that's
been worked on by several people, and getting it right by a standard should be
as easy to do as possible; ideally, it should be possible to
do [automatically][2] using something like [scalafmt][3] instead of leaving it
up to the capricious whims and error-proneness of humans.

An indentation scheme should reflect code structure, not have to be too fiddly
to accommodate changes, and easy to enforce with a static analyzer. It should
not take up an inordinate amount of a coder's time. Thus it is I propose a
simple scheme that I do not strictly follow myself as yet, but which I think has
quite a bit of potential. Indentation should be a number of spaces (or this
works with tabs too, but not with mixing them together, which you should never
do anyway) determined by a simple linear function _y = mx + b_, where _b_ is
some constant indentation level started with (probably 0 in most cases); _m_,
also a constant, is your tab width (two spaces, or three, or whatever is common
idiom of the language or decided on by team, project, or company); and _x_, the
variable, is the number of expression delimiters (i.e. parens, brackets,
begin/end pairs) left unclosed as of the start of the line. (This doesn't
include things that delimit literals, such as the quotes around strings.)

This does have some potential to look a little odd in places where x is more
than one greater than on the preceding line, and it doesn't account for `case`
or `if` branches that don't have brackets around them (consider them to have
imaginary brackets maybe? Some companies' standards just say to always use the
brackets), but generally it allows you in such cases to put the closing
delimiters on separate lines and reflect the depth of structure they are closing
without having any of them end up at the same indentation level. Closing
delimiters that are at the start of a line should end up aligned with the start
of the line they were opened on pretty easily this way.

That's all I have on that, but I'm interested in feedback. Naturally, none of
this applies to Lisp dialects which tend to have their own established
conventions and I imagine Lispers would have all sorts of reasons for hating
this idea, but I don't much care what those grey neckbeards think. (Maybe
Clojure people would be more willing to give it a try but I don't promise it
will look good, I haven't tried it in any Lispy syntaxen, which as we all know
are weird anyway.) What I like about this method is its simplicity and relative
lack of special cases or aesthetic judgement calls, which make it ideal for an
automatic formatter.

[1]: http://usabilitynews.org/the-effects-of-line-length-on-reading-online-news/
[2]: https://medium.freecodecamp.org/why-robots-should-format-our-code-159fd06d17f7
[3]: http://scalameta.org/scalafmt/
