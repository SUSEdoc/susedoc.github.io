# Overview Page for susedoc.github.io

Important Files in this repo:

* `index-config.xml` - Configuration file with links to all relevant documents.
* `index.html` - Output HTML file.
* `update-index.sh` - Script to generate `index.html`.

Hence, to update the index page:

1. Add documents/make text changes in `index-config.xml`.
2. Run `./update-index.sh`.
3. Commit & push your changes.

To create draft builds of documentation with Travis CI, refer to https://github.com/openSUSE/doc-ci#travis-draft-builds
