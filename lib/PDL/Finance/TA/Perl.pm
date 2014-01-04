package PDL::Finance::TA::Perl;
use 5.10.0;
use PDL;
use PDL::NiceSlice;

BEGIN {
    use PDL::Exporter;
    our @ISA = qw/PDL::Exporter/;
    our $VERSION = '0.01';
    $VERSION = eval $VERSION;
    our @EXPORT;
    our @EXPORT_OK = qw/movavg/;
    our %EXPORT_TAGS = (Func => [@EXPORT_OK], Internal => []);
}

*movavg = \&PDL::movavg;

sub PDL::movavg($$) {
    my ($p, $N) = @_;
    return null unless $N > 0;
    my $kern = ones($N)/$N;
    # conv1d using wrap-around method, hence we remove the N/2 number of
    # elements from each side
    my $b = conv1d $p, $kern;
    my $r1 = floor(($N - 1)/2);
    my $r2 = -1 - ceil(($N - 1)/2);
    return $b($r1:$r2);
}

1;
__END__
### COPYRIGHT: 2014 Vikas N. Kumar. All Rights Reserved.
### AUTHOR: Vikas N Kumar <vikas@cpan.org>
### DATE: 3rd Jan 2014
### LICENSE: Refer LICENSE file
