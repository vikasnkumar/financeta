package PDL::Finance::TA::Indicators;
use strict;
use warnings;
use 5.10.0;
use feature 'say';

our $VERSION = '0.04';
$VERSION = eval $VERSION;

use PDL::Finance::TA::Mo;
use PDL::Lite;
use PDL::NiceSlice;
use PDL::Finance::Talib;
use Data::Dumper;

$PDL::doubleformat = "%0.6lf";
has debug => 0;
has plot_engine => 'gnuplot';

sub _plot_gnuplot_general {
    my ($self, $xdata, $output) = @_;
    # output is the same as the return value of the code-ref above
    my @plotinfo = ();
    my @colors = qw(dark-blue brown dark-green dark-red magenta dark-magenta);
    foreach (@$output) {
        my $p = $_->[1];
        push @plotinfo, {
            with => 'lines',
            legend => $_->[0],
            linecolor => shift @colors,
        }, $xdata, $p;
    }
    return @plotinfo;
}

has ma_names => {
    0 => 'SMA',
    1 => 'EMA',
    2 => 'WMA',
    3 => 'DEMA',
    4 => 'TEMA',
    5 => 'TRIMA',
    6 => 'KAMA',
    7 => 'MAMA',
    8 => 'T3',
};

#TODO: verify parameters that are entered by the user
has overlays => {
    bbands => {
        name => 'Bollinger Bands',
        params => [
            # key, pretty name, type, default value
            [ 'InTimePeriod', 'Period Window (2 - 100000)', PDL::long, 5],
            [ 'InNbDevUp', 'Upper Deviation multiplier', PDL::float, 2.0],
            [ 'InNbDevDn', 'Lower Deviation multiplier', PDL::float, 2.0],
            # this will show up in a combo list
            [ 'InMAType', 'Moving Average Type', 'ARRAY',
                [
                    'Simple', #SMA
                    'Exponential', #EMA
                    'Weighted', #WMA
                    'Double Exponential', #DEMA
                    'Triple Exponential', #TEMA
                    'Triangular', #TRIMA
                    'Kaufman Adaptive', #KAMA
                    'MESA Adaptive', #MAMA
                    'Triple Exponential (T3)', #T3
                ],
            ],
        ],
        code => sub {
            my ($obj, $inpdl, @args) = @_;
            say "Executing ta_bbands with parameters: ", Dumper(\@args) if $obj->debug;
            my $period = $args[0];
            my ($upper, $middle, $lower) = PDL::ta_bbands($inpdl, @args);
            return [
                ["Upper Band($period)", $upper],
                ["Middle Band($period)", $middle],
                ["Lower Band($period)", $lower],
            ];
        },
        # use Gnuplot related stuff
        gnuplot => \&_plot_gnuplot_general,
    },
    dema => {
        name => 'Double Exponential Moving Average',
        params => [
            # key, pretty name, type, default value
            [ 'InTimePeriod', 'Period Window (2 - 100000)', PDL::long, 30],
        ],
        code => sub {
            my ($obj, $inpdl, @args) = @_;
            say "Executing ta_dema with parameters: ", Dumper(\@args) if $obj->debug;
            my $period = $args[0];
            my $outpdl = PDL::ta_dema($inpdl, @args);
            return [
                ["DEMA($period)", $outpdl],
            ];
        },
        gnuplot => \&_plot_gnuplot_general,
    },
    ema => {
        name => 'Exponential Moving Average',
        params => [
            # key, pretty name, type, default value
            [ 'InTimePeriod', 'Period Window (2 - 100000)', PDL::long, 30],
        ],
        code => sub {
            my ($obj, $inpdl, @args) = @_;
            say "Executing ta_ema with parameters: ", Dumper(\@args) if $obj->debug;
            my $period = $args[0];
            my $outpdl = PDL::ta_ema($inpdl, @args);
            return [
                ["EMA($period)", $outpdl],
            ];
        },
        gnuplot => \&_plot_gnuplot_general,
    },
    ht_trendline => {
        name => 'Hilbert Transform - Instantaneous Trendline',
        params => [
            # no params
        ],
        code => sub {
            my ($obj, $inpdl) = @_;
            say "Executing ta_ht_trendline" if $obj->debug;
            my $outpdl = PDL::ta_ht_trendline($inpdl);
            return [
                ['HT-trendline', $outpdl],
            ];
        },
        gnuplot => \&_plot_gnuplot_general,
    },
    kama => {
        name => 'Kaufman Adaptive Moving Average',
        params => [
            # key, pretty name, type, default value
            [ 'InTimePeriod', 'Period Window (2 - 100000)', PDL::long, 30],
        ],
        code => sub {
            my ($obj, $inpdl, @args) = @_;
            say "Executing ta_kama with parameters: ", Dumper(\@args) if $obj->debug;
            my $period = $args[0];
            my $outpdl = PDL::ta_kama($inpdl, @args);
            return [
                ["KAMA($period)", $outpdl],
            ];
        },
        gnuplot => \&_plot_gnuplot_general,
    },
    ma => {
        name => 'Moving Average',
        params => [
            # key, pretty name, type, default value
            [ 'InTimePeriod', 'Period Window (2 - 100000)', PDL::long, 30],
            # this will show up in a combo list
            [ 'InMAType', 'Moving Average Type', 'ARRAY',
                [
                    'Simple', #SMA
                    'Exponential', #EMA
                    'Weighted', #WMA
                    'Double Exponential', #DEMA
                    'Triple Exponential', #TEMA
                    'Triangular', #TRIMA
                    'Kaufman Adaptive', #KAMA
                    'MESA Adaptive', #MAMA
                    'Triple Exponential (T3)', #T3
                ],
            ],
        ],
        code => sub {
            my ($obj, $inpdl, @args) = @_;
            say "Executing ta_ma with parameters: ", Dumper(\@args) if $obj->debug;
            my $period = $args[0];
            my $type = $obj->ma_name->{$args[1]} || 'UNKNOWN';
            my $outpdl = PDL::ta_ma($inpdl, @args);
            return [
                ["MA($period)($type)", $outpdl],
            ];
        },
        gnuplot => \&_plot_gnuplot_general,
    },
    mama => {
        name => 'MESA Adaptive Moving Average',
        params => [
            # key, pretty name, type, default value
            [ 'InFastLimit', 'Upper Limit (0.01 - 0.99)', PDL::double, 0.5],
            [ 'InSlowLimit', 'Lower Limit (0.01 - 0.99)', PDL::double, 0.05],
        ],
        code => sub {
            my ($obj, $inpdl, @args) = @_;
            say "Executing ta_mama with parameters: ", Dumper(\@args) if $obj->debug;
            my ($omama, $ofama) = PDL::ta_mama($inpdl, @args);
            return [
                ["MAMA", $omama],
                ["FAMA", $ofama],
            ];
        },
        gnuplot => \&_plot_gnuplot_general,
    },
    mavp => {
        name => 'Moving Average with Variable Period',
        params => [
            # key, pretty name, type, default value
            [ 'InMinPeriod', 'Minimum Period (2 - 100000)', PDL::long, 2],
            [ 'InMaxPeriod', 'Maximum Period (2 - 100000)', PDL::long, 30],
            # this will show up in a combo list
            [ 'InMAType', 'Moving Average Type', 'ARRAY',
                [
                    'Simple', #SMA
                    'Exponential', #EMA
                    'Weighted', #WMA
                    'Double Exponential', #DEMA
                    'Triple Exponential', #TEMA
                    'Triangular', #TRIMA
                    'Kaufman Adaptive', #KAMA
                    'MESA Adaptive', #MAMA
                    'Triple Exponential (T3)', #T3
                ],
            ],
        ],
        code => sub {
            my ($obj, $inpdl, @args) = @_;
            say "Executing ta_mavp with parameters: ", Dumper(\@args) if $obj->debug;
            my $type = $obj->ma_name->{$args[2]} || 'UNKNOWN';
            my $outpdl = PDL::ta_mavp($inpdl, @args);
            return [
                ["MAVP($type)", $outpdl],
            ];
        },
        gnuplot => \&_plot_gnuplot_general,
    },
    midpoint => {
        name => 'Mid-point over period',
        params => [
            # key, pretty name, type, default value
            [ 'InTimePeriod', 'Period Window (2 - 100000)', PDL::long, 14],
        ],
        code => sub {
            my ($obj, $inpdl, @args) = @_;
            say "Executing ta_midpoint with parameters: ", Dumper(\@args) if $obj->debug;
            my $period = $args[0];
            my $outpdl = PDL::ta_midpoint($inpdl, @args);
            return [
                ["MIDPOINT($period)", $outpdl],
            ];
        },
        gnuplot => \&_plot_gnuplot_general,
    },
    midprice => {
        name => 'Mid-point Price over period',
        params => [
            # key, pretty name, type, default value
            [ 'InTimePeriod', 'Period Window (2 - 100000)', PDL::long, 14],
        ],
        input => ['high', 'low'],
        code => sub {
            my ($obj, $highpdl, $lowpdl, @args) = @_;
            say "Executing ta_midprice parameters: ", Dumper(\@args) if $obj->debug;
            my $period = $args[0];
            my $outpdl = PDL::ta_midprice($highpdl, $lowpdl, @args);
            return [
                ["MIDPRICE($period)", $outpdl],
            ];
        },
        gnuplot => \&_plot_gnuplot_general,
    },
    sar => {
        name => 'Parabolic SAR',
        params => [
            # key, pretty name, type, default value
            [ 'InAcceleration', 'Acceleration Factor(>= 0)', PDL::double, 0.02],
            [ 'InMaximum', 'Max. Acceleration Factor(>= 0)', PDL::double, 0.2],
        ],
        input => ['high', 'low'],
        code => sub {
            my ($obj, $highpdl, $lowpdl, @args) = @_;
            say "Executing ta_sar parameters: ", Dumper(\@args) if $obj->debug;
            my $outpdl = PDL::ta_sar($highpdl, $lowpdl, @args);
            return [
                ["SAR", $outpdl],
            ];
        },
        gnuplot => \&_plot_gnuplot_general,
    },
    sarext => {
        name => 'Parabolic SAR - Extended',
        params => [
            # key, pretty name, type, default value
            [ 'InStartValue', 'Start Value', PDL::double, 0.0],
            [ 'InOffsetOnReverse', 'Percent Offset(>= 0)', PDL::double, 0.0],
            [ 'InAccelerationInitLong', 'Acceleration Factor Initial Long(>= 0)', PDL::double, 0.02],
            [ 'InAccelerationLong', 'Acceleration Factor Long(>= 0)', PDL::double, 0.02],
            [ 'InAccelerationMaxLong', 'Acceleration Factor Max. Long(>= 0)', PDL::double, 0.2],
            [ 'InAccelerationInitShort', 'Acceleration Factor Initial Short(>= 0)', PDL::double, 0.02],
            [ 'InAccelerationShort', 'Acceleration Factor Short(>= 0)', PDL::double, 0.02],
            [ 'InAccelerationMaxShort', 'Acceleration Factor Max. Short(>= 0)', PDL::double, 0.2],
        ],
        input => ['high', 'low'],
        code => sub {
            my ($obj, $highpdl, $lowpdl, @args) = @_;
            say "Executing ta_sarext parameters: ", Dumper(\@args) if $obj->debug;
            my $outpdl = PDL::ta_sarext($highpdl, $lowpdl, @args);
            return [
                ["SAR-EXT", $outpdl],
            ];
        },
        gnuplot => \&_plot_gnuplot_general,
    },
    sma => {
        name => 'Simple Moving Average',
        params => [
            # key, pretty name, type, default value
            [ 'InTimePeriod', 'Period Window (2 - 100000)', PDL::long, 30],
        ],
        code => sub {
            my ($obj, $inpdl, @args) = @_;
            say "Executing ta_sma with parameters: ", Dumper(\@args) if $obj->debug;
            my $period = $args[0];
            my $outpdl = PDL::ta_sma($inpdl, @args);
            return [
                ["SMA($period)", $outpdl],
            ];
        },
        gnuplot => \&_plot_gnuplot_general,
    },
    t3 => {
        name => 'Triple Exponential Moving Average (T3)',
        params => [
            # key, pretty name, type, default value
            [ 'InTimePeriod', 'Period Window (2 - 100000)', PDL::long, 5],
            [ 'InVFactor', 'Volume Factor(0.0 - 1.0)', PDL::double, 0.7],
        ],
        code => sub {
            my ($obj, $inpdl, @args) = @_;
            say "Executing ta_t3 with parameters: ", Dumper(\@args) if $obj->debug;
            my $period = $args[0];
            my $outpdl = PDL::ta_t3($inpdl, @args);
            return [
                ["T3-EMA($period)", $outpdl],
            ];
        },
        gnuplot => \&_plot_gnuplot_general,
    },
    tema => {
        name => 'Triple Exponential Moving Average',
        params => [
            # key, pretty name, type, default value
            [ 'InTimePeriod', 'Period Window (2 - 100000)', PDL::long, 30],
        ],
        code => sub {
            my ($obj, $inpdl, @args) = @_;
            say "Executing ta_trima with parameters: ", Dumper(\@args) if $obj->debug;
            my $period = $args[0];
            my $outpdl = PDL::ta_tema($inpdl, @args);
            return [
                ["TEMA($period)", $outpdl],
            ];
        },
        gnuplot => \&_plot_gnuplot_general,
    },
    trima => {
        name => 'Triangular Moving Average',
        params => [
            # key, pretty name, type, default value
            [ 'InTimePeriod', 'Period Window (2 - 100000)', PDL::long, 30],
        ],
        code => sub {
            my ($obj, $inpdl, @args) = @_;
            say "Executing ta_trima with parameters: ", Dumper(\@args) if $obj->debug;
            my $period = $args[0];
            my $outpdl = PDL::ta_trima($inpdl, @args);
            return [
                ["TRIMA($period)", $outpdl],
            ];
        },
        gnuplot => \&_plot_gnuplot_general,
    },
    wma => {
        name => 'Weighted Moving Average',
        params => [
            # key, pretty name, type, default value
            [ 'InTimePeriod', 'Period Window (2 - 100000)', PDL::long, 30],
        ],
        code => sub {
            my ($obj, $inpdl, @args) = @_;
            say "Executing ta_wma with parameters: ", Dumper(\@args) if $obj->debug;
            my $period = $args[0];
            my $outpdl = PDL::ta_wma($inpdl, @args);
            return [
                ["WMA($period)", $outpdl],
            ];
        },
        gnuplot => \&_plot_gnuplot_general,
    },
    ### SKELETON
    #key => {
    #   name => 'Pretty Name',
    #   params => [
    #       ['key', 'pretty name', 'type', 'default value'],
    #       #...add more if required...
    #   ],
    #   input => [qw/high low/] # default is [/close/]
    #   code => sub {
    #       my ($indicator_obj, $input_pdl, @params) = @_;
    #       #...add code here...
    #       # output array-ref
    #       return [ ['Pretty Name', $output_pdl_1],...];
    #   },
    #   gnuplot => sub {
    #       my ($indicator_obj, $x_axis_pdl, $output_array_ref) = @_;
    #       #...add plotting arguments here in an array
    #       return @plot_args;
    #   },
    #}
};

