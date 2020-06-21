FAME=vendor/oleander/git-fame-rb
CLI=vendor/shopify/cli-ui
dir:
	mkdir -p vendor
	rm -rf vendor/shopify
	rm -rf vendor/oleander
	mkdir -p vendor/shopify
	mkdir -p vendor/oleander
fetch:
	git clone https://github.com/shopify/cli-ui $(CLI)
	git --git-dir $(CLI)/.git --work-tree $(CLI) reset --hard ef976df676f4
	git clone https://github.com/oleander/git-fame-rb $(FAME)
	git --git-dir $(FAME)/.git --work-tree $(FAME) reset --hard a9b9c25bbab1
