#!/usr/bin/env perl

use strict;
use warnings;
use PDL::Lite;
use PDL::Core;
use PDL::Basic;
use PDL::NiceSlice;

my $a = ones(100, 4) + sequence(100, 4) * 0.05;
print $a, "\n";

thread_define 'bsell(o(n);h(n);l(n);c(n); [o]z(n))', over {
    $_[4] .= $_[3] > (($_[3] + $_[0] + $_[1] + $_[2]) / 4);
};

my $b = ones(100);
bsell($a(,(0)), $a(,(1)), $a(,(2)), $a(,(3)), $b);
print $b, "\n";