sub get_groups {
    my $self = shift;
    my @groups = qw/
        overlays
    /;
    @groups = map { ucfirst $_ } @groups;
    return wantarray ? @groups : \@groups;
}

sub get_funcs($) {
    my ($self, $grp) = @_;
    $grp = lc $grp if defined $grp;
    if (defined $grp and $self->has($grp)) {
        my $r = $self->$grp;
        my @funcs = ();
        foreach my $k (sort(keys %$r)) {
            push @funcs, $r->{$k}->{name};
        }
        say "Found funcs: ", Dumper(\@funcs) if $self->debug;
        return wantarray ? @funcs : \@funcs;
    }
}

sub get_params($$) {
    my ($self, $fn_name, $grp) = @_;
    $grp = lc $grp if defined $grp;
    my $fn;
    # find the function parameters
    if (defined $grp and $self->has($grp)) {
        my $r = $self->$grp;
        foreach my $k (sort (keys %$r)) {
            $fn = $k if $r->{$k}->{name} eq $fn_name;
            last if defined $fn;
        }
        my $params = $r->{$fn}->{params} if defined $fn;
        say "Found params: ", Dumper($params) if $self->debug;
        return $params;
    }
}

sub _find_func_key($$) {
    my ($self, $iref) = @_;
    return unless ref $iref eq 'HASH';
    my $params = $iref->{params};
    my $grp = $iref->{group};
    my $fn_name = $iref->{func};
    my $fn_key;
    $grp = lc $grp if defined $grp;
    if (defined $grp and $self->has($grp)) {
        my $r = $self->$grp;
        foreach my $k (sort (keys %$r)) {
            $fn_key = $k if $r->{$k}->{name} eq $fn_name;
            last if defined $fn_key;
        }
    }
    return unless defined $fn_key;
    say "Found $fn_key" if $self->debug;
    return $fn_key;
}

