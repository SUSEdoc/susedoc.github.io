# Natively installing the SUSE documentation toolchain

The YMP file (YaST "1-click" installer) from this repository helps you quickly set up the SUSE documentation toolchain on openSUSE Leap or Tumbleweed.
It automatically subscribes you to necessary repositories and sets up necessary packages.

If you are using any other Linux distribution, see https://github.com/openSUSE/daps2docker.
If you are using any other OS, you can use the container image also used by daps2docker, via `docker pull susedoc/ci:latest` (additional steps need to be figured out manually).


## Prerequisites

Make sure that the package `yast2-metapackage-handler` is installed.
(This package is usually installed by default.)


## Installing


1. Alternatively, use the GUI or the command line.
   * Command line:

     ```
     sudo OneClickInstallUI https://susedoc.github.io/ymp/Documentation.ymp
     ```

     Enter your `root` password. YaST should open.

   * GUI:

     a. Download this file: [https://susedoc.github.io/ymp/Documentation.ymp](https://susedoc.github.io/ymp/Documentation.ymp).

     b. Double-click the downloaded file. You should see a prompt for your `root` password and then a YaST screen.

2. Independently of how you started the installation, there are two steps:

   a. You will be offered a list of repositories to subscribe to.

   b. You will be offered a list of packages to install.

   Review the suggestions, in particular the package suggestions.
   In many cases, it is not necessary to change the default settings.
   However, you can select additional optional packages.


## Feedback

If you are missing any packages or have other feedback, open an issue at https://github.com/susedoc/susedoc.github.io/issues.


## More information

* openSUSE Wiki article about One-Click Installation:

  https://en.opensuse.org/openSUSE:One_Click_Install_Developer

