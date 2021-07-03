## Navigation page for susedoc.github.io and configuration of which documents to build in GitHub Actions

### Updating the GitHub Action build configuration and the navigation page

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

After the changes have been pushed, the GitHub Actions job for this repository *automatically* updates the navigation page.
That means it updates the `index.html` file.

### Enabling a documentation repository for CI draft builds

To initially enable draft builds of documentation with CI within a documentation repository, see the instructions at https://github.com/openSUSE/doc-ci#enabling-github-actions-within-documentation-repositories.


### Troubleshooting

The following bottlenecks exist:

* **GitHub Actions** builds and validates our documentation in a virtual machine.
  Sometimes, it takes the CI significant time to create a VM.
  In most cases, the CI creates a VM within a minute.
  There may be other cases.

  CI can also take significant time to validate and build documents.
  This is largely dependent on the size of the documents in the documentation repository.
  However, it can also be influenced by general network and server load.

* **GitHub Pages** serves the documents built by CI.
  It employs a server cache and uses a CDN (content delivery network).
  It usually takes around 2-5 minutes after CI is finished before you see the build results.

* **Your browser** has a local cache.
  This may lead to you being shown outdated content.

**Patience is a virtue.**
Both GitHub Actions and GitHub Pages are free (as in money) Web services providing significant computing resources to a global audience.
In exchange for that, they are not always as quick as you might expect from an internal-only, high-priority service.


#### Checking the status of CI

It may take some time until the results are displayed.
You can check the progress of a CI build job directly from the documentation repository which hosts the documentation sources:

* From the *Actions* tab of the repository: Click the job you are interested in.
* In the GitHub commit list:
  Click the little green/orange/red icon next to the commit's description and click *Details*.
  This option takes you directly to the related build job.

Read the CI logs carefully.
Some smaller issues may be reported there even though the build as a whole succeeded.
Within the CI log, there may be a few items you could be especially interested in:

* The job *select-dc-files*, step *Selecting DC files to build*.
  To display more details, unfold the step and look at the end result (*Builds will be enabled*).
  If the branch is not configured for builds but should be, this may be because of either:
  * the configuration is wrong: adjust `config.xml`, then restart the CI build (see below)
  * the build you are looking at ran before the last configuration update: restart the CI build (see below)

* The job *publish*, step *Publishing builds on susedoc.github.io*.
  This job is set to fail silently, because sometimes there are hard-to-avoid Git-related issues when publishing builds for too many jobs at the same time.
  If you see the message *Target repository could not be pushed to* at the end of that step, unfortunately, your job has been caught up in this issue.
  You can click *Re-run jobs* to try again, if necessary.


#### Restarting CI builds

CI allows restarting jobs manually.
This is helpful in the following cases:

* If https://susedoc.github.io/ displays a link for a newly configured document/branch but clicking it still displays a *404 error*.
  In this case, there often has not have been a new commit since you updated `config.xml`.
  Therefore, CI did not start a new build with the updated configuration file.

* If a CI build failed because of a timeout or other technical issue.

To manually trigger a rebuild:

1. Go to a job log page as described in *Checking the Status of CI* above.
2. Click *Re-run jobs*.


#### Checking the status of GitHub Pages

There is no way to directly check the deployment status of GitHub Pages.


#### Avoiding browser caching

Your browser has a local cache.
This may lead to you being shown outdated content.
To exclude issues related to browser caching from interfering with what you are seeing:

1. Open a new Private mode or Incognito mode window of your browser.
2. Check the Web site in this window.


#### Other issues

* Sometimes, **GitHub** itself runs into glitches.
  To see whether GitHub has any outages currently, check https://status.github.com/.


### Files and branches in this repository

#### `main` branch

The `main` branch is used to configure the output and CI builds.

* `config.xml`
   * Configuration file that defines
      * Which documents CI will build from which source repo and branch
      * Links to all output documents on `https://susedoc.github.io/index.html`
      * HTML-based preamble text for the index page
      * Redirect links under `https://susedoc.github.io/r/`
* `README.md` - This README file
* `_stuff/config.dtd` - A schema file to validate `config.xml` with.
* `.github/workflows/` - GitHub Actions workflow files.

#### `gh-pages` branch

The `gh-pages` branch is used to output the final `index.html` file to (updated automatically).
Automatically created redirect HTML pages are stored in `r/`.

It also contains the `documentation.ymp` file (needs to be updated manually).

Finally, it contains a few other files that do not need to be touched regularly:

* `favicon.ico` - An image for the tab strip in your browser
* `google26b19e50039fbeba.html` - Google verification file
* `robots.txt` - disallows crawling by search engines to avoid our beta documentation from creeping into people's search results
* `stylesheet.css` - Formatting for the navigation page

#### `gha-sdgio-publish` branch

The `gha-sdgio-publish` branch contains the GitHub Action that converts the `config.xml` file from the `main` branch to the `index.html` of the `gh-pages` branch.
To do that, it needs:

* `action.yml` - GitHub Actions main file
* `action.sh` - The script run by `action.yml`
* `Dockerfile` - The Docker container we use (for no good reason)
* `update-script/update-index.sh` - Script that actually updates the `index.html` page, can also be run manually on a local machine if need be
* `update-script/update-index.xsl` - XSL stylesheet that transforms the configuration file into an HTML page
