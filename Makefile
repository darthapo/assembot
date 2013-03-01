
build:
	coffee -o lib -c src

watch:
	coffee -w -o lib -c src 

push:
	git push dropbox
	git push github

pushtags:
	git push dropbox --tag
	git push github --tag

publish:
	npm publish