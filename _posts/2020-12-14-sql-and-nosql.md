---
layout: post
title: "SQL and NoSQL"
tags: [databases, SQL, NoSQL]
---

 > Recently I was given some job interview questions to prepare for. I decided
 > to try writing my thoughts on the subjects. I had fun with it so I decided to
 > clean them up a bit and make them blog posts. One thing I noticed was that
 > when writing, I didn't have so much a name let alone a mental picture of a
 > hypothetical senior engineer I'd be interviewing with and seemed instead to
 > be writing for the recruiter I'd been in contact with as intended audience. I
 > was explaining concepts less to impress someone and more to actually teach.
 > Therefore I hope these posts are informative to someone.

Q: When might you want to use a NoSQL database instead of SQL?

Generally speaking, a database is any store of data and the means to find and
use what is in it, which may include a query language such as SQL. The file
system(s) used by the operating system on your computer is also a database, and
you might even think of file names/paths as part of a query language for it. A
file system has metadata for keeping track of where the bits that are called by
a given filename in a given folder are physically kept on the disk (or whatever
storage medium you might be abstractly referring to as a "disk"), so as to help
the software to find, use, add, and modify files in ways a user might request.

These same factors also define other kinds of databases: a way of organizing
data in some storage medium; facilities for accessing, calculating from, adding
to, and modifying it; and metadata (such as indexes) to support these
facilities. Various database architectures have different ways of implementing
these things that can support different logical models of data access to varying
degrees of speed and space efficiency. 

The term "NoSQL" is interesting because I suspect that it may be highlighting
the wrong variable and thereby misleading. The defining factors of NoSQL
databases as opposed to what users of this term mean by SQL databases seems to
me to have more to do with the underlying architecture and features of a
database engine, than with the SQL query language itself. But SQL is closely
correlated to what are called relational databases, a model which has dominated
the field of databases, in the sense of which most people think of the term
"database", for a number of years now.

Relational databases provide a logical model of data arranged in tables, the
rows being data records, containing fields (arranged in columns) that hold the
component data of the records. There are keys to uniquely identify particular
records, foreign keys to express _relationships_ between records, be they in the
same table or different, and indexes to help the system locate records by keys.
It's all fairly intuitive to folks who know their way around spreadsheets and
also quite logically flexible. Relational databases almost universally offer an
SQL interface, but I have also seen SQL-like languages offered for other kinds
of data stores such as ksqldb for Kafka, and proprietary specialized dialects
like this one thing Salesforce has that I can't remember the name of right now.
They have become the default choices of database to back most applications that
need something they can't get from, say, sticking stuff in files; to the degree
that the term "database" has become nearly synonymous with them, and the
occupation of "database administrator" likewise synonymous with someone skilled
at working with SQL, various extensions of SQL, and relational database
solutions in general or specific.

Relational databases have been so dominant for so long for good reason. They are
good general-purpose databases and a lot of work over a long time has gone into
making them good. They give you facilities to be able to do just about anything
with the data they contain that you might conceivably dream up, almost as
quickly as you can dream it up. You can put lots of data in an SQL database and
get a lot out functionality of it easily.  Right now I'd still say if you're
building a new product, there's almost no reason not to at least start off with
one of these databases even if you're keeping your options open in the longer
term. Free and open-source solutions like PostgreSQL are competitive with
commercial offerings like Microsoft SQL or Oracle, and at small scale and/or
early stages of a product you can even go with something easy and
low-maintenance like MySQL or SQLite. You can run them on your own laptop and do
all the nasty things to them you could ever want to try as you develop a
product.

But yeah, this is the hegemony that birthed the NoSQL meme. Some tech companies
were getting big doing some innovative stuff and found themselves reaching
performance and scale needs that relational databases weren't up for. Being
pretty good at a lot of things sometimes leaves you coming up short on very
specific things, especially things that were rarer when the system was initially
designed. Everything's a trade-off. Demand increased for distributed and
parallel computing to handle high load, and relational databases often weren't
the best at scaling out. Replication exists but it's pretty meh, and sharding is
helpful for some things but can be difficult to get right. Other kinds of
databases needed to be found or built to meet new needs.

The NoSQL movement may be little more than a recognition of these conditions.
Its effect has seemed to be to bring attention to other kinds of database
systems. A caching system can get by with less features for structuring data so
long as it can access it quickly. A reporting system would have more need for
pulling a lot of data at once and flexibility in structuring it, but place less
importance on the data being up-to-the-millisecond consistent across your
enterprise. Through message- and event-driven system design techniques, one can
even represent the same information in multiple different databases to support
different applications.

So ultimately, the answer to the question of when you might want to use a SQL
database versus a NoSQL one comes down to the old "consultants' answer" of "it
depends." But what I hope I have been able to get across is a good sense of what
kinds of things it might depend _on_. There exist now a variety of database
solutions besides SQL/relational, all focused on being good at different things.
The question isn't so much SQL versus NoSQL as a choice among a variety of
databases of which SQL is but one subcategory.

 > Got a tech question you'd like me to write on? Send it to hoff2 at HEY dot
 > com.