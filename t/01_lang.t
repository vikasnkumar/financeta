use strict;
use warnings;
use Test::More;

use_ok('App::financeta::language');

sub coderef_check {
    my $lang = shift;
    my $output = shift;
    my $coderef = $lang->generate_coderef($output);
    is(ref $coderef, 'CODE', 'can eval output into a code-ref') or
    diag("\$coderef is $coderef");
}

my $lang = new_ok( 'App::financeta::language' => [ debug => 0 ] );
can_ok( $lang, 'grammar' );
can_ok( $lang, 'receiver' );
can_ok( $lang, 'parser' );
can_ok( $lang, 'compile' );
can_ok( $lang, 'generate_coderef' );
can_ok( $lang, 'get_grammar_regexes');
my $gregexes= $lang->get_grammar_regexes;
is(ref $gregexes, 'HASH', 'keywords is a hash');
is( $lang->compile(''), undef, 'compiler works on undefined' );

my $test1 = << 'TEST1';
# --DO NOT EDIT--
# these are autogenerated comments. removing them will not regenerate them.
# default variables: open, high, low, close, volume
# MACD variables: macd, macd_signal, macd_hist
# --END OF DO NOT EDIT--
# Add your own comments here
TEST1
is( $lang->compile($test1), undef, 'compiler works on comments' );

my $test2 = << 'TEST2';
# --DO NOT EDIT--
# these are autogenerated comments. removing them will not regenerate them.
# default variables: open, high, low, close, volume
# MACD variables: macd, macd_signal, macd_hist
# --END OF DO NOT EDIT--
# Add your own comments here
buy at $open WHEN $macd_hist becomes positive and $macd CROSSES $macd_signal FROM BELOW;
TEST2
####
# macd_hist becomes positive => macd_hist[i] > 0 && macd_hist[i - L1] < 0
# macd crosses macd_signal from below => macd[i - L2] < macd_signal[i - L2] && macd[i] > macd_signal[i]
# buy at $open => $buy = $open
# actual code in PDL
# my $i1 = xvals($macd_hist->dims) - $L1;
# $i1 = $i1->setbadif($i1 < 0)->setbadtoval(0);
# my $i2 = xvals($macd_hist->dims) - $L2;
# $i2 = $i2->setbadif($i2 < 0)->setbadtoval(0);
# my $buys = zeroes($macd_hist->dims);
# my $buys_i = which($macd_hist > 0 &
#           $macd_hist->index($i1) < 0 &
#           macd->index($i2) < macd_signal->index($i2) &
#           macd > macd_signal
#           );
# $buys->index($buys_i) .= $open->index($buys_i);
my $expected2_src = <<'EXPECTED';
use PDL;
use PDL::NiceSlice;
sub  {
    my $open = shift;
    my $high = shift;
    my $low = shift;
    my $close = shift;
    my $macd = shift;
    my $macd_signal = shift;
    my $macd_hist = shift;
my $buys     = zeroes( $close->dims );
my $sells    = zeroes( $close->dims );
my $lookback = 1;
my $idx_0    = xvals( $macd_hist->dims ) - $lookback;
$idx_0 = $idx_0->setbadif( $idx_0 < 0 )->setbadtoval(0);
my $idx_1 = xvals( $macd->dims ) - $lookback;
$idx_1 = $idx_1->setbadif( $idx_1 < 0 )->setbadtoval(0);
my $idx_2 = which( ($macd_hist >= 0.000001)
      & ($macd_hist->index($idx_0) < 0.000001)
      & ($macd->index($idx_1) < $macd_signal->index($idx_1))
      & ($macd > $macd_signal) );
$buys->index($idx_2) .= $open->index($idx_2);
return { buys => $buys, sells => $sells, long => 1, short => 0 };
}
EXPECTED
my $expected2;
Perl::Tidy::perltidy(source => \$expected2_src, destination => \$expected2);
my $output2 = $lang->compile(
    $test2,
    [qw/
        open
        high
        low
        close
        macd
        macd_signal
        macd_hist
    /]
);
isnt( $output2, undef, 'compiler can parse an instruction' );
note($output2);
is( $output2, $expected2, 'compiler output matches expected output' );
coderef_check($lang, $output2);

my $test3 = << 'TEST3';
  ### START OF AUTOGENERATED CODE - DO NOT EDIT
  ### The list of variables that you can use is below:

  ### $open

  ### $high

  ### $low

  ### $close

  ### $macd

  ### $macd_signal

  ### $macd_hist

  ### END OF AUTOGENERATED CODE

  sell at $high WHEN $macd_hist becomes negative and $macd CROSSES $macd_signal
    FROM ABOVE;
