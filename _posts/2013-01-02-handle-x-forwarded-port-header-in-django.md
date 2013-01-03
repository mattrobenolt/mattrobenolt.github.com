---
layout: post
title: Handle X-Forwarded-Port Header in Django
tags: django
comments: true
---

# Handle <nobr>X-Forwarded-Port</nobr> Header in Django
When running on a non-standard port, and behind a load balancer/proxy, it has become "standard"<sup>[[1]](#footnote-1)</sup> to forward along a header called `X-Forwarded-Port`.

This header is very similar to `X-Forwarded-Host`, `X-Forwarded-Proto`, and `X-Forwarded-For` in the sense that it's forwarding relevent information about the originating request and telling your backend to ignore the values it's aware of.

In this case, `X-Forwarded-Port` is not supported by Django natively, and the easiest way to handle it is through a simple middleware:

{% highlight python %}
class XForwardedPort(object):
    def process_request(self, request):
        try:
            request.META['SERVER_PORT'] = request.META['HTTP_X_FORWARDED_PORT']
        except KeyError:
            pass
        return None
{% endhighlight %}

This will allow urls to be properly reversed with the correct port as you'd expect.

### References
* [https://gist.github.com/4439597](https://gist.github.com/4439597)

#### Footnotes
* <a id="footnote-1"></a><small><sup>[1]</sup> I use quotes because nobody has a fucking clue what's really going on with this shit. There isn't a standard, just an idea that a few people started implementing.</small>
