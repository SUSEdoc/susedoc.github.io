## Navigation Page for susedoc.github.io and Configuration of Which Files to Build in Travis

### Updating the Travis Build Configuration and the Navigation Page

All of the following works from the GitHub Web UI. To configure a new branch for
building, there is **no need to clone** this repository locally
**or run a script**.

1. Add documents/make text changes in `config.xml`.
   * To change document builds, modify/add/remove `<doc/>` tags. `<doc/>` tags have the following attributes:
      * `cat="..."`, a category ID (usually for the product), categories are defined in the `<cats/>` section of the document
      * `doc="..."`, the name of the DC file but with the `DC-` suffix removed
      * `branches="..."`, a space-separated list of branches for which the DC file in question will be published here
     Finally, a `<doc/>` tag includes the human-readable name of the document as its element text.
   * Preamble text changes need to happen within in the `<meta/>` element.
2. Commit & push your changes.

The Travis job for this repository will then take care of updating the
`index.html` file that is displayed as the navigation page automatically.


To initially enable draft builds of documentation with Travis CI, see https://github.com/openSUSE/doc-ci#travis-draft-builds.

### Patience! and Other Dubitable Troubleshooting Wisdom

GitHub does not always update the Web page immediately or as fast as you may wish. Travis may run longer or do unexpected things. Here's a quick guide to the most important troubleshooting steps:

* ***Patience is a virtue.*** Both Travis and GitHub are free (as in money) Web services providing significant computing
  resources to a global audience. In exchange for that, they are not always as quick as you might expect from an
  internal-only, high-priority service.
  * **Travis** may take some time to spin up a VM/Docker image. You can watch the progress of your build:
    * GitHub Pull Request view: Click "Travis" > "Details"
    * GitHub Commit list: Click the little green/orange/red icon next to your commit's name > "Details"
  * **GitHub Pages** employs a server cache and uses a CDN. It usually takes around 2-5 minutes after Travis is finished
    before you can see the build results.
  * Your **browser** has a local cache. Try checking the website in the Private/Incognito mode of your browser to
    exclude issues with browser caching.
  * Sometimes, **GitHub** runs into glitches. To see whether GitHub has any outages currently, check
    https://status.github.com/.

* ***Read the Travis logs*** if you continue to see issues after applying an appropriate amount of patience:
  * The build result may be "green" but that does not mean the log is uninteresting. Travis does not provide a light-red
    state, there are only red or green. Hence, some smaller issues may be ignored during build. 
  * In particular, check the logs for whether your branch is set up for building or whether it is only set up for validation.
  * If you log in to Travis, you can use the "Trigger Rebuild" button. That can help with:
    * Travis runs that failed because of timeout issues
    * Travis runs that did not lead to a HTML document build/upload because Travis started the build before the
      `config.xml` was properly configured.


### Files in this Repo

#### Important for Users

* `config.xml`
   * Configuration file that defines
      * Which documents Travis CI will build from which source repo and branch
      * Links to all output documents on `https://susedoc.github.io/index.html`
      * HTML-based preamble text for the index page
* `index.html` - Output HTML navigation page as displayed at `https://susedoc.github.io/index.html` -- do not edit manually
* `README.md` - This README file


#### Others

* `.travis.yml` - Main Travis CI configuration file
* `favicon.ico` - An image for the tab strip in your browser
* `google26b19e50039fbeba.html` - Google verification file
* `robots.txt` - disallows crawling by search engines to avoid our beta documentation from creeping into people's search results
* `stylesheet.css` - Formatting for the navigation page
* `_stuff/ssh_key.enc` - Encrypted SSH key that allows Travis CI to push back to this repository
* `_stuff/travis.sh` - Script that will be run by Travis CI in our Docker container
* `_stuff/update-index.sh` - Script that actually updates the `index.html` page, can also be run manually on a local machine if need be
* `_stuff/update-index.xsl` - XSL stylesheet that transforms the configuration file into an HTML page
* `_stuff/config.dtd` - DTD for config.xml