TEST3
####
# macd_hist becomes negative => macd_hist[i] < 0 & macd_hist[i - L1] > 0
# macd crosses macd_signal from above => macd[i - L2] > macd_signal[i - L2] & macd[i] < macd_signal[i]
# sell at $high => $sell = $high
my $expected3_src = << 'EXPECTED';
use PDL;
use PDL::NiceSlice;
sub  {
    my $open = shift;
    my $high = shift;
    my $low = shift;
    my $close = shift;
    my $macd = shift;
    my $macd_signal = shift;
    my $macd_hist = shift;
my $buys     = zeroes( $close->dims );
my $sells    = zeroes( $close->dims );
my $lookback = 1;
my $idx_0    = xvals( $macd_hist->dims ) - $lookback;
$idx_0 = $idx_0->setbadif( $idx_0 < 0 )->setbadtoval(0);
my $idx_1 = xvals( $macd->dims ) - $lookback;
$idx_1 = $idx_1->setbadif( $idx_1 < 0 )->setbadtoval(0);
my $idx_2 = which( ($macd_hist <= -0.000001)
& ($macd_hist->index($idx_0) > -0.000001)
& ($macd->index($idx_1) > $macd_signal->index($idx_1))
& ($macd < $macd_signal) );
$sells->index($idx_2) .= $high->index($idx_2);
return { buys => $buys, sells => $sells, long => 1, short => 0 };
}
EXPECTED
my $expected3;
Perl::Tidy::perltidy(source => \$expected3_src, destination => \$expected3);
my $output3 = $lang->compile($test3,
    [qw/
        open
        high
        low
        close
        macd
        macd_signal
        macd_hist
    /]
);
isnt( $output3, undef, 'compiler can parse an instruction' );
note($output3);
is( $output3, $expected3, 'compiler output matches expected output' );
coderef_check($lang, $output3);

my $test4 = << 'TEST4';
### START OF AUTOGENERATED CODE - DO NOT EDIT
#### The list of variables that you can use is below:
#### $open
#### $high
#### $low
#### $close
#### $bbands_upper_5
#### $bbands_middle_5
#### $bbands_lower_5
#### $macd_12_26_9
#### $macdsig_12_26_9
#### $macdhist_12_26_9
#### END OF AUTOGENERATED CODE
buy at $open WHEN $macdhist_12_26_9
  becomes positive AND $macd_12_26_9 crosses $macdsig_12_26_9 from BELOW;
sell at
  $high WHEN $macdhist_12_26_9 becomes negative AND $macd_12_26_9 crosses $macdsig_12_26_9
  from above;
TEST4
my $output4 = $lang->compile($test4, [qw/
open
high
low
close
bbands_upper_5
bbands_middle_5
bands_lower_5
macd_12_26_9
macdsig_12_26_9
macdhist_12_26_9
/]);
isnt($output4, undef, 'compiler can parse rules');
note($output4);
coderef_check($lang, $output4);

my $test5 = << 'TEST5';
### START OF AUTOGENERATED CODE - DO NOT EDIT
#### The list of variables that you can use is below:
#### $open
#### $high
#### $low
#### $close
#### $bbands_upper_5
#### $bbands_middle_5
#### $bbands_lower_5
#### $rsi_14
#### $macd_12_26_9
#### $macdsig_12_26_9
#### $macdhist_12_26_9
#### END OF AUTOGENERATED CODE
buy at $open WHEN $macdhist_12_26_9
  becomes positive AND $macd_12_26_9 crosses $macdsig_12_26_9 from BELOW and
  $rsi_14 > 30;
sell at
  $high WHEN $macdhist_12_26_9 becomes negative AND $macd_12_26_9 crosses $macdsig_12_26_9
  from above;
TEST5
my $output5 = $lang->compile($test5, [qw/
open
high
low
close
bbands_upper_5
bbands_middle_5
bands_lower_5
rsi_14
macd_12_26_9
macdsig_12_26_9
macdhist_12_26_9
/]);
isnt($output5, undef, 'compiler can parse rules');
note($output5);
coderef_check($lang, $output5);

# end of testing
done_testing();
__END__
### COPYRIGHT: 2013-2023. Vikas N. Kumar. All Rights Reserved.
### AUTHOR: Vikas N Kumar <vikas@cpan.org>
### DATE: 3rd Sept 2014
### LICENSE: Refer LICENSE file
