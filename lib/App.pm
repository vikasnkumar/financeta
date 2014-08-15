package App::financeta;
use strict;
use warnings;
use 5.10.0;

our $VERSION = '0.02';
$VERSION = eval $VERSION;

use PDL::Finance::TA;

#TODO: parse arguments and set up options
sub run {
    my $gui = PDL::Finance::TA->new(debug => 1);
    $gui->run;
}

1;
