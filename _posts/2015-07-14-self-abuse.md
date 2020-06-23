---
layout: post
title: "self => abuse, or, the baclava antipattern"
description: "A rant about dependency injection and software design principles"
date: 2015-07-14 17:00
modified: 2015-07-14
tags: [scala, cake, OO, design, dependency-injection]
---

Like many beginning Scala programmers, I was exposed to the
[Cake][cake pattern 1] [Pattern][cake pattern 2] early on and told
that this is how you do dependency injection in Scala. Coming from the
Ruby world I thought it looked like an awfully heavy-weight method,
but of course I didn't know any other way yet. Right away I was placed
on a project in which the Cake pattern was apparently very much in
use, a CMS built on [Play][Play site].

I was tasked with adding a sitemap feature, such that when the path
/sitemap.xml was requested, a sitemap of the site would be rendered.
This seemed straightforward enough. I would just need to pull some
data about the site's currently published pages from the database and
massage it into some [pretty straightforward
XML][sitemap protocol]. This being Play, I
started with a controller, and right away knew I'd need to pull in
whatever code pulls pages from the database, which was pretty easy to
find. I soon found I would also want to pull in a trait for looking at
the contents of the HTTP request. Again, no big deal.

{% highlight scala %}
trait SitemapController extends Controller
    with SiteRequestExtractorComponent
    with PageRepositoryComponent {

  def sitemap = {
    // the magic happens...
    Ok(sitemapXML)
  }
}
{% endhighlight %}

Simple enough, until I tried to compile:

    [error] /Users/chuckhoffman/dev/cms/app/controllers/SitemapController.scala:48: illegal inheritance;
    [error]  self-type controllers.SitemapController.type does not conform to models.page.CmsPageModule's selftype models.page.CmsPageModule with models.auth.UserRepositoryComponent with models.auth.GroupRepositoryComponent with models.approval.VersionApprovalComponent with models.email.EmailServiceComponent
    [error]   with CmsPageModule

Hm. Looks like somebody used that Cake pattern thingy to inject
dependencies into `CmsPageModule` having to do with users, user
"groups," and approval of new content. That probably has to do with
who can do what kind of updating of pages, so even though that isn't
relevant to what I'm after since I only want to _read_ page data, not
update it, it still seems reasonable. I'll just find the right traits
that satisfy those three things -- even though I'm not really _using_
them here -- and add `with`s for them and all should be good.

One little snag, I guess... it turns out that those traits were
"abstract", which meant `grep`ing through the code to find the correct
"implementations," which turned out to be
`UserRepositoryComponentPostgres`, `GroupRepositoryComponentPostgres`,
and `MongoVersionApprovalComponent`. (This is a common sort of thing
to do, since one often wants to mock out the database for tests.) Took
a while to track them down, but eventually I did. So surely I should
be able to just add those three `with`s to the `SitemapController`, add
the `import`s of them to the top of the file, and _now_ we're off and
running, yeah?

    [error] /Users/chuckhoffman/dev/cms/app/controllers/SitemapController.scala:48: illegal inheritance;
    [error]  self-type controllers.SitemapController.type does not conform to models.page.CmsPageModule's selftype models.page.CmsPageModule with models.auth.UserRepositoryComponent with models.auth.GroupRepositoryComponent with models.approval.VersionApprovalComponent with models.email.EmailServiceComponent
    [error]   with CmsPageModule
    [error]        ^
    [error] /Users/chuckhoffman/dev/cms/app/controllers/SitemapController.scala:51: illegal inheritance;
    [error]  self-type controllers.SitemapController.type does not conform to models.approval.MongoVersionApprovalComponent's selftype models.approval.MongoVersionApprovalComponent with models.page.PageModule with models.treasury.TreasuryModule with models.auth.UserRepositoryComponent with models.auth.GroupRepositoryComponent with models.email.EmailServiceComponent with com.banno.utils.TimeProviderComponent
    [error]   with MongoVersionApprovalComponent
    [error]        ^

Oh. Looks like there's now some kind of dependency here being enforced
between pages and something having to do with email; also, versions,
in addition to depending on pages, users, groups, and that same email
thing again, also depend on... treasuries? Huh?

Plainly there's a design problem here because I'm now being forced to
mixin traits having to do with treasuries (these are bank websites)
into a controller that makes a sitemap. At this point, however, I
don't know Scala well enough to pull off the refactoring this needs
with all these self-types in the way. So off I go to find more traits
to mixin to satisfy those self-types. Then those traits turn out to
have self-types forcing mixin of even more traits, and so on.

After a day and a half of work, I finally had a working
`SitemapController.scala` file containing about ten lines of actual
"pulling web pages data from the database" and "building some XML,"
and a couple dozen lines of mostly irrelevant `with`s and `import`s
just so the bastard would compile.

It's Time We Had A Talk About What A "Dependency" is
----------------------------------------------------

Consider this: given two modules (in the general sense of "bunch of
code that travels together", so Scala `trait`s and `object`s, class
instances, Ruby `module`s, and so forth, all apply) A and B, having,
let's say, a dozen functions each, if _one_ of the functions in A
calls _one_ of the functions in B, does that make B a dependency of A?

