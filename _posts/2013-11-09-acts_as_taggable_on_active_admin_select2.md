---
layout: post
title: "acts_as_taggable_on tagging in Active Admin with Select2 and remote data"
description: "A post about making a tag input for Active Admin"
date: 2013-11-09 15:20
modified: 2013-11-09
tags: [rails, ruby, acts-as-taggable, active-admin, select2]
---

I wanted a really fly keyword tagging input in my app that let me do
what I'm already pretty used to doing with Wordpress's tagging:
auto-complete existing tags to help me maintain consistency, but also
let me make up new tags on the spot.

[Select2][select2 site] is nice as heck, and has a tagging
functionality that does just what I'm looking for and is even prettier
than what Wordpress has. The section on "Tagging Support" on the
website looked like pretty much exactly what I wanted, but there were
a few things to iron out: Firstly, I didn't want to have to stick all
the existing tags in the javascript or in the view. Yeah it's cool
that the asset pipeline _lets_ us do .js.erb but it just feels wrong;
and that list of all the existing tags could get pretty big, so
jamming it all into an HTML attribute feels even more wrong. What I
wanted was that AJAXy searching autocomplete where you start typing
and it fetches a list from the server and that list narrows down as
you type more letters. And on top of it all, I was doing this in
Active Admin in a Rails 3 app.

![image Select2 docs screenshot](/images/select2_tagging.png)

[select2-rails][select2-rails github] takes care of a good bit of that
last bit, though it doesn't do too much more than package it up for
the asset pipeline. I had to wrestle with it quite a bit more, hacking
bits and pieces together from different documentation, blogs, and
StackOverflow threads, before everything would behave like I wanted,
even though I didn't think what I was after was particularly exotic.
So naturally the right thing do to once I got it all working was to
write it up here. I think even if you're not using Active Admin, a lot
of this will still help without too much adjustment, especially if
you're using Formtastic.

First off you'll want `gem 'select2-rails'` and `gem
'acts-as-taggable-on'` in your Gemfile and bundle install'd. Then pull
the select2 javascript into your app by putting `//= require select2`
in your `active_admin.js` -- or application.js if you want to also
have it available in non-admin parts of your app -- and that same line
in `active_admin.css.scss`. If some stuff still looks visually out of
whack later on, try adding this at the end of
`active_admin.css.scss`:

    body.active_admin {
      @import 'select2'
    }

So now we get into how to put this in your Active Admin form. We'll
make it an input for `acts_as_taggable_on`'s `tag_list` accessor
because it does such a nice job of Doing What You Mean with very
little fuss. Here's a somewhat redacted excerpt from my
`app/admin/articles.rb`:

{% highlight ruby %}
form do |f|
  f.inputs do
    f.input :title
    f.input :content, as: :rich
    f.input :tag_list,
      label: "Tags",
      input_html: {
        data: {
          placeholder: "Enter tags",
          saved: f.object.tags.map{|t| {id: t.name, name: t.name}}.to_json,
          url: autocomplete_tags_path },
        class: 'tagselect'
      }
  end
  f.buttons
end
{% endhighlight %}

As you can see, there's quite a few attributes being given to the
input's HTML element, which Select2 will then hide and manipulate
behind the scenes while presenting us the very cool tagging widget we
love. The `class` could be whatever we want, but it's what we'll be
using to find this element in the javascript we'll get to momentarily.

The `data` hash gets placed on the input as data attributes. This is
data we want to make available to said javascript. `saved` is for the
article's current tags, so that the widget can render those right
away. Select2 expects to work with a JSON array of objects, but you're
probably wondering why I'm passing both an `id` and a `name` but
setting both values to the tag's name.

The thing is, since we're using the `tag_list` accessor, we don't
really care about the tags' IDs. I think that's fine, after all,
conceptually, a tag's name _is_ it's identifying attribute. It would
be a perfectly reasonable design for the `tags` database table to not
have an `id` column at all and have `name` be the primary key -- that
would match our mental model of tags -- but this is Rails where
everything has to have an `id`. More to the point, Select2 won't
render the tags right, or at all, if they don't have an `id` attribute
with _something_ in it. But when I used the tags' actual ID there, the
IDs were ending up among the array of tag names in the params coming
in to the Rails app causing me to end up with extraneous tags getting
created whose names _were_ those IDs, and that was awful. There might
be other ways around this.

The `url` data attribute is there to tell Select2 where to find the
remote service to look up tags in for the auto-complete. It's up to
you whether you want to set this up in another controller, what you
want to name it, and so on. In my case, just keeping it simple, I
added it to Active Admin's controller for my `app/admin.articles.rb`,
like so:

