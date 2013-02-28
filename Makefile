
build:
	coffee -o lib -c src

watch:
	coffee -w -o lib -c src 

push:
	git push dropbox
	git push github

publish:
	npm publish