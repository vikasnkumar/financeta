package PDL::Finance::TA;
use strict;
use warnings;
use 5.10.0;

our $VERSION = '0.02';
$VERSION = eval $VERSION;

use PDL::Finance::TA::Mo;
use Carp;

1;
__END__
### COPYRIGHT: 2014 Vikas N. Kumar. All Rights Reserved.
### AUTHOR: Vikas N Kumar <vikas@cpan.org>
### DATE: 3rd Jan 2014
### LICENSE: Refer LICENSE file

=head1 NAME

PDL::Finance::TA

=head1 SYNOPSIS

PDL::Finance::TA is a perl module allowing the user to perform technical
analysis on financial data stored as PDLs.

=head1 VERSION

0.01

=head1 METHODS

=over

=item B<movavg $p, $N>

The C<movavg()> function takes two arguments, a pdl object and the number of
elements over which to calculate the simple moving average. It can be invoked in two
ways:

    use PDL;
    use PDL::Finance::TA 'movavg';
    my $ma_13 = $p->movavg(13); # the 13-day moving average
    my $ma_21 = movavg($p, 21); # the 21-day moving average

For a nice example on how to use moving averages and plot them see
I<examples/movavg.pl>.

=begin HTML

<p><img
src="http://vikasnkumar.github.io/PDL-Finance-TA/images/pgplot_movavg.png"
alt="Simple Moving Average plot of YAHOO stock for 2013" /></p>

=end HTML

=item B<expmovavg $p, $N, $alpha>

The C<expmovavg()> function takes three arguments, a pdl object, the number of
elements over which to calculate the exponential moving avergage and the
exponent to use to calculate the moving average. If the number of elements is 0
or C<undef> then all the elements are used to calculate the value. If the
exponent argument is C<undef>, the value of (2 / (N + 1)) is assumed.

For a nice example on how to use and compare exponential moving average to the
simple moving average look at I<examples/expmovavg.pl>.

=begin HTML

<p><img
src="http://vikasnkumar.github.io/PDL-Finance-TA/images/pgplot_expmovavg.png"
alt="Exponential Moving Average plot of YAHOO stock for 2013" /></p>

=end HTML

=back

=head1 COPYRIGHT

Copyright (C) 2013-2014. Vikas N Kumar <vikas@cpan.org>. All Rights Reserved.

=head1 LICENSE

This is free software. You can redistribute it or modify it under the terms of
Perl itself. Refer LICENSE file in the top level source directory for more
information.
