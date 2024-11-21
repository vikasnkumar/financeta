# How to use PDL::Finance::TA to develop a trading strategy

## Introduction

So you are a Perl developer and you see a lot of people make money on the stock
market and think you could do that too. You could use third party tools provided
by the trading platforms, you could use Python with its various related tools,
you could use R with its RQuantLib, you could do C++ with quantlib and other
similar methods. Maybe you want to use machine learning on the stock price data,
or want to just gamble by guessing or following the herd. TIMTOWTDI applies
here. 

But you decided you want to use Perl, so for that scenario you
can use PDL and the financial technical analysis library PDL::Finance::TA, which
wraps the TA-lib C++ library. Technical Analysis, also known sometimes by
detractors as _astrology for traders_, can be a useful way to generate buy and
sell trading signals for a stock that you may be interested in trading. It
consists of invoking a set of functions, that maybe statistical or numerical in
nature, to create _indicators_ that generate such trading signals or provide a
hint for the trader to make a trade. However, these indicators are always
lagging indicators because they cannot predict the future, they can only be
based on the past data, similar to what a machine learning model does.

That's why you see disclaimers like _past performance is not indicative of
future results_ in your broker's statements or in advertisements.

In this post, I show you how to start using PDL::Finance::TA to test out some
theories that you can experiment with. A module named App::financeta exists that
is a desktop GUI product that allows you to do this in an easier fashion without writing
any code, but for this post we describe how to develop simple functions to do
this. Maybe you want to embed this kind of functionality into a website you
already have developed.

## Pre-requisites

Let's first install all the prerequisites using `App::cpanminus`, which is what
I use on Linux. This code has been tested on Ubuntu 22.04 LTS and Debian 11. If
you find an issue on other types of Linux or on Windows, please inform me.

```bash
## you need Perl installed and Gnuplot installed.
$ sudo apt -y install gnuplot perl perl-modules cpanminus liblocal-lib-perl
## set your local Perl install to $HOME/perl5
$ mkdir -p ~/perl5/lib/perl5
### add this oneliner to the ~/.bashrc or ~/.profile for your terminal
$ eval $(perl -I ~/perl5/lib/perl5 -Mlocal::lib)
$ cpanm PDL PDL::Graphics::Gnuplot PDL::Finance::TA JSON::XS \
    LWP::UserAgent DateTime Path::Tiny
## sometimes this module does not pass the tests
$ cpanm -f Finance::QuoteHist
## check if PDL got installed
$ which pdl2
```

## Get Pricing Data from Yahoo Finance

Before we start we need to download some pricing data. You can either use Yahoo
Finance and download a CSV, or we can use a web request with
`Finance::QuoteHist`.

Below we show code to download a stock like NVDA from Yahoo Finance and convert to PDL object.

```perl
use DateTime;
use Finance::QuoteHist;
use PDL;
use PDL::NiceSlice;
my $finq = Finance::QuoteHist->new(
        symbols => ['NVDA'],
        start_date => '1 year ago',
        end_date => 'today',
        auto_proxy => 1,
        );
my @quotes = ();
foreach my $row ($finq->quotes) {
    my ($sym, $date, $o, $h, $l, $c, $vol) = @$row;
    ## date is in YYYY/MM/DD format
    my ($yy, $mm, $dd) = split /\//, $date;
    ## the data is NASDAQ/NYSE specific
    my $epoch = DateTime->new(
        year => $yy, month => $mm, day => $dd,
        hour => 16, minute => 0, second => 0,
        time_zone => 'America/New_York')->epoch;
    push @quotes, pdl($epoch, $o, $h, $l, $c, $vol);
}
$finq->clear_cache;
## convert the array of PDLs to a single 6-D PDL
my $qdata = pdl(@quotes)->transpose;
## now we operate on the $qdata PDL object

```

In simple terms, the above code downloads 1 year of open, high, low, close and
volume data for the _NVDA_ (NVIDIA) stock symbol from Yahoo Finance and is
converted to a 6-dimension PDL to be used for the next steps.

## Get Pricing Data from Gemini Exchange

If you want to trade cryptocurrencies, the Gemini Exchange provides a free
public REST API that we can use to get data from using `LWP::UserAgent`.

