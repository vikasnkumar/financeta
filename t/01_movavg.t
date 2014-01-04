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
    $have_talib = 1;
}

my $M = 50;
my $x = 10 * random($M);
my $y = $x->movavg(0);
isa_ok($y, 'PDL');
ok($y->isnull, "PDL is null");
$y = $x->movavg(-5);
isa_ok($y, 'PDL');
ok($y->isnull, "PDL is null");

foreach $N (1 .. 10) {
    my $y1 = $x->movavg($N);
    isa_ok($y1, 'PDL');
    is($y1->nelem, $M - $N + 1, "no. of elements is " . ($M - $N + 1));
    note $y1, "\n";
    SKIP: {
        skip 'PDL::Finance::TA::TALib will not be tested', 4 unless $have_talib;
        my ($y2) = PDL::Finance::TA::TALib::movavg($x, $N);
        isa_ok($y2, 'PDL');
        is($y2->nelem, $M, "no. of elements is $M");
        is(all(abs($y1 - $y2) < 1e-12), 1, "Both PDLs are the same");
        note $y2, "\n";
    }
}

done_testing();

__END__
### COPYRIGHT: 2013 Vikas N. Kumar. All Rights Reserved.
### AUTHOR: Vikas N Kumar <vikas@cpan.org>
### DATE: 21st Mar 2013
### LICENSE: Refer LICENSE file
