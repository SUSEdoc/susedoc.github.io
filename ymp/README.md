# Making Installation Easier for Documentation People

Whenever you installed a new openSUSE Leap or Tumbleweed on your machine
from scratch, you face this problems:

* which packages do I need for my documentation work?
* where do I find them?

These questions can be solved with a YMP file. Everything is in one place,
be it repositories or packages.


## Requirements

Make sure you have the `yast2-metapackage-handler` package installed
(usually already available on your system by default).


## Using the YMP File

To subscribe to the repositories and install the packages from the YMP file,
run:

```
sudo OneClickInstallUI https://gitlab.suse.de/susedoc/doc-ymp/raw/master/Documentation.ymp
```

The installation contains two steps:

1. The list of repositories you will subscribe to.
2. The list of packages you will install.

Review them carefully. Usually, it is not necessary to change the default
settings. In some cases, you can select or deselect some packages which are
optional.


## How to Contribute

If you are missing packages? Please open an issue, thanks!


## See Also

* First post about YMP on doku-intern:

  https://mailman.suse.de/mailman/private/doku-intern/2018-September/008602.html

* openSUSE Wiki article about One Click Installation:

  https://en.opensuse.org/openSUSE:One_Click_Install_Developer

