package PDL::Finance::TA;
use 5.10.0;

BEGIN {
    use Exporter();
    our @ISA = qw/Exporter/;
    our $VERSION = '0.01';
    $VERSION = eval $VERSION;
    our @EXPORT;
    our @EXPORT_OK = qw(
        movavg
    );
    our %EXPORT_TAGS = (
        Func => [@EXPORT_OK],
        Internal => [],
    );
}
use PDL::Finance::TA::Perl;

*movavg = \&PDL::Finance::TA::Perl::movavg;

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
elements over which to calculate the moving average. It can be invoked in two
ways:

    use PDL;
    use PDL::Finance::TA 'movavg';
    my $ma_13 = $p->movavg(13); # the 13-day moving average
    my $ma_21 = movavg($p, 21); # the 21-day moving average

For a nice example on how to use moving averages and plot them see
L<examples/movavg.pl>.

=begin HTML

<p><img
src="http://vikasnkumar.github.io/PDL-Finance-TA/images/pgplot_movavg.png"
alt="Moving Average plot of YAHOO stock for 2013" /></p>

=end HTML

=back

=head1 COPYRIGHT

Copyright (C) 2013-2014. Vikas N Kumar <vikas@cpan.org>. All Rights Reserved.

This is free software; You can redistribute it or modify it under the terms of
Perl itself.