sub execute_ohlc($$) {
    my ($self, $data, $iref) = @_;
    return unless ref $data eq 'PDL';
    my $fn_key = $self->_find_func_key($iref);
    return unless defined $fn_key;
    # ok now we found the function so let's invoke it
    my $grp = lc $iref->{group};
    my $params = $iref->{params};
    my $func = $self->$grp->{$fn_key}->{func};
    my $coderef = $self->$grp->{$fn_key}->{code};
    my $paramarray = $self->$grp->{$fn_key}->{params};
    my @args = ();
    for (my $i = 0; $i < scalar @$paramarray; ++$i) {
        my $k = $paramarray->[$i]->[0];
        next unless defined $k;
        if (exists $params->{$k . '_index'}) {
            # handle ARRAY
            push @args, $params->{$k . '_index'};
        } else {
            push @args, eval $params->{$k};
        }
    }
    my $input_cols = $self->$grp->{$fn_key}->{input} || ['close'];
    $input_cols = ['close'] unless scalar @$input_cols;
    my @input_pdls = ();
    foreach (@$input_cols) {
        push @input_pdls, $data(,(0)) if /time/i;
        push @input_pdls, $data(,(1)) if /open/i;
        push @input_pdls, $data(,(2)) if /high/i;
        push @input_pdls, $data(,(3)) if /low/i;
        push @input_pdls, $data(,(4)) if /close/i;
    }
    return &$coderef($self, @input_pdls, @args) if ref $coderef eq 'CODE';
}

sub get_plot_args($$$) {
    my ($self, $xdata, $output, $iref) = @_;
    my $fn_key = $self->_find_func_key($iref);
    return unless defined $fn_key;
    my $grp = lc $iref->{group};
    my $plotref = $self->$grp->{$fn_key}->{lc($self->plot_engine)};
    return &$plotref($self, $xdata, $output) if ref $plotref eq 'CODE';
}

1;
__END__
### COPYRIGHT: 2014 Vikas N. Kumar. All Rights Reserved.
### AUTHOR: Vikas N Kumar <vikas@cpan.org>
### DATE: 17th Aug 2014
### LICENSE: Refer LICENSE file
