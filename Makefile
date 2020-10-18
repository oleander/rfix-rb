bundle:
	cd tmp && bundle install
install: bundle
	bundle exec rake install:local
	# brew install cmake pkg-config libgit2 safe-rm
	# gem install colorize rake
	# rake build

test: install
	cd tmp && rfix info || true
	# cd tmp && bundle exec rfix --help || true
	# cd tmp && bundle exec ./exe/rfix  --debug --help || true
