use Test::More;
use PDL;
use PDL::NiceSlice;

BEGIN { use_ok('PDL::Finance::TA'); }

can_ok('PDL::Finance::TA', 'movavg');

my $have_talib = 0;
SKIP: {
    eval { require Alien::TALib };
    skip 'Alien::TALib is not installed', 2 if $@;
    use_ok('PDL::Finance::TA::TALib');
    can_ok('PDL::Finance::TA::TALib', 'movavg');
    $have_talib = 0;
}

my $M = 50;
my $x = 10 * random($M);
my $y = $x->expmovavg(0);
isa_ok($y, 'PDL');
ok(!$y->isnull, "PDL is not null");
$y = $x->expmovavg(-5);
isa_ok($y, 'PDL');
ok($y->isnull, "PDL is null");

foreach $N (0 .. $M) {
    my $y1 = $x->expmovavg($N);
    isa_ok($y1, 'PDL');
    ok(!$y1->isnull, "PDL isn't null");
    note "pdl generated: $y1\n";
    my $NN = $N || $M;
    note "N is $NN\n";
    is($y1->nelem, $M - $NN + 1, "no. of elements is " . ($M - $NN + 1));
    my @xarr = $x->list;
    my @yarr = ();
    is(scalar @xarr, $M, "no. of elements in X is $M");

    my $alpha = 2 / ($NN + 1);
    my @powarr = map { $alpha * ((1 - $alpha) ** $_) } 0 .. ($NN - 1);
    for my $i ($NN .. scalar(@xarr)) {
        my $s = 0;
        map { $s += $powarr[$_] * $xarr[$_ + $i - $NN] } 0 .. ($NN - 1);
        push @yarr, $s;
    }
    is(scalar @yarr, $M - $NN + 1, "no. of elements is " . ($M - $NN + 1));
    my $yarrp = pdl @yarr;
    note "perl generated: $yarrp\n";
    is(all(abs($y1 - $yarrp) < 1e-12), 1, "Both PDLs are the same");

    SKIP: {
        skip 'PDL::Finance::TA::TALib will not be tested', 4 unless $have_talib;
        my ($y2) = PDL::Finance::TA::TALib::movavg($x, $N);
        isa_ok($y2, 'PDL');
        ok(!$y2->isnull, "PDL isn't null");
        note "talib generated: $y2\n";
        is($y2->nelem, $M, "no. of elements is $M");
        is(all(abs($y1 - $y2) < 1e-12), 1, "Both PDLs are the same");
    }
}

done_testing();

__END__
### COPYRIGHT: 2013 Vikas N. Kumar. All Rights Reserved.
### AUTHOR: Vikas N Kumar <vikas@cpan.org>
### DATE: 21st Mar 2013
### LICENSE: Refer LICENSE file
