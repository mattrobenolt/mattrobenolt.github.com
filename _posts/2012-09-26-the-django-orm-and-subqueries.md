---
layout: post
title: The Django ORM & Subqueries
comments: true
---

# {{ page.title }}
<small>Note: At the time of writing, Django is at v1.4.1</small>

So what actually happens when you have a Django query like the following?

{% highlight python %}
cities = City.objects.all()
venues = Venue.objects.filter(city__in=cities)
{% endhighlight %}

Django is smart enough to know that you want to use the results from the first *unevaluated* `QuerySet` as the input for the `__in` clause, and in turn, generates a subquery. The raw query generated is something like this:

{% highlight sql %}
SELECT ...
FROM   "venue" 
WHERE  "venue"."city_id"
IN (
    SELECT U0."id" 
    FROM "city" U0
) 
{% endhighlight %}

Awesome. Django saved us an extra round trip by inlining the query instead of evaluating the first query separately.

## What's wrong?
In this scenario, nothing at all. We've saved a round trip to the database, all is good. Let's throw caching into the mix.

{% highlight python %}
cities = cache.get('cities')
if cities is None:
  cities = City.objects.all()
  cache.set('cities', cities)
venues = Venue.objects.filter(city__in=cities)
{% endhighlight %}

In this scenario, we want to cache the entire list of cities. The `City` `QuerySet` gets cached for us like we expect, but when Django gets to the `filter()`, it sees that you're passing it a `QuerySet` and generates a subquery again. We've effective cached nothing because the exact same query is being run.

This also applies when you want to use the same `__in` across multiple filters.

{% highlight python %}
cities = City.objects.all()
venues = Venue.objects.filter(city__in=cities)
users = UserAccount.objects.filter(city__in=cities)
{% endhighlight %}

Again, the exact same subquery is repeated across both queries.

## Well, how can we fix this?
The reason why Django is doing this is solely because the argument passed into `filter()` is a `QuerySet`. If we just pass a `list`, Django will use an array of ids inside the `IN` SQL.

Let's look at an improved version with caching.

{% highlight python %}
cities = cache.get('cities')
if cities is None:
  cities = list(City.objects.all())  # Force query evaluation
  cache.set('cities', cities)
venues = Venue.objects.filter(city__in=cities)
{% endhighlight %}

The only thing that has changed is forcing the `QuerySet` to be evaluated by converting it to a `list`. Now, `cities` is a `list`, so Django won't try to perform a subquery anymore. This could be simplified to just caching the primary keys as a `list` as well, depending on what you're trying to achieve.

The resulting SQL will be something like:

{% highlight sql %}
SELECT ...
FROM   "venue" 
WHERE  "venue"."city_id"
IN (
    1, 2, 3
) 
{% endhighlight %}

## One more gotcha!
We all know that Django's `QuerySet`s are lazy, right? No query is actually performed until the `QuerySet` is iterated over. Once a `QuerySet` has been iterated over, it won't query again for the results. The results get cached into an internal `_results_cache` object.

At the moment, Django is not smart enough to detect that a `QuerySet` has already been evaluated before generating a subquery, effectively causing the query to be run again when we already know the results.

Picture this scenario:

{% highlight python %}
cities = City.objects.all()
names = [city.name for city in cities]  # QuerySet cache is filled
# ... do something awesome ...
venues = Venue.objects.filter(city__in=cities)
{% endhighlight %}

Since we've already evaluated the `QuerySet` before passing it to the `__in` clause, it'd be smart to just use the ids that we've already calculated from before, but it doesn't. So pay attention and be careful.

I've submitted a patch to Django core to try and get that behavior fixed:

* [https://github.com/django/django/pull/396](https://github.com/django/django/pull/396)
* [https://code.djangoproject.com/ticket/19029](https://code.djangoproject.com/ticket/19029)
