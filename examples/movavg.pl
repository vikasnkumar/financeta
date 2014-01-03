#!/usr/bin/env perl
use strict;
use warnings;
use blib;
use feature 'say';
use PDL;
use PDL::NiceSlice;
use PDL::Finance::TA;

my $a = sequence 50;
my $ma = PDL::Finance::TA::movavg($a, 5);
say $ma;
