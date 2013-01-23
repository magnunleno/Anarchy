Anarchy
=======

A tool with the intend to help installing the amazing Arch Linux distribution. With the Anarchy Project you'll be able to automatize the installation using a simple script.

The Anarchy Project will be distributed in the following modalities:
 * A couple of scripts (through this repository);
 * A tool to build a new installation image (ISO) with the Anarchy Project scripts embedded;
 * A pre-built ISO;

*Attention:* Despite the project being stable and usable, this first release is a "prove of concept" and will be totally rewritten to Python in the near future. Also new features will be added gradually.


Anarchy is NOT a Distribution
=============================

Despite the fact that the Anarchy Project WILL provide an installation image (ISO), we are NOT an Arch Linux based distribution. We merely want to help:
 * all those newbie users which are having a bad time with the Arch Linux installation;
 * users that constantly need to reinstall Arch Linux for testing purposes;
 * users that already know the installation process and are in a rush to do it;
 * users that want to automatize the Arch Linux installation process;


Using Anarchy
=============

In order to use Anarchy first you'll need to obtain it, this can be done following one of those guides:
 * Build your own installation image;
 * Clone the Anarchy Project repository;
 * Download the latest stable Anarchy Project source code;

After obtaining the Anarchy Project you'll need to customize it to your needs, this can be done editing the anarchy.conf file, more info [here](http://github.com/magnunleno/Anarchy/wiki/Anarchy.conf).

Then just run the anarchy.sh script with the following command:
`./anarchy.sh`

Now lie back and watch the script do all the handwork.

After the reboot you'll have a basic Arch Linux installation.

Hacking
=======

We are open for contributions, just fork the repository and submit your pull request. Also, any improvement suggestion, bug report or critic is welcome and can be done via [GitHub Issue](https://github.com/magnunleno/Anarchy/issues) or contacting any of the developers.

The Anarchy Project source code is straightforward and simple, as our favorite distribution we follow the KISS philosophy.


Credits
=======
 * [Magnun Leno](https://github.com/magnunleno)
 * [Henrique Leal](https://github.com/hmleal)

License
=======
Copyright (C) 2013 - Magnun Leno

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
