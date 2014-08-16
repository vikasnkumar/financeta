package App::financeta;
use strict;
use warnings;
use 5.10.0;

our $VERSION = '0.02';
$VERSION = eval $VERSION;

use PDL::Finance::TA;

sub print_warning {
    my $license = <<'LICENSE';
    App::financeta  Copyright (C) 2014  Vikas N Kumar <vikas@cpan.org>
    This program comes with ABSOLUTELY NO WARRANTY; for details read the LICENSE
    file in the distribution.
    This is free software, and you are welcome to redistribute it
    under certain conditions.
    The developers are not responsible for any profits or losses due to use of this software.
    Use at your own risk and with your own intelligence.
LICENSE
    print STDERR "$license\n";
}
#TODO: parse arguments and set up options
sub run {
    my @args = @_;
    my $gui = PDL::Finance::TA->new(debug => 0);
    $gui->run;
}

1;
