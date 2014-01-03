package PDL::Finance::TA::Perl;
use 5.10.0;
use PDL;
use PDL::NiceSlice;

BEGIN {
    use Exporter();
    our @ISA = qw/Exporter/;
    our $VERSION = '0.01';
    $VERSION = eval $VERSION;
}

our @EXPORT = qw(
    movavg
);

sub movavg($$) {
    my ($p, $N) = @_;
    return null unless $N > 0;
    my $kern = ones($N)/$N;
    my $b = conv1d $p, $kern;
    my $r1 = floor($N/2);
    my $r2 = $p->nelem - $N + $r1;
    return ($b($r1:$r2), $N - 1);
}

1;
__END__
### COPYRIGHT: 2014 Vikas N. Kumar. All Rights Reserved.
### AUTHOR: Vikas N Kumar <vikas@cpan.org>
### DATE: 3rd Jan 2014
### LICENSE: Refer LICENSE file
