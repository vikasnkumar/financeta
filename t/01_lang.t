use Test::More;

use_ok('App::financeta::language');

my $lang = new_ok('App::financeta::language' => [ debug => 0]);
can_ok($lang, 'grammar');
can_ok($lang, 'receiver');
can_ok($lang, 'parser');
can_ok($lang, 'compile');
is($lang->compile(''), undef, 'compiler works on undefined');

my $test1 = << 'TEST1';
# --DO NOT EDIT--
# these are autogenerated comments. removing them will not regenerate them.
# default variables: open, high, low, close, volume
# MACD variables: macd, macd_signal, macd_hist
# --END OF DO NOT EDIT--
# Add your own comments here
TEST1
is($lang->compile($test1), undef, 'compiler works on comments');


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
# my $buys_i = which($macd_hist > 0 &&
#           $macd_hist->index($i1) < 0 &&
#           macd->index($i2) < macd_signal->index($i2) &&
#           macd > macd_signal
#           );
# $buys->index($buys_i) .= $open->index($buys_i);
isnt($lang->compile($test2, {
        open => 1, high => 1, low => 1, close => 1,
        macd => 1, macd_signal => 1, macd_hist => 1,
    }), undef, 'compiler can parse an instruction');

done_testing();

__END__
### COPYRIGHT: 2014 Vikas N. Kumar. All Rights Reserved.
### AUTHOR: Vikas N Kumar <vikas@cpan.org>
### DATE: 3rd Sept 2014
### LICENSE: Refer LICENSE file