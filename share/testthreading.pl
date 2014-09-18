#!/usr/bin/env perl

use strict;
use warnings;
use PDL;
use PDL::NiceSlice;


thread_define 'test1(x(n);i(n);[o]z(n))', over {
    my ($x, $i, $z) = @_;
    $z .= ($x > $x->index($i)) * 3.14159;
};

thread_define 'test2(x(n);[o]z(n))', over {
    my ($x, $z) = @_;
    my $i = xvals($x->dims) - 1;
    $i = $i->setbadif($i < 0)->setbadtoval(0);
    $z .= 3.14159 * ($x > $x->index($i));
};

my $a = randsym 20;
print $a, "\n";

# pre-generate the indexing and then send to function
my $i = xvals($a->dims) - 1;
$i = $i->setbadif($i < 0)->setbadtoval(0);
print $a->index($i), "\n";
my $b; test1($a, $i, $b = null);
print $b, "\n";

# have the function handle the indexing
my $c; test2($a, $c = null);
print $c, "\n";

my $d = zeroes($a->dims);
my $d_i =  $d->where($a > $a->index($i));
$d_i .= 3.14159;
print $d, "\n";
