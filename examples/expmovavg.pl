#!/usr/bin/env perl
use strict;
use warnings;
use blib;
use feature 'say';
use File::Spec;
use PDL;
use PDL::NiceSlice;
use PDL::Finance::TA ':Func';

my $symbol = $ARGV[0] || 'YHOO';
## Let's test if the moving average function works first
if ($ENV{DEBUG}) {
    my $a = sequence 50;
    my $ma = $a->expmovavg(5);
    say $ma, "\tDims: ", $ma->dims, " NElem: ", $ma->nelem;
}

## Now let's test this on real financial data
eval 'require Finance::QuoteHist' || die "Please install the recommended ".
    "packages in Build.PL before running this example";
eval { require DateTime; require PDL::Graphics::PGPLOT::Window; };
$PDL::doubleformat = "%.6lf";

## download the stock price data for $symbol and save to a CSV file
my $tmpdir = $ENV{TEMP} || $ENV{TMP} if $^O =~ /Win32|Cygwin/i;
$tmpdir = $ENV{TMPDIR} || '/tmp' unless $^O =~ /Win32|Cygwin/i;
my $path = File::Spec->catfile($tmpdir, "$symbol.csv");
my @quotes = ();
my $data;
unless (-e $path) {
    my $fq = new Finance::QuoteHist(
        symbols => [ $symbol ],
        start_date => '1 year ago',
        end_date => 'today',
    );
    open my $fh, '>', $path or die "$!";
    foreach my $row ($fq->quotes) {
        my ($sym, $date, $o, $h, $l, $c, $vol) = @$row;
        my ($yy, $mm, $dd) = split /\//, $date;
        my $epoch = DateTime->new(
                    year => $yy,
                    month => $mm,
                    day => $dd,
                    hour => 16, minute => 0, second => 0,
                    time_zone => 'America/New_York',
                 )->epoch;
        say $fh "$epoch,$o,$h,$l,$c";
        push @quotes, pdl($epoch, $o, $h, $l, $c);
    }
    $fq->clear_cache;
    close $fh;
    say "$path has some data for analysis";
    $data = pdl(@quotes)->transpose;
} else {
    ## now read this back into a PDL using rcol
    say "$path already present. loading it...";
    $data = rcols $path, [], { COLSEP => ',', DEFTYPE => PDL::double };
}

my ($start) = $data(0, (0))->list;
my $start_day = DateTime->from_epoch(epoch => $start)->ymd;
$data(0:-1,(0)) -= $start;
if ($ENV{DEBUG}) {
    say $data(0:50,(0));
    say $data(0:50,(1));
    say $data(0:50,(1))->expmovavg(13);
}
my $win = PDL::Graphics::PGPLOT::Window->new(Device => '/xs');
# plot the close price
$win->line($data(0:-1,(0)), $data(0:-1,(4)),
    { COLOR => 'CYAN', AXIS => [ 'BCNSTZ', 'BCNST']});
$win->hold;
# plot the 21-day simple moving average of the close price
my ($N, $alpha) = (21, 0.9);
$win->line($data(0 + $N - 1:-1,(0)), $data(0:-1,(4))->movavg($N),
            { COLOR => 'YELLOW'});
# plot the 21-day exponential moving average of the close price
$win->line($data(0 + $N - 1:-1,(0)), $data(0:-1,(4))->expmovavg($N, $alpha),
            { COLOR => 'RED'});
$N = 34;
# plot the 34-day exponential moving average of the close price
$win->line($data(0 + $N - 1:-1,(0)), $data(0:-1,(4))->expmovavg($N, $alpha),
            { COLOR => 'GREEN'});
# plot the 34-day simple moving average of the close price
$win->line($data(0 + $N - 1:-1,(0)), $data(0:-1,(4))->movavg($N),
            { COLOR => 'MAGENTA'});
$win->label_axes("Days since $start_day", 'Close Price', 'Exponential Moving Average of Close Prices');
$win->legend([$symbol, '21-day EMA', '21-day SMA', '34-day EMA', '34-day SMA'],
    40, 40, { Colour => [qw/CYAN RED YELLOW GREEN MAGENTA/], XPos => 5, YPos =>
    5, Width => 'Automatic'});
$win->release;
$win->close;
