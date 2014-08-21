#Installing _App::financeta_

## Hardware Requirements

The software will perform well and fast if you're using an Intel or AMD
multi-core CPU made by them after 2007. You will benefit if you have more than
2GB RAM although the application should run within 300MB, but that depends on
how much data you're analyzing. PDL does a lot of parallel computations which
benefit with a multi-core and/or a multi-cpu system.

The software has not been tested on ARM CPU based systems, and if there are any success
reports, please let the authors know and we shall include them here.

If you want us to support a different CPU type, please contact the authors.

## Linux & BSD variants

_App::financeta_ has been developed on the GNU/Linux platform. However, it works
on the BSD platforms (FreeBSD, NetBSD, OpenBSD) as well.
You will need to have `perl` installed which is
present by default on most or all Linux and BSD platforms. The minimum Perl
version expected is 5.10.1.

#### Installing `ta-lib`

Download the source from sourceforge, compile and install it. You can also
install it to a custom directory of your choice instead of `/usr/local` but you
will need to set the environment variable `$PATH` appropriately in your shell
and your `.bashrc` or `.profile` or similar shell profile files.

    $ wget http://prdownloads.sourceforge.net/ta-lib/ta-lib-0.4.0-src.tar.gz
    $ tar -zxvf ta-lib-0.4.0-src.tar.gz
    $ cd ta-lib
    $ ./configure --prefix=/usr/local && make && make check
    $ sudo make install

#### Installing Gnuplot

Currently, the plotting engine of _App::financeta_ is
[Gnuplot](http://www.gnuplot.info) which will be
available in your distribution's package manager. If not, you can find
instructions on installing it on their [website](http://www.gnuplot.info).

#### Installing App::financeta from CPAN

Check if the `perl` and `cpan` executables are installed on your system and if
the version number of `perl` is greater than or equal to 5.10.1. If `perl`
and/or `cpan` are not installed, please consult your distribution's package
manager. The `ta-lib` that you have just installed above, needs to be present in
your `$PATH` variable if you have not installed it into `/usr/local`. The
`gnuplot` executable also should have been installed and be present in your
`$PATH` environment.

    $ which perl
    $ perl -V:version
    $ which cpan
    $ which ta-lib-config
    $ which gnuplot
    $ sudo cpan -i App::financeta
    # to run the application
    $ /usr/bin/financeta

This will install the package and all its dependencies from CPAN.
If you choose to install the CPAN package to a custom directory, you will have
to adjust the `$PERL5LIB` environment variable appropriately.

#### Installing App::financeta from Github

If you would like to get the bleeding edge of the codebase or if you want to
send us pull requests, you may want to install the development version from
[Github](https://github.com/vikasnkumar/financeta.git). You will need to have
`git` installed for this to work.

    $ which git
    $ git clone https://github.com/vikasnkumar/financeta.git
    $ cd financeta
    $ perl ./Build.PL
    $ ./Build test
    # to run the application
    $ perl -Mblib ./bin/financeta

When installing from Github, you may see that your dependencies are not
installed. To install all the required dependencies, after you have installed
`ta-lib` and `gnuplot` as above, run the below command.

    $ sudo cpan -i PDL Prima PDL::Graphics::Gnuplot Finance::QuoteHist \
        PDL::Finance::Talib POE::Loop::Prima Capture::Tiny DateTime \
        Software::License Pod::Readme Module::Build

Some of these modules may already be available through your distribution's
package manager.

## Mac OS X

There are not many differences in the installation of _App::financeta_ on the
OS X platform, except for the fact that you may be using
[Macports](http://www.macports.org), [Fink](http://finkproject.org) or
[Homebrew](http://brew.sh) as your package manager. We have tested with Macports installed on OS
X 10.7.

#### Installing using Macports and CPAN

Macports may already come with `perl` but you could install a more recent
version if you like.

    $ sudo port install ta-lib gnuplot perl5
    $ sudo cpan -i App::financeta

#### Installing using native Mac Perl

Follow the same instructions to install as for the
Linux/BSD variants [here](#linuxbsdvariants).

#### Installing using Fink or Homebrew

You may want to look at what packages these package managers provide, and use
your judgement to pick the appropriate ones as required. You could also always
just install `perl` from these package managers and follow the rest of the
instructions from [here](#linuxbsdvariants).

## Windows

**COMING SOON !**


[Back to Home](./index.html) [Next](./faq.html)
