use Test::More;
use PDL;
use PDL::NiceSlice;

BEGIN { use_ok('PDL::Finance::TA'); use_ok('PDL::Finance::TA::TALib'); }

can_ok('PDL::Finance::TA', 'movavg');
can_ok('PDL::Finance::TA::TALib', 'movavg');


my $x, $y1, $y2, $idx1, $idx2;

map {
my $M = 50;
my $N = $_;
$x = sequence $M;#10 * random(50);
($y1, $idx1) = PDL::Finance::TA::movavg($x, $N);
($y2, $idx2) = PDL::Finance::TA::TALib::movavg($x, $N);
isa_ok($y1, 'PDL');
isa_ok($y2, 'PDL');
is($y1->nelem, $M - $N + 1, "no. of elements is " . ($M - $N + 1));
is($y2->nelem, $M, "no. of elements is $M");
is($idx1, $N - 1, "beginning index from movavg is $idx1");
is($idx2, $N - 1, "begIdx from TA_MA in ta-lib is $idx2");
is(all(abs($y1 - $y2) < 1e-12), 1, "Both PDLs are the same");
note $y1, "\n", $y2, "\n";
} 1 .. 10;

done_testing();

__END__
### COPYRIGHT: 2013 Vikas N. Kumar. All Rights Reserved.
### AUTHOR: Vikas N Kumar <vikas@cpan.org>
### DATE: 21st Mar 2013
### LICENSE: Refer LICENSE file
