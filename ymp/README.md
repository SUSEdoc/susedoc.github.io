# Making it easier to install the SUSE documentation toolchain

After installing openSUSE Leap or Tumbleweed, you may have faced the
following questions:

* Which packages are necessary for my documentation work?
* Where do I find them?

This YMP file tries to solve the issue by subscribing you to relevant
software repositories and allowing you to select relevant software packages
easily.


## Prerequisites

Make sure that the package `yast2-metapackage-handler` is installed.
(Usually installed by default).


## Installing packages with the YMP file

To subscribe to the repositories and install the packages from the YMP file,
run:

```
sudo OneClickInstallUI https://susedoc.github.io/ymp/Documentation.ymp
```

The installation consists of two steps:

1. You will be offered a list of repositories to subscribe to.
2. You will be offered a list of packages to install.

Review the suggestions, in particular package suggestions.
In many cases, it is not necessary to change the default settings.
However, you can select additional optional packages.


## Contributing

If you are you missing any packages, open an issue in this repository.


## More information

* First post about this YMP file on doku-intern:

  https://mailman.suse.de/mailman/private/doku-intern/2018-September/008602.html

* openSUSE Wiki article about One Click Installation:

  https://en.opensuse.org/openSUSE:One_Click_Install_Developer

