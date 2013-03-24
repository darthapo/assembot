build:
	./node_modules/.bin/assembot build

gzip:
	gzip --stdout --best public/app.js > public/app.js.gz

clean:
	rm public/app.*

test:
	@NODE_ENV=test
	@clear
	@./node_modules/.bin/mocha

.PHONY: build clean gzip test 
