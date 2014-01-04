#!/usr/bin/env perl
use strict;
use warnings;
use blib;
use feature 'say';
use File::Spec;
use PDL;
use PDL::NiceSlice;
use PDL::Finance::TA ':Func';

## Let's test if the moving average function works first
if ($ENV{DEBUG}) {
    my $a = sequence 50;
    my $ma = $a->movavg(5);
    say $ma, "\tDims: ", $ma->dims, " NElem: ", $ma->nelem;
}

## Now let's test this on real financial data
eval 'require Finance::QuoteHist' || die "Please install the recommended ".
    "packages in Build.PL before running this example";
eval { require DateTime; require PDL::Graphics::PGPLOT::Window; };
$PDL::doubleformat = "%.6lf";

## download the stock price data for YHOO and save to a CSV file
my $tmpdir = $ENV{TEMP} || $ENV{TMP} if $^O =~ /Win32|Cygwin/i;
$tmpdir = $ENV{TMPDIR} || '/tmp' unless $^O =~ /Win32|Cygwin/i;
my $path = File::Spec->catfile($tmpdir, 'YHOO.csv');
unless (-e $path) {
    my $fq = new Finance::QuoteHist(
        symbols => [qw(YHOO)],
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
    }
    $fq->clear_cache;
    close $fh;
    say "$path has some data for analysis";
}

## now read this back into a PDL using rcol
my $data = rcols $path, [], { COLSEP => ',', DEFTYPE => PDL::double };
my ($start) = $data(0, (0))->list;
my $start_day = DateTime->from_epoch(epoch => $start)->ymd;
$data(0:-1,(0)) -= $start;
if ($ENV{DEBUG}) {
    say $data(0:50,(0));
    say $data(0:50,(1));
    say $data(0:50,(1))->movavg(13);
}
my $win = PDL::Graphics::PGPLOT::Window->new(Device => '/xs');
# plot the close price
$win->line($data(0:-1,(0)), $data(0:-1,(4)),
    { COLOR => 'CYAN', AXIS => [ 'BCNSTZ', 'BCNST']});
$win->hold;
# plot the 5-day moving average of the close price
$win->line($data(0 + 5 - 1 :-1,(0)), $data(0:-1,(4))->movavg(5),
            { COLOR => 'MAGENTA'});
# plot the 13-day moving average of the close price
$win->line($data(0 + 13 - 1:-1,(0)), $data(0:-1,(4))->movavg(13),
            { COLOR => 'RED'});
# plot the 21-day moving average of the close price
$win->line($data(0 + 21 - 1:-1,(0)), $data(0:-1,(4))->movavg(21),
            { COLOR => 'YELLOW'});
$win->label_axes("Days since $start_day", 'Close Price', 'Moving Average of Close Prices');
$win->legend(['YHOO', '5-day Mov. Avg.', '13-day Mov. Avg.', '21-day Mov. Avg.'],
    40, 40, { Colour => ['CYAN', 'MAGENTA', 'RED', 'YELLOW'], XPos => 5, YPos =>
    5, Width => 'Automatic'});
$win->release;
$win->close;


