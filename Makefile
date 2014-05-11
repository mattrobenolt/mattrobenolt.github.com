setup:
	bundle install

run:
	bundle exec jekyll serve --watch --drafts

.PHONY: setup run