{% highlight ruby %}
controller do
  def autocomplete_tags
    @tags = ActsAsTaggableOn::Tag.
      where("name LIKE ?", "#{params[:q]}%").
      order(:name)
    respond_to do |format|
      format.json { render json: @tags , :only => [:id, :name] }
    end
  end
end
{% endhighlight %}

and correspondingly, in config/routes.rb:

{% highlight ruby %}
get '/admin/autocomplete_tags',
  to: 'admin/articles#autocomplete_tags',
  as: 'autocomplete_tags'
{% endhighlight %}

Fairly straightforward what's going on here, we'll be having Select2
pass in what we've typed so far in the `q` param and using a SQL
`LIKE` query to give back tags to offer in the little auto-complete
list.

And now, the javascript to fire up Select2's tag input magic. Right
now I just have this tacked on the end of `active_admin.js` but it's a
significant enough piece of code that I'd feel justified putting it in
a separate file and `//= require`-ing it.

{% highlight javascript %}
$(document).ready(function() {
    $('.tagselect').each(function() {
        var placeholder = $(this).data('placeholder');
        var url = $(this).data('url');
        var saved = $(this).data('saved');
        $(this).select2({
            tags: true,
            placeholder: placeholder,
            minimumInputLength: 1,
            initSelection : function(element, callback){
                saved && callback(saved);
            },
            ajax: {
                url: url,
                dataType: 'json',
                data:    function(term) { return { q: term }; },
                results: function(data) { return { results: data }; }
            },
            createSearchChoice: function(term, data) {
                if ($(data).filter(function() {
                    return this.name.localeCompare(term)===0;
                }).length===0) {
                    return { id: term, name: term };
                }
            },
            formatResult:    function(item, page){ return item.name; },
            formatSelection: function(item, page){ return item.name; }
        });
    });
});
{% endhighlight %}

So at the top you can see I start with a jQuery selector of that
"tagselect" class I put on in the `input_html` option, then grab the
values off those data attributes, then call `select2` on the element
with a whole mess of the options it accepts. The most interesting
bits:

 * `tags: true` is the simplest way to tell Select2 this is a tagging
   input without having to tell is what tags to autocomplete for up
   front.
 * `minimumInputLength` is how many letters we want the user to type
   before we start trying to suggest completions.
 * `initSelection` is used to set up the tagging input at the start,
   to get it to display what we brought in the `saved` data attribute.
 * `ajax` sets up the call to our `autocomplete_tags` action described
   before.
 * `createSearchChoice` is where we tell Select2 how to put the
   results of that call in the autocomplete list. The snarly-looking
   conditional here is just to filter out duplicates of tags we've
   already got picked out. As long as it's not a duplicate, we whip up
   another `id`/`name` object just like we did when we set up the
   `saved` data attribute.
 * `formatResult` and `formatSelection` look for a `text` attribute if
   you don't tell them otherwise so I'm telling them to use `name`.

And that's pretty much all it takes. I had to complicate it up pretty
heavily in order to see how to get it this simple, now you don't have
to. Have fun!

_update 6 September 2014:_ Samo Zeleznik writes in:

> When I create a new post with a tag that is the same as a tag that
was already created prior to that it does not save it by it's name,
but by it's id. So it creates a new entry in the tags table that has a
unique id, but the name of that tag is the id of the real tag.

> What I just wrote is probably a little bit confusing so let me
explain it with an example: I have a post tagged with "math" and this
tag has an ID of 5. Now I create a new post and I tag also tag it with
"math". Now when I save this post it will bi tagged with 5. So It
creates a new tag with a unique id (6 for example) and names it 5 (id
of math). Do you have any idea what could be causing this issue?

Around the same time, David Sigley tweets me with what appears to be
the same issue.

As it's been quite a while, all I could offer was that I sorta
remembered having trouble with tags getting named their IDs instead of
their names before and there was some hack I had to do, and I may not
have done enough to point it out and explain it above. Later Samo sent
me [this StackOverflow question][stackoverflow question] where he got
it worked out, and the solution comports with the ruby code above that
looks like this: `f.object.tags.map{|t| {id: t.name, name:
t.name}}.to_json`. Note how the hash/JSON has an `id` key and a `name`
key, but the value at both is the tag's name. Later the Javascript
does something siliar: `return { id: term, name: term };` Then [David
figured it out too][Sigley tweet]. I don't have a really clear idea of
why it has to be this way, it's a hack, but there you have it.

[select2 site]: http://ivaynberg.github.io/select2/
[select2-rails github]: https://github.com/argerim/select2-rails
[stackoverflow question]: https://stackoverflow.com/questions/24728983/acts-as-taggable-on-and-select2-returning-weird-results-in-active-admin/25428442#25428442
[Sigley tweet]: https://twitter.com/Sigularusrex/status/503536715920068608
