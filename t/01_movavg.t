use Test::More;
use PDL;
use PDL::NiceSlice;

BEGIN { use_ok('PDL::Finance::TA'); use_ok('PDL::Finance::TA::TALib'); }

can_ok('PDL::Finance::TA', 'movavg');
can_ok('PDL::Finance::TA::TALib', 'movavg');

my $x = 10 * random(50);
my ($y1, $idx1) = PDL::Finance::TA::movavg($x, 5);
my ($y2, $idx2) = PDL::Finance::TA::TALib::movavg($x, 5);
isa_ok($y1, 'PDL');
isa_ok($y2, 'PDL');
is($idx1, 4, "beginning index from movavg is $idx1");
is($idx2, 4, "begIdx from TA_MA in ta-lib is $idx2");
is(all(abs($y1 - $y2) < 1e-12), 1, "Both PDLs are the same");
is($y1->nelem, 46, "no. of elements is 47");
note $y1, "\n", $y2, "\n";

done_testing();

__END__
### COPYRIGHT: 2013 Vikas N. Kumar. All Rights Reserved.
### AUTHOR: Vikas N Kumar <vikas@cpan.org>
### DATE: 21st Mar 2013
### LICENSE: Refer LICENSE file
