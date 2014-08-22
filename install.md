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

There are two ways to install _App::financeta_ on Windows - using Strawberry
Perl or Cygwin. Either of these ways is alright to do, although Strawberry Perl
is definitely nicer to use. We have tested this only on Windows 7 64-bit.

### Strawberry Perl

1. Download Strawberry Perl from their [website](http://strawberryperl.com) and
install it.
- You may choose either 32 or 64 bit MSI file depending on what kind of Windows
you are running.
- You may choose to download the _PortableZIP_ version of Strawberry Perl which
includes _extra PDL related libs_ as part of it from <http://strawberryperl.com/releases.html>.

1. Download Gnuplot for Windows from [here](http://gnuplot.info/download.html).
- Select the option that says "Primary download site on Sourceforge" and pick the
_exe_ installer from Sourceforge file list.
- You will need to do the default install but remember to check the option that says add Gnuplot to the `PATH`
environment.

1. If you have downloaded the _PortableZIP_ version with _extra PDL libs_ you can
  skip this step.
    - Download _ta-lib_ for Windows from [here](http://ta-lib.org/hdr_dw.html). Select the `ta-lib-0.4.0-msvc.zip` file and download it into a directory and
unzip it.
    - You should see the `ta-lib` folder created after unzipping the file.
    - Note down the directory path. For example, if you unzip the folder in your `Documents` directory, then your path on Windows 7 will be `%USERPROFILE%\Documents\ta-lib`. The `%USERPROFILE%` environment variable automatically picks your home directory on Windows.
    - If you have installed the MSI version, start the Strawberry Perl shell from your _Start Menu_ > _Strawberry Perl_ > _Perl (commandline)_. This shell will look like the Windows command shell but with all the paths necessary for Perl to run. You will need to set the
environment variables for installing `PDL::Finance::Talib` as shown below:

Set the environment variables as below, and install the packages
    
    C:\> set TALIB_LIBS=-L%USERPROFILE%\Documents\ta-lib\c\lib -lta_abstract_cmr -lta_common_cmr -lta_func_cmr _lta_libc_cmr
    C:\> set TALIB_CFLAGS=-I%USERPROFILE%\ta-lib\c\include>
    C:\> echo %TALIB_LIBS%
    C:\> echo %TALIB_CFLAGS%
    C:\> cpan -i PDL::Finance::Talib
    C:\> cpan -i PDL::Graphics::Gnuplot
    C:\> cpan -i App::financeta

If you have used the _PortableZip_ version, you can directly install
`App::financeta` as below:

    C:\> cpan -i App::financeta

Once this is done, you can run _financeta_ either from the Perl shell or from
a regular command shell or Power shell by typing the following

    C:\> financeta.bat

### Cygwin

We assume you already have [Cygwin](https://www.cygwin.com/) installed.

Install the following packages: 

- gnuplot
- perl
- perl-libwin32
- gcc-g++
- autoconf
- automake
- tar
- wget
- libgif-devel
- libjasper-devel
- libpng-devel
- libtiff-devel
- perl-Capture-Tiny
- git
- xorg-server
- xorg-server-devel
- xorg-server-extra
- xorg-server-common
- libX11-devel
- libX11-xcb-devel
- libXext-devel
- libXfont-devel
- libXft-devel
- libXi-devel
- libXmu-devel

 and any other packages that you may want.

Install _ta-lib_ as given below:

    $ wget http://prdownloads.sourceforge.net/ta-lib/ta-lib-0.4.0-src.tar.gz
    $ tar -zxvf ta-lib-0.4.0-src.tar.gz
    $ cd ta-lib
    $ ./configure
    $ make CFLAGS=-I./include/ta_common
    $ make check
    $ make install

Once this is done, let's install `App::financeta` using `cpan`.

    $ cpan
    cpan> install App::financeta

On success, you will find `financeta` in `/usr/bin` and can start it as
below:

    $ /usr/bin/financeta


[Back to Home](./index.html) [Next](./faq.html)