I'll save you the suspense. No, it does not. Or at least, not that
fact alone. In fact, laying aside the concern that a dozen functions
might be too many for one module anyway, it's clear that the
dependency is between those two _functions_, not the whole modules
they happen to be in. Which suggests that that one function in that
module is responsible for some functionality that may not be all that
relevant to what the other eleven are for. In other words, you have a
case of poor [cohesion][C2 CouplingAndCohesion].

To the extent that we promote the Cake pattern to new Scala
programmers before they have a handle on what good design in Scala
looks like, I believe we're putting the cart before the horse. The
cake pattern, or more generally, cake pattern-inspired self-typing,
takes your bad design and enlists the compiler to help cram it down
others' throats. Couple this with the fact that a lot of new Scala
programmers think that: (1) because I'm writing Scala, I'm doing
functional programming; (2) functional programming is the wave of the
future and OO is on its way out, therefore (3) The past couple decades
of software design thinking, coming as it does from the old OO world,
has no relevance to me; and we get situations like my humble little
sitemap feature.

Cake-patterned code, especially _badly_ cake-patterned code (which has
been the majority of cake-patterned code I've seen, which isn't
surprising given the pattern's complexity -- literally nobody I've
talked to seems to quite completely "get" it, myself included), is
needlessly difficult to refactor, not just because of the high number
of different modules and "components" involved and/or because you have
to very carefully pick apart all the self-types (especially when those
have even more `with`s in them), but also because you frequently find
yourself wanting to move some function A, but need to make sure it can
still call some function B, but B turns out to be very difficult to
_find_, let alone move -- it might be in some trait extended by the
module A is in, or it might be in some trait extended by one of those,
or some trait extended by one of _those_, and so on, to the point
where B could literally be almost anywhere in your project or any
library it uses, and likewise anywhere in there could easily be
completely different functions with the same name. All this just so
that you can get the compiler to beat the next developer that has to
maintain this code over the head with errors if he doesn't extend
certain traits in certain places, despite the fact that the compiler
is already perfectly good at knowing if you're trying to call a
function that isn't in scope.

To make matters worse, most folks' introduction to functional
programming these days still consists of pretty basic Lisp or Haskell
use throwing all your program's functions in one global namespace with
no real modularization. It's no surprise then if they see either the
cake pattern or trait inheritance in general as simply a way of
cramming more stuff into one namespace. Old Rails hands will hear
echoes of [concerns][Corey Haines on Concerns] or more generally, the
Ruby antipattern of "refactoring" by shoving a bunch of
seemingly-sorta-related stuff out of the way into a module (it makes
your files shorter on average, but doesn't necessarily improve your
design any).

Cohesion and coupling,
[separation of concerns][Wikipedia Separation of Concerns],
[connascence][Wikipedia Connascence], even things like
[DCI][Artima DCI], these things still matter in Scala and in any of
today's rising functional or [mostly-functional][Excluded Middle]
programming languages -- or for that matter, any programming language
that gives you the ability to stick related things together, which is
pretty much all the useful ones. (I posit that DCI may be especially
relevant to the Scala world as it seems like it would play nicely with
[anemic models][Debasish on anemic models] based on case classes.)

I hate to keep harping on my Ruby past, but I heartily recommend
[Sandi Metz's book][POODR] _Practical Object-Oriented Design in Ruby_.
Scala is really just kind of like a verbose, statically-typed Ruby
plus pattern matching, when you think about it. Both combine OO and
functional concepts, both have "single-inheritance plus mixins"
multiple-inheritance; heck, even implicit conversions are just a way
better way of doing what [refinements][Avdi on refinements] are trying
to do.

Ultimately though, the cake pattern has the same problem as used to be
pointed to about [those other "patterns"][C2 DesignPatternsBook] when
they were all the rage: people learned the patterns early on, and
started using them everywhere because they thought that was how you're
supposed to program now. They ended up with overly convoluted designs
because they were wedging patterns in where they weren't necessary or
didn't make sense, rather than first understanding the _reasons_ the
patterns existed, reaching for the patterns only when they found
themselves facing the design puzzles the patterns are intended for.

[Play site]: https://www.playframework.com/
[cake pattern 1]: http://jonasboner.com/2008/10/06/real-world-scala-dependency-injection-di/
[cake pattern 2]: http://www.cakesolutions.net/teamblogs/2011/12/19/cake-pattern-in-depth
[sitemap protocol]: http://www.sitemaps.org/protocol.html
[C2 CouplingAndCohesion]: http://c2.com/cgi/wiki?CouplingAndCohesion
[Corey Haines on Concerns]: http://blog.coreyhaines.com/2012/12/why-i-dont-use-activesupportconcern.html
[Wikipedia Separation of Concerns]: https://en.wikipedia.org/wiki/Separation_of_concerns
[Wikipedia Connascence]: https://en.wikipedia.org/wiki/Connascence_(computer_programming)
[Artima DCI]: http://www.artima.com/articles/dci_vision.html
[Excluded Middle]: https://queue.acm.org/detail.cfm?id=2611829
[Debasish on anemic models]: http://debasishg.blogspot.com/2014/05/functional-patterns-in-domain-modeling.html
[POODR]: http://www.poodr.com/
[Avdi on refinements]: http://devblog.avdi.org/2015/05/20/so-whats-the-deal-with-ruby-refinements-anyway/
[C2 DesignPatternsBook]: http://c2.com/cgi/wiki?DesignPatternsBook
