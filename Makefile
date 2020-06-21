dir:
	mkdir -p vendor
	rm -rf vendor/shopify
	rm -rf vendor/oleander
	mkdir -p vendor/shopify
	mkdir -p vendor/oleander
fetch:
	git clone https://github.com/shopify/cli-ui vendor/shopify/cli-ui
	git  --git-dir vendor/shopify/cli-ui/.git checkout ef976df676f4
	git clone https://github.com/oleander/git-fame-rb vendor/oleander/git-fame-rb
	git --git-dir vendor/oleander/git-fame-rb/.git checkout a9b9c25bbab1
