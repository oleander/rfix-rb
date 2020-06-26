install:
	brew install cmake pkg-config libgit2 safe-rm
	gem install colorize rake
	rake build
