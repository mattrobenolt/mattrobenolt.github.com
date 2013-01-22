---
layout: post
title: Reusable Django Tests
tags: django testing brain-dump
comments: true
---

# {{ page.title }}
First of all, I think that testing should be accessible to everyone and should be simple enough to just "plug in" some automated tests for common patterns.

Django does a pretty awesome job at encompassing applications. An application may be a blog, or a voting system, or one of many other components that require minimal configuration. These applications lower the barrier to writing larger systems.

These applications come from the idea that a lot of these pieces share the same basic pieces across different projects, e.g. everyone's tagging system is going to support the same core necessities.

What if we were able to identify common testing patterns and were able to generate tests that automatically introspect and make assertions about our app for us? Then we could just *install* a new application, apply some basic configuration, and boom! Instant tests without needing to actually write them yourself.

I want to start tackling this problem and begin identifying patterns that can be extrapolated out into their own suite that is just installed and ready to go.

## Introducing: [Proofread][1]
My first attempt at a solution to this is a project I've called **[proofread][1]**. [Proofread][1] tests the very basics of any web application: the public endpoints.

[Proofread][1] is simply configured in your `settings.py` to make requests to each of the endpoints on your app, and check that they respond with correct status codes.

### What makes [Proofread][1] awesome?
Well, anyone can use it, whether you've ever written a test before or not, and take advantage of some immediate features.

In my experience, I tend to write a quick layer of tests that I've called a "smoke screen" check. This smoke screen would just make sure that the application worked in the most basic sense.

**Does making a request for the home page succeed?**

That simple question can usually catch accidental `SyntaxError`s or missing `import` statements. Too often have I see someone do a really quick fix and forget to import the file needed resulting in someone else cleaning up the broken commit.

### What's next?
I'm going to be researching and experimenting with automating some tests for other common aspects of Django. I think my next attempt is going to be introspecting Forms and automating a test suite for validation.

I'd love to hear thoughts and opinions on this topic!


## Resources
* [https://github.com/mattrobenolt/proofread][1]

[1]: https://github.com/mattrobenolt/proofread
