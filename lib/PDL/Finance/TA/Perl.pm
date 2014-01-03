package PDL::Finance::TA::Perl;
use 5.10.0;
use PDL::Lite;
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
    my $b = pdl map { $p($_ - $N : $_ - 1)->avg } $N .. $p->nelem;
    return wantarray ? ($b, $N - 1) : $b;
}

1;
__END__
### COPYRIGHT: 2014 Vikas N. Kumar. All Rights Reserved.
### AUTHOR: Vikas N Kumar <vikas@cpan.org>
### DATE: 3rd Jan 2014
### LICENSE: Refer LICENSE file
