#!/usr/bin/env perl
use strict;
use warnings;
use blib;
use 5.10.0;
use feature 'say';
use Benchmark 'timethese';
use PDL;
use PDL::NiceSlice;
use PDL::Finance::TA;
use PDL::Finance::TA::TALib;

my $x = 10 * random(50000);
my $N = 13;
say "x[0:10] = ", $x(0:10);

timethese(10_000,{
    movavg_perl => sub { PDL::Finance::TA::movavg($x, $N) },
    movavg_talib => sub { PDL::Finance::TA::TALib::movavg($x, $N) }
});

