git:
	git add .
	git commit -m "Automatic" || true
gem:
	gem build rfix.gemspec
	gem install rfix-0.1.0.gem
build: bundle git gem
bundle:
	bundle install
clean:
	rm -f rfix-0.1.0.gem
run: build
	unalias rfix || true
	bundle exec rfix local --dry --list-files || true
do: run clean
