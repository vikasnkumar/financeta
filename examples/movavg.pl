#!/usr/bin/env perl
use strict;
use warnings;
use blib;
use feature 'say';
use PDL;
use PDL::NiceSlice;
use PDL::Finance::TA ':Func';

my $a = sequence 50;
my $ma = $a->movavg(5);
say $ma;
say "Dims: ", $ma->dims, " NElem: ", $ma->nelem;
