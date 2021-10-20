# Natively installing the SUSE documentation toolchain

The YMP file (YaST "1-click" installer) from this repository helps you quickly set up the SUSE documentation toolchain on openSUSE Leap or Tumbleweed.
It automatically subscribes you to necessary repositories and sets up necessary packages.

If you are using any other Linux distribution, see https://github.com/openSUSE/daps2docker.
If you are using any other OS, you can use the container image also used by daps2docker, via `docker pull susedoc/ci:latest` (additional steps need to be figured out manually).


## Prerequisites

Make sure that the package `yast2-metapackage-handler` is installed.
(This package is usually installed by default.)


## Starting the installation, command line

To subscribe to the repositories and install the packages from the YMP file, run:

```
sudo OneClickInstallUI https://susedoc.github.io/ymp/Documentation.ymp
```

Enter your root password, YaST should open afterward.


## Starting the installation, GUI

1. Download this file: https://susedoc.github.io/ymp/Documentation.ymp
2. Double-click the downloaded file, you should see a prompt for your `root` password and then a YaST screen.


## Actual installation

Independently of how you started it, the installation consists of two steps:

1. You will be offered a list of repositories to subscribe to.
2. You will be offered a list of packages to install.

Review the suggestions, in particular the package suggestions.
In many cases, it is not necessary to change the default settings.
However, you can select additional optional packages.


## Feedback

If you are missing any packages or have other feedback, open an issue at https://github.com/susedoc/susedoc.github.io/issues.


## More information

* openSUSE Wiki article about One Click Installation:

  https://en.opensuse.org/openSUSE:One_Click_Install_Developer

