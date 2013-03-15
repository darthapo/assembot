push:
	git push dropbox
	git push github

pushtags:
	git push dropbox --tag
	git push github --tag

publish:
	npm publish

test:
	@NODE_ENV=test 
	@clear
	@./node_modules/.bin/mocha 

watch_test:
	@NODE_ENV=test 
	@./node_modules/.bin/mocha --reporter min --watch --growl

.PHONY: watch push pushtags publish test watch_test