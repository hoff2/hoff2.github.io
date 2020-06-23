---
layout: post
title:  "Counting shared tags (or other commonalities) with a SQL view"
description: "A cool use for views in a rails app"
date: 2013-12-04 12:00
modified: 2013-12-04
tags: [rails, ruby, sql]
---

Occasionally I surprise myself and end up feeling a desire to write
about it and toot my own horn a little bit. What better place to do
that than on a professional blog at least part of the purpose of which
is to show prospective employers or clients that I'm good at stuff?


I'm pretty good, I guess
------------------------

_note: personal background jabber, skip this section at will_

I'm largely self-taught in the area of databases and SQL. The only
course I ever took on the subject was a quarter-length database class,
circa 1999, at Hamilton College (since bought up by Kaplan, I think)
as part of their two-year IT degree program. It used Microsoft Access
and was very beginner-level and I think I might have been out sick on
`join`s day. Later when pursuing my Computer Science degree I avoided
the databases course out of dislike for the professor who taught it;
the alternative course to meet the same requirement had more to do
with text indexing, information theory -- search-engine kind of stuff
-- and oddly enough, the course taught and used an open-source
multi-dimensional hierarchical database and MUMPS compiler developed
by the course's professor (multi-dimensional databases are quite good
at storing and comparing things like, vectors of the occurrences of
hundreds of different words in a bunch of textual articles). So, yes,
I learned MUMPS in college instead of SQL. Actually, you can
[download](http://www.cs.uni.edu/~okane/) and make-install the C++
code for the MUMPS compiler we used yourself, which compiles MUMPS
into C++, if you ever get a wild urge to do such a thing. In fact, I'd
recommend it to my fellow programming language nerds, especially those
interested in old, obscure, or just plain weird languages. At the very
least you'll have a little fun with it; and I believe MUMPS is even
still in use in some corners of the health care industry, so you'd be
picking up a skill that's in some demand yet increasingly difficult to
hire for. (While you're at it, check out Dr. O'Kane's [MUMPS
book](http://amzn.com/1438243383) and his rollicking, action-packed
[novel](http://amzn.com/B001C8VA26).)

At my first real programming job, I started out coding in Actionscript
2.0 but when a particular developer left the company, someone was
needed to take over server-side development in PHP, so I took it upon
myself to learn PHP, and, as it turned out, also ended up needing to
learn SQL and relational databases. I read a PHP book or two and a
whole lot of blogs, but mostly just dove right in to the existing code
and gradually made sense out of it. Eventually I was working back and
forth between Actionscript and PHP pretty regularly. That kind of
pick-it-up-as-needed approach is pretty much how I roll, though it's
hard to explain this kind of adaptability to recruiters who are
looking to basically keyword-match your experience against a job
description, which can be a real drag if you're the type of person who
craves new experiences. When at UNI I had been the kind of student
that made a point of taking the more theoretical computer-sciencey
courses, on the rationale that things like programming languages are
certain to change in the future, but they will most likely continue to
build on the same underlying theory dating at last as far back as good
ol' Alan Turing. I would say that approach has paid off well for me in
the years since. My first boss described me in a LinkedIn endorsement
as being capable of working in multiple programming languages
simultaneously, "something which drives most of us insane."

But I digress (often). Like I said starting out this post, sometimes I
still surprise myself. When I pull off something new or just more
complex than I'm used to, it feels good, and I like to share it, not
just to strut about, but also because I am sure others are out there
trying to solve similar problems, and also to give credit to others
whose work I drew on to arrive at my solution. And like I said, my SQL
skills are largely the product of a few old blog posts and experience
so I was pretty stoked at what I pulled off this week.


The assignment
--------------

I was given the task of populating a "related articles" part of a page
on a news website. Naturally the first thing I thought we needed to
hash out was how the system should conclude that two articles are
related. After some discussion we arrived at this idea: we would score
two articles' relatedness based on:

 * The number of keyword tags they have in common (this was the same
   site using [acts\_as\_taggable\_on][aato github] from which I drew
   [this recent post][aato old post])
 * The number of retailers they have in common (Article HABTM
   Retailer)
 * How close or far apart their `published_at` timestamps are (in
   months)


How this turns out to be slightly difficult
-------------------------------------------

This sounds perfectly reasonable, even like it would be pretty easy to
express in an OO/procedural kind of way in Ruby or any other
mainstream programming language. But once this site gets a long
history of articles, it's likely that looping or `#map`ing through all
of them to work this out is going to get way too time and memory
intensive to keep the site running responsively.

Another alternative is to store relatedness scores in a database table
and update them only when they need to change; we could hook in to
Rails's lifecycle callbacks like `after_save` so that when an article is
created or saved, we insert or update a record for its relatedness to
every other article. That still sounds intensive but we could at least
kick off a background worker to handle it. However, I got the feeling
that there was potential for errors caused by overlooking some event
that would warrant recalculating this table, or missing some pairs.

And there was still another wrinkle to work out: the relatedness
scores pertain to pairs of articles, and those pairs should be
considered un-ordered: the concept of article A's relatedness to
article B is identical to B's relatedness to A. I don't know if any
databases have an unordered tuple data type and even if they did
whether ActiveRecord would know how to use it. It seems wasteful and
error-prone to maintain redundant records so as to have the pairings
both ways around. Googling about for good ways to represent a
symmetrical matrix in a SQL database didn't bear much fruit. So it
would probably be best to enforce an ordering ("always put the article
with the lower ID first" seems reasonable). But then this means to
look up related articles, we need to find the current article's ID in
one of _two_ association columns, rather than just one, and then use
the _other_ column to find the related article. I'm pretty sure
ActiveRecord doesn't have a way to express this kind of thing as an
association. Which is too bad, because ideally, if possible, we'd like
to get the relatedness scores and related articles in the form of a
`Relation` so that we can chain other operations like `#limit` or
`#order` onto it. (Possibly we could write it as a `scope` with a
lambda and give the model a method that passes `self.id` to that, but
I'm still not sure we would get a `Relation` rather than an `Array`.
The point at which ActiveRecord's magic decides to convert from one to
the other is something I find myself constantly guessing on, guessing
wrong, and getting confused and annoyed trying to come up with a
workaround.) But so it goes.

Any way we look at this, it looks like we're going to be stuck writing
some pretty serious SQL "by hand".

I'm not going to show my whole solution here, but you probably don't
need all of it anyway. I think the most useful bit of it to share is
the shared-tags calculation.


Counting shared tags in SQL
---------------------------

acts\_as\_taggable\_on has some methods for matching any (or all) of
the tags on a list, and versions of this that are aware of tag
contexts (the gem supports giving things different kinds/contexts of
tags, which I'm not going into here but it's a cool feature). So
obviously you can call `#tagged_with` using an Article's tag list to
get Articles that share tags with it, but the documentation doesn't
mention anything about ordering the results according to how many tags
are matched, or even finding out that number. Well, here's the SQL
query I arrived at that uses acts\_as\_taggable\_on's `taggings` table
to build a list of article pairs and counts of their shared tags. One
nifty thing about it is that it involves joining a table to itself. To
do this, you have to alias the tables so that you can specify which
side of the join you mean when specifying columns, otherwise you'll
either get an ambiguous column name error or you'll just get confused.
You'll see I've also added a condition in the join that the "first" id
be lower than the "second," forcing an ordering to the ID pairs so as
to eliminate duplicate/reversed-order rows and also eliminate
comparing any article with itself, since we don't care to consider an
article related to itself. (Also, the way this is written Article
pairings with no shared tags won't be returned at all. Maybe try a
`left join` if you want that.)

{% highlight sql %}
select
  first.taggable_id as first_article_id,
  second.taggable_id as second_article_id,
  count(first.tag_id) as shared_tags
from taggings as first
join taggings as second
on
  first.tag_id = second.tag_id and
  first.taggable_type = second.taggable_type and
  first.taggable_id < second.taggable_id
where first.taggable_type = 'Article'
group by first_article_id, second_article_id
{% endhighlight %}

Add a `and first_article_id = 23 or second_article_id = 23` to the
`where` clause here and you'll get just the rows pertaining to article
23. Add an `order by shared_tags desc` and the rows will come back
with the highest shared-tag-counts, the "most related," at the top. If
you're looking to know the number of shared acts\_as\_taggable\_on
tags among your articles or whatever other model you have, here you
are.


Building a leaning tower of SQL
-------------------------------

So, for the other two relatedness factors, I did a similar query to
this against the `articles_retailers` table to count shared retailers,
and another on `articles` to compute the number of months apart that
pairs of articles were published to the site. Each query used the same
"first id less than second id" constraint. Then I pulled the three
queries together as subqueries of one larger query, joining them by
`first_article_id` and `second_article_id`, and added a calculated
column whose value was the shared tags count plus the shared retailers
count minus the months-apart count and call this their `score` -- a
heuristic, arbitrary measure of "how related" each pairing of articles
is. (The `coalesce` function came in mighty handy here. Despite its
esoteric-sounding name, all it does is exchange a null value for
something else you specify, like you might do with `||` in Ruby -- so
`coalesce(shared_tags, 0)` returns 0 if `shared_tags` is null, or
otherwise returns whatever `shared_tags` is, for example.)

As you are probably picturing in your head, the resulting master
relatedness-score query is _huge_. It took me a good couple hours at a
MySQL command-line prompt composing the subqueries and overall query a
little bit at a time. It felt _awesome_. But still: the result was one
seriously big glob of SQL. (Incidentally iTerm2 acted up in a _really_
weird way when I tried pasting these large blocks of code into it, but
not when I was SSHed into a remote server; if this rings a bell to
you, drop me a line.) I'm going to spare you the eye-bleeding caused
by seeing the whole thing. You're going to drop _that_ big nasty thing
in the middle of some ActiveRecord model? Yikes!


Views to the rescue
-------------------

In a forum thread where I was looking for help on the implementation
of all this, [Frank Rietta][rietta] suggested I consider using a
database view. To be perfectly honest, I hadn't used a view in years,
if ever. I didn't even think MySQL had them (yes, I'm using MySQL,
don't judge) -- maybe some older version I used in the past didn't and
they've been added since? At first I wasn't sure how this could help
me, but then Frank wrote [this excellent blog post][rietta on views]
on the subject. I read it, and the more I thought about it, the better
the idea sounded.

Basically, a view acts like a regular database table, at least when it
comes to querying it with a `select`. But underneath it's based on
some query you come up with of other tables and views. You can't write
to it, but it provides you with a different "view" of your data by
what I would describe as "abstracting a query." And because the view
can be read from like any other table, it can also act as the table
behind an ActiveRecord model (at least, until you try to `#save` to
it). Go read [Frank's post][rietta on views] so I don't have to recap
it here. You'll be glad you did.

The great advantage of using a view to hold the relatedness scoring is
that I don't have to think about writing Ruby code to maintain the
table of relatedness scores, I don't have to think about background
jobs or hooking into ActiveRecord lifecycle callbacks to maintain the
data or any of that -- the database itself keeps this "table" updated.
Any time the tables it depends on change, it changes right along with
them automatically. Plus it gets the big hairy SQL query out of my
Ruby code where it won't distract or confuse anyone; and it handles
the issue of making sure `first_article_id` is always lower than
`second_article_id` because that's expressed right in the query it's
based on.

So that settles it, I create a view out of my big relatedness-scoring
query and an ActiveRecord model over top of it! Only one problem, and
it turned out to be pretty minor, but as I mentioned, my big
relatedness query involved a join over three subqueries. Turns out
that in MySQL, views can't have subqueries. Perhaps they can in other
database engines, I would not be surprised, but not in MySQL. The
workaround for this is to create views for the subqueries and query
those views. Honestly that probably makes the SQL read more easily
anyway. On the other hand, I ended up creating four views. That was
definitely the longest Rails migration I have ever written, by far.


The models and other miscellaneous thoughts
-------------------------------------------

So, now I have a table called `article_relations` that contains pairs
of Article id's and their relatedness scores, I can give it a model
like this:

{% highlight ruby %}
class ArticleRelation < ActiveRecord::Base
  belongs_to :first_article,  class_name: 'Article'
  belongs_to :second_article, class_name: 'Article'

  def other_article(source)
    [first_article, second_article].find{|a| a != source}
  end

  def readonly?
    true
  end
end
{% endhighlight %}

And give the Article model a couple methods like this:

{% highlight ruby %}
  def article_relations
    ArticleRelation.where(
      'first_article_id = ? or second_article_id = ?', id, id).order('score desc')
  end

  def related_articles
    article_relations.map{|r| r.other_article(self)}
  end
{% endhighlight %}

Or something to this effect. You'll likely want to have your view only
contain records where the score is above 0, for instance, or give the
above methods an optional parameter to use in a `limit` so you can
limit the number of related articles you show.

Which reminds me, speaking of `#limit`... as I alluded to before, it
would be great if I could do things like
`@article.related_articles.limit(10)` here but I can't. This bugs me a
little bit, because it means that some of my queries to the Article
class are going to call `#limit` and others will have to pass the
limit as a parameter, or slice the array like `[0..9]` or something,
so I have code where doing the "same" thing reads completely
differently. (I am also unfortunate enough to still be working with
Rails 2 regularly, where `limit` goes in an options hash. It appears
if you try that syntax in Rails 3, it just ignores it.) There are
other gems like [punching_bag][punching_bag github] where this itches
at me a little as well (not to mention, I'd like to be able to give my
model a method or `scope` with a name more appropriate to my domain
such as `popular` or `hot` and have that delegate to `most_hit`). I
think this might just be a product of the usual leakiness of ORM
abstractions and I'll just have to get over it.

One caveat that should be pointed out is that Rails's generating of
`schema.rb` doesn't handle views "properly" and probably can't be made
to when you think about it or depending on what you think the proper
thing for it to do would be. Rails will dump the structure of your
views out as regular tables, so if you use `rake db:schema:load`
you'll get tables rather than views with all their cool magic. At this
point it's probably a good idea to uncomment that
`config.active_record.schema_format = :sql` line in your
`application.rb` configuration file, which will make `rake db:migrate`
spit out a `structure.sql` file instead of `schema.rb`, and get rid of
`schema.rb` altogether.

Another thing worth considering, depending on the complexity of your
view(s), is whether to make them
[materialized views][materialized wikipedia]. This is a view that's
backed by a physical table that gets updated as needed. It's more
efficient to query but a little slower to update so the effects of a
change to one of the tables it depends on might not be reflected right
away, but this may be a worthwhile trade-off to make.

Join me next time when I talk about technical debt or something like
that.

[aato github]: https://github.com/mbleigh/acts-as-taggable-on
[aato old post]: /2013/11/09/acts_as_taggable_on_active_admin_select2.html
[rietta]: http://rietta.com/
[rietta on views]: http://blog.rietta.com/blog/2013/11/28/rails-and-sql-views-for-a-report/
[punching_bag github]: https://github.com/biola/punching_bag
[materialized wikipedia]: https://en.wikipedia.org/wiki/Materialized_view
