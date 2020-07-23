## Navigation Page for susedoc.github.io and Configuration of Which Documents to Build in Travis

### Updating the Travis Build Configuration and the Navigation Page

**All of the following works from the GitHub Web UI.**

To configure a new branch for building, there is:

* no need to clone this repository locally (though you can if you want to)
* no need to run a script


1. From this repository, open `config.xml` for editing.
   * To change document builds, modify/add/remove `<doc/>` tags. `<doc/>` tags have the following attributes:
      * `cat="..."`, a category ID (usually for the product), categories are defined in the `<cats/>` section of the document
      * `doc="..."`, the name of the DC file but with the `DC-` suffix removed
      * `branches="..."`, a space-separated list of branches for which the DC file in question will be published here
     Finally, a `<doc/>` tag includes the human-readable name of the document as its element text.
   * Preamble text changes need to happen within in the `<meta/>` element.
   * You can define short redirect URLs using `<redirect/>` elements.
2. Commit & push your changes.

After the changes have been pushed, the Travis CI job for this repository *automatically* updates the navigation page.
That means, it updates the `index.html` file.

### Enabling a Documentation Repository for Travis CI Draft Builds

To initially enable draft builds of documentation with Travis CI within a documentation repository,
see the instructions at https://github.com/openSUSE/doc-ci#travis-draft-builds.


### Troubleshooting

The following bottlenecks exist:

* **Travis CI** builds and validates our documentation in a virtual machine.
  Sometimes, it takes Travis CI significant time to create a VM.
  In most cases, Travis CI creates a VM within a minute.
  In more extreme cases, it can take 10 minutes for Travis CI to create a VM.

  Travis CI can also take significant time to validate and build documents.
  This is largely dependent on the size of the documents in the documentation repository.
  However, it can also be influenced by general network and server load.

* **GitHub Pages** serves the documents built by Travis.
  It employs a server cache and uses a CDN (content delivery network).
  It usually takes around 2-5 minutes after Travis is finished before you see the build results.

* **Your browser** has a local cache.
  This may lead to you being shown outdated content.

**Patience is a virtue.**
Both Travis and GitHub are free (as in money) Web services providing significant computing resources to a global audience.
In exchange for that, they are not always as quick as you might expect from an internal-only, high-priority service.


#### Checking the Status of Travis CI

It may take some time until the results are displayed.
You can check the progress of a Travis build job directly from the documentation repository which hosts the documentation sources:

* In the GitHub Pull Request view: In the section that displays the Travis checks, click "Details".
  This option takes you directly to the related build job.
* In the GitHub Commit list: Click the little green/orange/red icon next to your commit's name and click "Details".
  This option takes you directly to the related build job.
* Log in to Travis CI at https://travis-ci.org/. From there, select the project and build job you are interested in.

Read the Travis CI logs carefully.
Some smaller issues may be reported there even though the build as a whole succeeded.
Within the Travis log, there may be a few items you could be especially interested in:

* The line "Check whether repo/branch are configured for builds".
  To display more details, unfold the section.
  If the branch is not configured for builds but should be, this may be because of either:
  * the configuration is wrong: adjust `config.xml`, then restart the Travis CI build (see below)
  * the build you are looking at ran before the last configuration update: restart the Travis CI build (see below)


#### Restarting Travis CI Builds

Travis allows restarting jobs manually.
This is helpful in the following cases:

* If https://susedoc.github.io/ displays a link for a newly configured document/branch but clicking it still displays a `404 error`.
  In this case, there often has not have been a new commit since you updated `config.xml`.
  Therefore, Travis did not start a new build with the updated configuration file.

* If a Travis CI build failed because of a timeout or other technical issue.

To manually trigger a rebuild:

1. Go to a job log page as described in *Checking the Status of Travis CI* above.
2. Make sure you are logged in to Travis CI.
   If not, log in with your GitHub credentials using the *Sign In with GitHub* button at the top of the page
3. Click *Restart Build*.


#### Checking the Status of GitHub Pages

There is no way to directly check the deployment status of GitHub Pages.


#### Avoiding Browser Caching

Your browser has a local cache.
This may lead to you being shown outdated content.
To exclude issues related to browser caching from interfering with what you are seeing:

1. Open a new Private mode or Incognito mode window of your browser.
2. Check the Web site in this window.


#### Other Issues

* Sometimes, **GitHub** itself runs into glitches.
  To see whether GitHub has any outages currently, check https://status.github.com/.


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
