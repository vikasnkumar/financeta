#!/usr/bin/env perl

use strict;
use warnings;
use feature 'say';
use PDL;
use PDL::NiceSlice;

thread_define 'test1(x(n);i(n);[o]z(n))', over {
    my ( $x, $i, $z ) = @_;
    $z .= ( $x > $x->index($i) ) * $x;
};

thread_define 'test2(x(n);[o]z(n))', over {
    my ( $x, $z ) = @_;
    my $i = xvals( $x->dims ) - 1;
    $i = $i->setbadif( $i < 0 )->setbadtoval(0);
    $z .= $x * ( $x > $x->index($i) );
};

if (0) {
    my $a = randsym 20;
    say $a;

    # pre-generate the indexing and then send to function
    my $i = xvals( $a->dims ) - 1;
    $i = $i->setbadif( $i < 0 )->setbadtoval(0);
    say $a->index($i);
    my $b;
    test1( $a, $i, $b = null );
    say $b;

    # have the function handle the indexing
    my $c;
    test2( $a, $c = null );
    say $c;

    my $d = zeroes( $a->dims );
    my $d_i = which( ( $a > 0.5 ) & ( $a->index($i) < 0.5 ) );
    say $d_i;
    $d->index($d_i) .= $a->index($d_i);
    say $d;
}

my ( $buys, $sells );
$buys = pdl(
    [
        qw(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
          0 0 0 2.778295 0 0 3.442582 0 0 3.118481 0 0 0 0 0 0 0 0 0 0 0 0 0 0
          3.118659 0 0 0 0 0 0 0 2.993371 0 0 0 0 0 0 0 3.099485 0 0 2.527537 0 0
          0 0 0 0 0 0 0 2.981708 0 2.932249 0 0 0 0 0 0 0 0 0 0 0 3.444964 0 0 0 0
          0 2.664758 0 0 0 0 0 2.543306 0 0 0 0 0 3.141515 0 0 3.364287 0 0 0 0 0
          0 0 0 0 2.572373 0 0 0 0 0 0 0 2.953769 0 2.862077 0 0 0 2.710273 0 0 0
          0 0 0 0 3.385658 0 0 0 0 3.108515 0 0 0 0 0 0 0 0 0 0 0 3.206189 0 0 0 0
          0 0 0 3.207604 0 0 0 0 0 0 3.351229 0 0 3.412056 0 3.289393 0 0 0 0 0 0
          2.835845 0 0 0 0 0 3.418003 0 0 0 0 3.275704 0 0 0 0 0 0 0 2.909404 0 0
          3.118672 0 0 3.409433 0 0 0 0 0 0 3.063403 0 2.656575 0 0 0 0 0 3.492635
          0 3.124842 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2.581690 0 0 0 0 0 0 0
          0 0 0 0 0 0 0 3.367341 0 2.603921 0 0 0 0 3.228272 0 0 0 0 0 0 0
          2.872926 0 0 0 0 0 3.370120 0 0 0 0 0)
    ]
);
$sells = pdl(
    [
        qw(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
          3.261372 0 3.284715 0 0 0 0 0 0 0 0 0 2.850560 0 0 0 0 0 0 0 3.135597 0 0 0 0
          0 0 0 0 0 0 0 0 0 3.382890 0 3.447057 0 0 0 0 0 0 2.806718 0 0 0 0 0 3.208396
          0 0 0 0 0 3.398771 0 0 0 0 0 0 0 0 0 0 0 3.185080 0 0 0 3.126663 0 0 0 0
          2.754486 0 0 0 0 2.635109 0 0 0 0 0 0 0 0 2.902307 0 0 0 0 2.954098 0 0 0 0 0
          0 2.990395 0 3.021950 0 0 0 0 0 0 0 3.009390 0 0 0 0 2.789942 0 0 0 0 0 0 0 0
          0 0 0 3.463290 0 0 0 0 2.981719 0 0 0 0 0 0 0 0 0 0 2.961715 0 0 0 3.399410 0
          3.062245 0 0 3.038278 0 0 0 0 0 0 0 0 2.524785 0 0 0 3.339499 0 0 0 0 2.975152
          0 0 0 0 0 0 0 3.443243 0 0 2.878604 0 2.703376 0 0 0 0 0 0 3.248159 0 0
          2.908090 0 0 0 0 3.464145 0 0 0 0 0 0 0 0 0 0 0 2.744324 0 0 0 0 0 0 0 0 0 0 0
          0 0 0 2.673235 0 0 0 0 0 0 0 0 0 2.653593 0 0 0 0 3.164421 0 0 0 0 0 2.916180
          0 0 0 0 0 2.564131 0 0 0 0 0 3.232372 0 0)
    ]
);
pnl_calculator( $buys, $sells );
$buys = pdl(
    [
        qw(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
          0 0 0 0 0 0 0 0 0 0 2.812647 0 0 0 0 0 3.040474 0 0 2.527565 0 0 0 0 2.698336
          0 0 0 0 0 0 0 0 0 3.193923 0 0 0 0 3.449491 0 0 0 2.675559 0 3.287885 0 0 0 0
          0 0 3.288014 0 0 3.066657 0 0 0 0 0 0 0 0 3.174554 0 0 0 0 0 0 2.861274 0 0 0
          0 0 2.999193 0 0 0 3.408314 0 0 0 0 0 0 0 2.781351 0 0 0 0 0 0 3.135890 0 0 0
          0 0 0 3.179554 0 0 3.418450 0 0 0 0 0 0 0 0 0 0 0 0 0 2.794567 0 0 0 0 0 0 0 0
          3.301169 0 0 2.572794 0 0 2.625594 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
          2.991164 0 0 0 0 0 0 0 0 0 0 3.231574 0 0 0 0 0 0 0 0 0 0 0 0 0 3.120943 0 0
          2.613636 0 0 0 0 0 2.667304 0 2.521447 0 0 0 0 0 0 3.123788 0 0 3.425438 0 0 0
          0 0 0 0 0 0 2.733572 0 0 0 0 2.618945 0 0 0 0 3.245461 0 0 2.564799 0 0 0 0 0
          0 0 2.940074 0 0 0 0 0 0 0 0 0 0 0 3.135154 0 0 3.015815 0 0 0 0 0 3.108112 0
          0 0 0 3.456544 0 3.083226)
    ]
);
$sells = pdl(
    [
        qw(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
          0 0 2.894235 0 0 0 0 0 0 0 0 0 0 0 0 0 3.116858 0 3.111701 0 0 3.388392 0 0 0
          0 0 0 0 0 0 0 0 2.709474 0 0 2.832519 0 0 0 0 3.449617 0 0 0 2.941207 0 0
          2.620776 0 0 0 0 0 0 2.872420 0 0 0 0 0 3.483031 0 0 0 0 0 2.933202 0 0 0 0 0
          0 3.462595 0 0 0 0 0 2.956799 0 0 0 0 0 0 0 0 2.615087 0 0 0 3.447604 0 0 0 0
          3.084196 0 0 0 0 0 0 0 2.572572 0 0 0 0 0 0 0 0 0 0 2.628707 0 0 0 0 3.078619
          0 0 0 0 0 0 0 0 0 3.374328 0 2.794525 0 0 0 0 0 0 0 0 0 0 0 0 3.151539 0 0 0 0
          0 0 0 0 0 0 0 0 0 3.232899 0 0 0 0 0 0 0 0 2.898395 0 0 0 0 0 0 0 0 0 0 0 0
          3.339632 0 0 2.829930 0 0 0 0 2.695821 0 0 0 0 2.810024 0 0 0 2.690098 0 0 0 0
          0 0 0 2.913808 0 0 0 0 0 0 0 2.935873 0 3.275847 0 0 0 0 0 3.044591 0 0 0 0
          3.411018 0 0 0 0 0 0 0 3.353161 0 0 0 0 0 0 0 0 0 3.007716 0 0 0 0 0 2.834662
          0 0 0 0 3.377260 0 3.491662 0)
    ]
);
pnl_calculator( $buys, $sells );

