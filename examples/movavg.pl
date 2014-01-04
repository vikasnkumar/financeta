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
my $a = sequence 50;
my $ma = $a->movavg(5);
say $ma;
say "Dims: ", $ma->dims, " NElem: ", $ma->nelem;

## Now let's test this on real financial data
eval 'require Finance::QuoteHist' || exit 0;
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
}

## now read this back into a PDL using rcols
my $data = rcols $path, [], { COLSEP => ',', DEFTYPE => PDL::double };
say $data(0:10);

my $N = 13;
my $win = PDL::Graphics::PGPLOT::Window->new(Device => '/xs');
$win->line($data(,(0)), $data(,(4)));
$win->hold;
$win->line($data($N - 1:-1,(0)), $data(,(4))->movavg($N));
$win->close;


