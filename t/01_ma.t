use Test::More;
use PDL;
use PDL::NiceSlice;

BEGIN { use_ok('PDL::Finance::TA'); }

can_ok('PDL::Finance::TA', 'MA');

my $x = sequence 50;
my ($y, $idx) = PDL::Finance::TA::MA($x, 5);
isa_ok($y, 'PDL');
is($idx, 4, "begIdx from TA_MA in ta-lib is $idx");
note $x->($idx:), "\n";
note $y, "\n";

done_testing();

__END__
### COPYRIGHT: 2013 Vikas N. Kumar. All Rights Reserved.
### AUTHOR: Vikas N Kumar <vikas@cpan.org>
### DATE: 21st Mar 2013
### LICENSE: Refer LICENSE file
