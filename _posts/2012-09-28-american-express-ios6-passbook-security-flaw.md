---
layout: post
title: American Express iOS6 Passbook Security Flaw
tags: secuity amex
comments: true
---

# {{ page.title }}
This morning, American Express announced that you are able to bring in your card into Passbook for iOS6 via Twitter.

<blockquote class="twitter-tweet"><p>Upgrading to <a href="https://twitter.com/search/%23iOS6">#iOS6</a>? Add our Apple <a href="https://twitter.com/search/%23Passbook">#Passbook</a> Pass using Safari for auto acct notifications + more <a href="http://t.co/fzXm5QkX" title="http://aexp.co/vn0">aexp.co/vn0</a> <a href="http://t.co/jNu3XXHV" title="http://bit.ly/Uy5MmR">bit.ly/Uy5MmR</a></p>&mdash; American Express (@AmericanExpress) <a href="https://twitter.com/AmericanExpress/status/251662955488374785" data-datetime="2012-09-28T12:41:38+00:00">September 28, 2012</a></blockquote>
<script src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

Immediately, I try it out. Awesome.

I open up Passbook, and see my balance and a list of recent transactions. Awesome again.

![](http://i.imgur.com/U7jMm.png)
![](http://i.imgur.com/wWnac.png)

Then I realized what I had to do to get this Passbook file which exposes some relatively sensitive account information.

The link that Amex posted is just a form, that asks simply for first name, last name, email address, credit card number, and CID. All information that anyone who has ever touched my physical card had access to.

You enter in the information, and you're giving a `.pkpass` file, which is really just a fancy name for a `zip` file. Extract it, and inside you'll find a `pass.json` file, which looks something like this:

{% highlight javascript %}
{
    "authenticationToken": "...",
    "generic": {
            "key": "recentActv",
            "label": "RECENT ACTIVITY",
            "textAlignment": "PKTextAlignmentNatural",
            "value": "..."
        }],
        "primaryFields": [{
            "key": "name",
            "label": "",
            "value": "Matthew R."
        }],
        "secondaryFields": [{
            "key": "outstandin",
            "label": "Outstanding Balance",
            "textAlignment": "PKTextAlignmentLeft",
            "value": "$..."
        }]
    },
    "organizationName": "American Express",
    "passTypeIdentifier": "pass.com.americanexpressdigitalpartners",
    "serialNumber": "...",
    "teamIdentifier": "...",
    "webServiceURL": "https://americanexpressdigitalpartners.com/pass"
}
{% endhighlight %}

**So, without entering any password or logging into my account, I can generate a list of recent transactions and an account balance.**

And last, from my understanding of how Passbook works, is that new transactions are pushed to my device. So any future transactions will be updated in semi-realtime.

American Express, this is awesome and all, but *PLEASE* secure this page inside my account page after I've logged in, or add it to your iOS apps directly.
