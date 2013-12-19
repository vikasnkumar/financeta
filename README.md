# PDL-Finance-TA

Copyright: 2013, Vikas N Kumar <vikas@cpan.org>. All Rights Reserved.

`PDL::Finance::TA` is a Technical Analysis library wrapper around `ta-lib` from
<http://ta-lib.org> for the Perl Data Language (PDL).

## INSTALLATION

To build this module do the following:

    perl ./Build.PL
    ./Build
    ./Build test
    ./Build install

To force the rebuilding of the `PDL::PP` modules for any reason you can run the
following command during the build

    ./Build forcepdlpp

To install in a custom directory you can do the following:

    perl ./Build.PL --install_base=/path/to/custom/directory
    ./Build
    ./Build test
    ./Build install