Here is a [link](https://docs.gemini.com/rest-api/?shell#candles) to the
_candles_ REST API for Gemini which we will be using to get the open, high, low,
close and volume data for a cryptocurrency such as DOGEUSD (Dogecoin).


```perl
use LWP::UserAgent
use PDL;
use PDL::NiceSlice;
use JSON::XS qw(decode_json);

my $url = sprintf("https://api.gemini.com/v2/candles/%s/%s", 'dogeusd', '1day');
my $lwp = LWP::UserAgent->new(timeout => 60);
$lwp->env_proxy;
my $resp = $lwp->get($url);
my $qdata;
if ($resp->is_success) {
    my $content = $resp->decoded_content;
    if (defined $content and length($content)) {
        my $jquotes = decode_json $content;
        if (ref $jquotes eq 'ARRAY' and scalar(@$jquotes)) {
            ## sort quotes by timestamp
            my @sorted = sort { $a->[0] <=> $b->[0] } @$jquotes;
            foreach my $q (@sorted) {
                ## timestamp is the first column in milliseconds
                $q->[0] /= 1000;
            }
            ## convert the quotes to a PDL
            $qdata = pdl(@sorted)->transpose;
        } else {
            warn "No quotes returned by $url";
            $qdata = undef;
        }
    } else {
        warn "No content received from $url";
        $qdata = undef;
    }
} else {
    warn "Error from request to $url: " . $resp->status_line;
    $qdata = undef;
}
## 
die "Unable to get data for dogeusd" unless ref $qdata eq 'PDL';
## now we operate on the $qdata PDL object
```

## Plot the Quotes using PDL::Graphics::Gnuplot

In this section we will use the `$qdata` variable and `PDL::Graphics::Gnuplot`
to plot the prices on a chart to view them.

```perl
use PDL;
use PDL::NiceSlice;
use PDL::Graphics::Gnuplot;
## let's assume all the data has been loaded into $qdata variable as in the
## above sections.

## create a default Gnuplot window
my $pwin = gpwin(size => [ 1024, 768, 'px' ]);
## now that the window is created, reset it anyway
$pwin->reset();
$pwin->multiplot();
$pwin->plot({
        object => '1 rectangle from screen 0,0 to screen 1,1 fillcolor rgb "black" behind',
        title => ["DOGEUSD Open-High-Low-Close", textcolor => 'rgb "white"'],
        key => ['on', 'outside', textcolor => 'rgb "yellow"'],
        border => 'linecolor rgbcolor "white"',
        xlabel => ['Date', textcolor => 'rgb "yellow"'],
        ylabel => ['Price', textcolor => 'rgb "yellow"'],
        xdata => 'time',
        xtics => {format => '%Y-%m-%d', rotate => -90, textcolor => 'orange', },
        ytics => {textcolor => 'orange'},
        label => [1, 'DOGEUSD', textcolor => 'rgb "cyan"', at => "graph 0.90,0.03"],
    },
    {
        with => 'financebars',
        linecolor => 'white',
        legend => 'Price',
    },
    $qdata(,(0)), #timestamp
    $qdata(,(1)), #open
    $qdata(,(2)), #high
    $qdata(,(3)), #low
    $qdata(,(4)), #close
    );
$pwin->end_multi;
$pwin->pause_until_close;

```

## Run Indicators

Now that we have pricing data stored in the `$qdata` variable we will show how
to use `PDL::Finance::TA` and `PDL::Graphics::Gnuplot` to generate some trading
signals and indicators.

The PDL that we have has 6 dimensions: timestamp, open price, high price, low
price, close price and trading volume. Different data providers have different
meanings for volume, but we will assume you can refer to their documentation for
more details.

First we try simple indicators like [Bollinger
Bands](https://en.wikipedia.org/wiki/Bollinger_Bands) which does a moving
average around the variable and noisy price distribution with a standard
deviation that can be configured. We will use 2 standard deviations in our code
below.

The `PDL::Finance::TA` function that implements Bolling Bands is called
`ta_bbands`. Here's how the code would look if we were to invoke this indicator
with some default values on the `$qdata` variable.

```perl
use PDL;
use PDL::NiceSlice;
use PDL::Finance::TA;

## load data as PDL into $qdata as described above

## use the close price
my $timestamp = $qdata(, (0));
my $open_px = $qdata(, (1));
my $high_px = $qdata(, (2));
my $low_px = $qdata(, (3));
my $close_px = $qdata(, (4));
## use the default values
my ($bb_upper, $bb_middle, $bb_lower) = PDL::ta_bbands($close_px, 5, 2, 2, 0);

## plot the data
my $pwin = gpwin(size => [1024, 768, 'px']);
$pwin->reset;
$pwin->multiplot;
$pwin->plot({
        object => '1 rectangle from screen 0,0 to screen 1,1 fillcolor rgb "black" behind',
        title => ["$symbol Open-High-Low-Close", textcolor => 'rgb "white"'],
        key => ['on', 'outside', textcolor => 'rgb "yellow"'],
        border => 'linecolor rgbcolor "white"',
        xlabel => ['Date', textcolor => 'rgb "yellow"'],
        ylabel => ['Price', textcolor => 'rgb "yellow"'],
        xdata => 'time',
        xtics => {format => '%Y-%m-%d', rotate => -90, textcolor => 'orange', },
        ytics => {textcolor => 'orange'},
        label => [1, $symbol, textcolor => 'rgb "cyan"', at => "graph 0.90,0.03"],
    },
    {
        with => 'financebars',
        linecolor => 'white',
        legend => 'Price',
    },
    $timestamp, $open_px, $high_px, $low_px, $close_px,
    ### Bollinger Bands plot
    {
        with => 'lines',
        axes => 'x1y1',
        linecolor => 'dark-green',
        legend => 'Bollinger Band - Upper'
    },
    $timestamp, $bb_upper, #upper band
    {
        with => 'lines',
        axes => 'x1y1',
        linecolor => 'dark-magenta',
        legend => 'Bollinger Band - Lower'
    },
    $timestamp, $bb_lower, #lower band
    $qdata(, (0)), #timestamp
    $bb_lower, #lower band
    {
        with => 'lines',
        axes => 'x1y1',
        linecolor => 'orange',
        legend => 'Bollinger Band - Middle'
    },
    $timestamp, $bb_middle, #middle band
);
$pwin->end_multi;
$pwin->pause_until_close;
```

Similarly, you can read the documentation of `PDL::Finance::TA` and pick
whatever indicators you would like to plot.

## Generate Buy or Sell Signals

Now let's take the case where we want to buy the security (whether a stock or a
cryptocurrency), when the high price crosses the upper Bollinger band and sell when
the low price crosses the lower Bollinger band.

To do that we will write the below `PDL` code.

```perl
use PDL;
use PDL::NiceSlice;
use PDL::Finance::TA;

## load data as PDL into $qdata as described above

## use the close price
my $timestamp = $qdata(, (0));
my $open_px = $qdata(, (1));
my $high_px = $qdata(, (2));
my $low_px = $qdata(, (3));
my $close_px = $qdata(, (4));
## use the default values
my ($bb_upper, $bb_middle, $bb_lower) = PDL::ta_bbands($close_px, 5, 2, 2, 0);

## generate buy and sell signals
## we want to sell at the CLOSE price when the HIGH price cuts the Upper Bollinger Band
## we want to buy at the OPEN price when the LOW price cuts the Lower Bollinger Band
my $buys            = zeroes( $close_px->dims );
my $sells           = zeroes( $close_px->dims );
## use a 1 tick lookback
my $lookback        = 1;
## calculate the indexes of the lookback PDL based on LOW price
my $idx_0           = xvals( $low_px->dims ) - $lookback;
## if the lookback index is negative set it to 0
$idx_0 = $idx_0->setbadif( $idx_0 < 0 )->setbadtoval(0);
## get the indexes of when the LOW Price < Lower Bollinger Band based on the lookback
my $idx_1 = which( 
        ($low_px->index($idx_0) > $bb_lower->index($idx_0)) &
        ($low_px < $bb_lower)
);
## set the buys to be on the OPEN price for those indexes
$buys->index($idx_1) .= $open_px->index($idx_1);
## set all 0 values to BAD to avoid plotting zeroes
$buys->inplace->setvaltobad(0);

## calculate the indexes of the lookback PDL based on HIGH price
my $idx_2 = xvals( $high_px->dims ) - $lookback;
## if the lookback index is negative set it to 0
$idx_2 = $idx_2->setbadif( $idx_2 < 0 )->setbadtoval(0);
## get the indexes of when the HIGH Price > Upper Bollinger Band based on the lookback
my $idx_3 = which(
    ($high_px->index($idx_2) < $bb_upper->index($idx_2)) &
    ($high_px > $bb_upper )
);
## set the sells to be on the CLOSE price for those indexes
$sells->index($idx_3) .= $close_px->index($idx_3);
## set all 0 values to BAD to avoid plotting zeroes
$sells->inplace->setvaltobad(0);

## plot the data
my $pwin = gpwin(size => [1024, 768, 'px']);
$pwin->reset;
$pwin->multiplot;
$pwin->plot({
        object => '1 rectangle from screen 0,0 to screen 1,1 fillcolor rgb "black" behind',
        title => ["$symbol Open-High-Low-Close", textcolor => 'rgb "white"'],
        key => ['on', 'outside', textcolor => 'rgb "yellow"'],
        border => 'linecolor rgbcolor "white"',
        xlabel => ['Date', textcolor => 'rgb "yellow"'],
        ylabel => ['Price', textcolor => 'rgb "yellow"'],
        xdata => 'time',
        xtics => {format => '%Y-%m-%d', rotate => -90, textcolor => 'orange', },
        ytics => {textcolor => 'orange'},
        label => [1, $symbol, textcolor => 'rgb "cyan"', at => "graph 0.90,0.03"],
    },
    {
        with => 'financebars',
        linecolor => 'white',
        legend => 'Price',
    },
    $timestamp,
    $open_px,
    $high_px,
    $low_px,
    $close_px,
    ### Bollinger Bands plot
    {
        with => 'lines',
        axes => 'x1y1',
        linecolor => 'dark-green',
        legend => 'Bollinger Band - Upper'
    },
    $timestamp,
    $bb_upper, #upper band
    {
        with => 'lines',
        axes => 'x1y1',
        linecolor => 'dark-magenta',
        legend => 'Bollinger Band - Lower'
    },
    $timestamp,
    $bb_lower, #lower band
    {
        with => 'lines',
        axes => 'x1y1',
        linecolor => 'orange',
        legend => 'Bollinger Band - Middle'
    },
    $timestamp,
    $bb_middle, #middle band
    {
        with => 'points',
        pointtype => 5, #triangle
        linecolor => 'green',
        legend => 'Buys',
    },
    $timestamp,
    $buys,
    {
        with => 'points',
        pointtype => 7, #inverted triangle
        linecolor => 'red',
        legend => 'Sells',
    },
    $timestamp,
    $sells,
);
$pwin->end_multi;
$pwin->pause_until_close;
```

## Final Script

So let's aggregate all the code into one script and it looks like below. We have moved the data retrieval into a simple
function `get_data()` that does not make web requests unnecessarily. You can copy this code and run it as is in the
shell and it will plot a Gnuplot window as seen in the screenshot image linked below.

```perl
#!/usr/bin/env perl
use strict;
use warnings;
use PDL;
use PDL::NiceSlice;
use PDL::Finance::TA;
use PDL::Graphics::Gnuplot;
use JSON::XS qw(decode_json);
use LWP::UserAgent;
use DateTime;
use Try::Tiny;
use Path::Tiny;

sub get_data($) {
    my $symbol = shift;
    my $filename = lc "$symbol.json";
    my $content;
    my $qdata;
    my $url = sprintf("https://api.gemini.com/v2/candles/%s/%s", lc $symbol, '1day');
    if (-e $filename) {
        print "Found $filename, loading data from that\n";
        $content = path($filename)->slurp;
    } else {
        my $lwp = LWP::UserAgent->new(timeout => 60);
        $lwp->env_proxy;
        my $resp = $lwp->get($url);
        if ($resp->is_success) {
            $content = $resp->decoded_content;
            path($filename)->spew($content);
        } else {
            warn "Error from request to $url: " . $resp->status_line;
            return undef;
        }
    }
    if (defined $content and length($content)) {
        my $jquotes = decode_json $content;
        if (ref $jquotes eq 'ARRAY' and scalar(@$jquotes)) {
            ## sort quotes by timestamp
            my @sorted = sort { $a->[0] <=> $b->[0] } @$jquotes;
            foreach my $q (@sorted) {
                ## timestamp is the first column in milliseconds
                $q->[0] /= 1000;
            }
            ## convert the quotes to a PDL
            $qdata = pdl(@sorted)->transpose;
        } else {
            warn "No quotes returned by $url or $filename";
            $qdata = undef;
        }
    } else {
        warn "No content received from $url or $filename";
        $qdata = undef;
    }
    ## now we operate on the $qdata PDL object
    return $qdata;
}

my $symbol = $ARGV[0] // 'DOGEUSD';
my $qdata = get_data($symbol);
die "Unable to get data for $symbol" unless ref $qdata eq 'PDL';
print $qdata;

my $timestamp = $qdata(, (0));
my $open_px = $qdata(, (1));
my $high_px = $qdata(, (2));
my $low_px = $qdata(, (3));
my $close_px = $qdata(, (4));
## use the default values
## each of these are 1-D PDLs
my ($bb_upper, $bb_middle, $bb_lower) = PDL::ta_bbands($close_px, 5, 2, 2, 0);
my $buys            = zeroes( $close_px->dims );
my $sells           = zeroes( $close_px->dims );
## use a 1 tick lookback
my $lookback        = 1;
## calculate the indexes of the lookback PDL based on LOW price
my $idx_0           = xvals( $low_px->dims ) - $lookback;
## if the lookback index is negative set it to 0
$idx_0 = $idx_0->setbadif( $idx_0 < 0 )->setbadtoval(0);
## get the indexes of when the LOW Price < Lower Bollinger Band based on the lookback
my $idx_1 = which( 
        ($low_px->index($idx_0) > $bb_lower->index($idx_0)) &
        ($low_px < $bb_lower)
);
## set the buys to be on the OPEN price for those indexes
$buys->index($idx_1) .= $open_px->index($idx_1);
## set all 0 values to BAD to avoid plotting zeroes
$buys->inplace->setvaltobad(0);

## calculate the indexes of the lookback PDL based on HIGH price
my $idx_2 = xvals( $high_px->dims ) - $lookback;
## if the lookback index is negative set it to 0
$idx_2 = $idx_2->setbadif( $idx_2 < 0 )->setbadtoval(0);
## get the indexes of when the HIGH Price > Upper Bollinger Band based on the lookback
my $idx_3 = which(
    ($high_px->index($idx_2) < $bb_upper->index($idx_2)) &
    ($high_px > $bb_upper )
);
## set the sells to be on the CLOSE price for those indexes
$sells->index($idx_3) .= $close_px->index($idx_3);
## set all 0 values to BAD to avoid plotting zeroes
$sells->inplace->setvaltobad(0);

## plot the data
my $pwin = gpwin(size => [1024, 768, 'px']);
$pwin->reset;
$pwin->multiplot;
$pwin->plot({
        object => '1 rectangle from screen 0,0 to screen 1,1 fillcolor rgb "black" behind',
        title => ["$symbol Open-High-Low-Close", textcolor => 'rgb "white"'],
        key => ['on', 'outside', textcolor => 'rgb "yellow"'],
        border => 'linecolor rgbcolor "white"',
        xlabel => ['Date', textcolor => 'rgb "yellow"'],
        ylabel => ['Price', textcolor => 'rgb "yellow"'],
        xdata => 'time',
        xtics => {format => '%Y-%m-%d', rotate => -90, textcolor => 'orange', },
        ytics => {textcolor => 'orange'},
        label => [1, $symbol, textcolor => 'rgb "cyan"', at => "graph 0.90,0.03"],
    },
    {
        with => 'financebars',
        linecolor => 'white',
        legend => 'Price',
    },
    $timestamp,
    $open_px,
    $high_px,
    $low_px,
    $close_px,
    ### Bollinger Bands plot
    {
        with => 'lines',
        axes => 'x1y1',
        linecolor => 'dark-green',
        legend => 'Bollinger Band - Upper'
    },
    $timestamp,
    $bb_upper, #upper band
    {
        with => 'lines',
        axes => 'x1y1',
        linecolor => 'dark-magenta',
        legend => 'Bollinger Band - Lower'
    },
    $timestamp,
    $bb_lower, #lower band
    {
        with => 'lines',
        axes => 'x1y1',
        linecolor => 'orange',
        legend => 'Bollinger Band - Middle'
    },
    $timestamp,
    $bb_middle, #middle band
    {
        with => 'points',
        pointtype => 5, #triangle
        linecolor => 'green',
        legend => 'Buys',
    },
    $timestamp,
    $buys,
    {
        with => 'points',
        pointtype => 7, #inverted triangle
        linecolor => 'red',
        legend => 'Sells',
    },
    $timestamp,
    $sells,
);
$pwin->end_multi;
$pwin->pause_until_close;

```