$buys = pdl([qw(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 327.72 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
        377.61 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 403.69 0 0 0 0 0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 353 0 0 0 0 0
        0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 323.97 0
        0 0 0 0 0 0 0 0 306.37 0 0 0 0 0 302.6 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 334.83 0 0 0 0 334.71 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 327.8 0 0 0 0 0 0 0 0 0)]);
$sells = pdl([qw(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 357.9 0 0 0 0 0 0 0 0 0 0 0 0 0 0
        0 0 0 0 0 388.35 0 0 0 0 0 0 0 0 0 0 0 0 0 405.63 0 0 0 0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0 0 0 361.5 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
        304.39 0 0 0 0 0 309.81 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0 0 329.73 0 0 0 0 0 0 0 0 333.74 0 0 0 0 0 0 0 0 0 0 0 0
        324.87 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)]);
pnl_calculator( $buys, $sells );

sub pnl_calculator {
    my ( $buys, $sells, $qty, $long_flag, $short_flag ) = @_;
    $qty = 100 unless defined $qty;
    my $xdata = xvals($buys->dim(0));
    my $b_idx = which( $buys > 0 );
    my $s_idx = which( $sells > 0 );
    say "buy index: $b_idx\n",  $b_idx->info;
    say "sell index: $s_idx\n", $s_idx->info;
    my $final_buys = zeroes($buys->dim(0));
    my $final_sells = zeroes($sells->dim(0));
    $long_flag = 1 unless defined $long_flag;
    $short_flag = 1 unless defined $short_flag;
    if ($b_idx->dim(0) > $s_idx->dim(0)) {
        $b_idx = $b_idx->index(xvals($s_idx->dim(0)));
        say "adjusting buy index to $b_idx";
        say "keeping sell index as $s_idx";
    } elsif ($b_idx->dim(0) < $s_idx->dim(0)) {
        $s_idx = $s_idx->index(xvals($b_idx->dim(0)));
        say "keeping buy index as $b_idx";
        say "adjusting sell index to $s_idx";
    }
    # numbers of buys and sells are equal
    if ( $b_idx->dim(0) == $s_idx->dim(0) ) {
        # long only
        my $longonly  = which( $b_idx < $s_idx );
        my $shortonly = which( $b_idx > $s_idx );
        if ($long_flag) {
            unless ( $longonly->isempty ) {
                say "long-only ", $longonly;
                my $trades = null;
                $trades =
                $trades->glue( 1, $xdata->index( $b_idx->index($longonly) ) );
                $trades =
                $trades->glue( 1, $buys->index( $b_idx->index($longonly) ) );
                $trades =
                $trades->glue( 1, $xdata->index( $s_idx->index($longonly) ) );
                $trades =
                $trades->glue( 1, $sells->index( $s_idx->index($longonly) ) );
                $final_buys->index($b_idx->index($longonly)) .= $buys->index($b_idx->index($longonly));
                $final_sells->index($s_idx->index($longonly)) .= $sells->index($s_idx->index($longonly));
                say $trades;

                # since they are ordered correctly as long only
                my $pnl = $trades ( , (3) ) - $trades ( , (1) );
                say "long-only P&L for $qty shares: ", sumover( $pnl * $qty );
            } else {
                say "some long trades possible";
                my $s2 = $s_idx->copy;
                my $b2 = $b_idx->copy;
                $s2->setbadat(0);
                $b2 = $b2->setbadat(-1)->rotate(1);
                say "adjusting sell index to $s2";
                say "adjusting buy index to $b2";
                $longonly = which( $b2 < $s2 );
                say "long-only: $longonly";

                unless ( $longonly->isempty ) {
                    my $trades = null;
                    $trades =
                    $trades->glue( 1, $xdata->index( $b2->index($longonly) ) );
                    $trades =
                    $trades->glue( 1, $buys->index( $b2->index($longonly) ) );
                    $trades =
                    $trades->glue( 1, $xdata->index( $s2->index($longonly) ) );
                    $trades =
                    $trades->glue( 1, $sells->index( $s2->index($longonly) ) );
                    say $trades;
                    $final_buys->index($b2->index($longonly)) .= $buys->index($b2->index($longonly));
                    $final_sells->index($s2->index($longonly)) .= $sells->index($s2->index($longonly));

                    # since they are ordered correctly as long only
                    my $pnl = $trades ( , (3) ) - $trades ( , (1) );
                    say "long-only P&L for $qty shares: ", sumover( $pnl * $qty );
                } else {
                    say "no long trades possible";
                }
            }
        }
        if ($short_flag) {
            unless ( $shortonly->isempty ) {
                say "short-only: $shortonly";
                my $trades = null;
                $trades =
                $trades->glue( 1, $xdata->index( $s_idx->index($shortonly) ) );
                $trades =
                $trades->glue( 1, $sells->index( $s_idx->index($shortonly) ) );
                $trades =
                $trades->glue( 1, $xdata->index( $b_idx->index($shortonly) ) );
                $trades =
                $trades->glue( 1, $buys->index( $b_idx->index($shortonly) ) );
                say $trades;
                $final_buys->index($b_idx->index($shortonly)) .= $buys->index($b_idx->index($shortonly));
                $final_sells->index($s_idx->index($shortonly)) .= $sells->index($s_idx->index($shortonly));

                # since they are ordered correctly as short only
                my $pnl = $trades ( , (3) ) - $trades ( , (1) );
                say "short-only P&L for $qty shares: ", sumover( $pnl * $qty );
            } else {
                say "some short trades possible";
                my $s2 = $s_idx->copy;
                my $b2 = $b_idx->copy;
                $b2->setbadat(0);
                $s2 = $s2->setbadat(-1)->rotate(1);
                say "adjusting sell index to $s2";
                say "adjusting buy index to $b2";
                $shortonly = which( $b2 > $s2 );
                say "short-only: $shortonly";

                unless ( $shortonly->isempty ) {
                    my $trades = null;
                    $trades =
                    $trades->glue( 1, $xdata->index( $s2->index($shortonly) ) );
                    $trades =
                    $trades->glue( 1, $sells->index( $s2->index($shortonly) ) );
                    $trades =
                    $trades->glue( 1, $xdata->index( $b2->index($shortonly) ) );
                    $trades =
                    $trades->glue( 1, $buys->index( $b2->index($shortonly) ) );
                    say $trades;
                    $final_buys->index($b2->index($shortonly)) .= $buys->index($b2->index($shortonly));
                    $final_sells->index($s2->index($shortonly)) .= $sells->index($s2->index($shortonly));

                    # since they are ordered correctly as long only
                    my $pnl = $trades ( , (3) ) - $trades ( , (1) );
                    say "short-only P&L for $qty shares: ", sumover( $pnl * $qty );
                } else {
                    say "no short trades possible";
                }
            }
        }
        say "Final buys: $final_buys";
        say "Final sells: $final_sells";
    } else {
        die "no. of buys and sells are not equal";
    }
}
