## Overview Page for susedoc.github.io and Configuration of Which Files to Build in Travis

### Important Files in this repo:

* `index-config.xml`
   * Configuration file that defines
      * Which documents Travis CI will build from which source repo and branch
      * Links to all output documents on `https://susedoc.github.io/index.html`
      * HTML-based preamble text for the index page
* `index.html` - Output HTML navigation page as displayed at `https://susedoc.github.io/index.html`.
* `update-index.sh` - Script to generate `index.html`.

### To update the index page:

Add documents/make text changes in `index-config.xml`.
   * To change document builds, modify/add/remove `<doc/>` tags. `<doc/>` tags have the following attributes:
      * `cat="..."`, a category ID (usually for the product), categories are defined in the `<cats/>` section of the document.
      * `doc="..."`, the name of the DC file but with the `DC-` suffix removed
      * `branches="..."`, a space-separated list of branches that the document is available on
      
     Finally, a `<doc/>` tag includes the human-readable name of the document as its element text.
   * Preamble text changes need to happen within in the `<meta/>` element.
Commit & push your changes.

Travis will then take of updating the `index.html` file that is displayed as
the navigation page.


To initially enable draft builds of documentation with Travis CI, see https://github.com/openSUSE/doc-ci#travis-draft-builds.
