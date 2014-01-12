package PDL::Finance::TA::Perl;
use 5.10.0;
use Carp;
use PDL;
use PDL::NiceSlice;

BEGIN {
    use PDL::Exporter;
    our @ISA = qw/PDL::Exporter/;
    our $VERSION = '0.01';
    $VERSION = eval $VERSION;
    our @EXPORT;
    our @EXPORT_OK = qw(
        movavg
        expmovavg
    );
    our %EXPORT_TAGS = (Func => [@EXPORT_OK], Internal => []);
}

*movavg = \&PDL::movavg;
*expmovavg = \&PDL::expmovavg;

sub PDL::movavg($$) {
    my ($p, $N) = @_;
    unless (defined $N and $N > 0) {
        carp "argument N has to be defined and positive";
        return null;
    }
    my $kern = ones($N)/$N;
    # conv1d using wrap-around method, hence we remove the N/2 number of
    # elements from each side
    my $out = conv1d $p, $kern, { Boundary => 'reflect' };
    my $r1 = floor(($N - 1)/2);
    my $r2 = -1 - ceil(($N - 1)/2);
    return $out($r1:$r2);
}

sub PDL::expmovavg {
    my ($p, $N, $alpha) = @_;
    # if N is undefined or 0 use the maximum
    $N = $p->nelem unless $N;
    # if N < 0 then return null
    carp "argument N cannot be negative. It can be >= 0 or undef" if $N < 0;
    return null if $N < 0;
    $N = $p->nelem if $N > $p->nelem;
    $alpha = 2 / ($N + 1) unless defined $alpha;
    return $p * $alpha if $N == 1;
    my $a = ones($N) * (1 - $alpha);
    ## all elements are now (1 - K)^i for i in [0, N - 1]
    ## multiply everything by K
    my $kern = $a->power(sequence($N), 0)->(-1:0) * $alpha;
    my $out = conv1d $p, $kern, { Boundary => 'reflect' };
    my $r1 = floor(($N - 1)/2);
    my $r2 = -1 - ceil(($N - 1)/2);
    return $out($r1:$r2);
}

1;
__END__
### COPYRIGHT: 2014 Vikas N. Kumar. All Rights Reserved.
### AUTHOR: Vikas N Kumar <vikas@cpan.org>
### DATE: 3rd Jan 2014
### LICENSE: Refer LICENSE file
