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
has overlaps => {
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

has 'volatility' => {
    atr => {
        name => 'Average True Range',
        params => [
            # key, pretty name, type, default value
            [ 'InTimePeriod', 'Period Window (1 - 100000)', PDL::long, 14],
        ],
        input => [qw/high low close/],
        code => sub {
            my ($obj, $high, $low, $close, @args) = @_;
            say "Executing ta_atr with parameters: ", Dumper(\@args) if $obj->debug;
            my $period = $args[0];
            my $outpdl = PDL::ta_atr($high, $low, $close, @args);
            return [
                ["ATR($period)", $outpdl],
            ];
        },
        gnuplot => \&_plot_gnuplot_general,
    },
    natr => {
        name => 'Normalized Average True Range',
        params => [
            # key, pretty name, type, default value
            [ 'InTimePeriod', 'Period Window (1 - 100000)', PDL::long, 14],
        ],
        input => [qw/high low close/],
        code => sub {
            my ($obj, $high, $low, $close, @args) = @_;
            say "Executing ta_natr with parameters: ", Dumper(\@args) if $obj->debug;
            my $period = $args[0];
            my $outpdl = PDL::ta_natr($high, $low, $close, @args);
            return [
                ["NATR($period)", $outpdl],
            ];
        },
        gnuplot => \&_plot_gnuplot_general,
    },
    trange => {
        name => 'True Range',
        params => [
            # no params
        ],
        input => [qw/high low close/],
        code => sub {
            my ($obj, $high, $low, $close) = @_;
            say "Executing ta_trange" if $obj->debug;
            my $outpdl = PDL::ta_trange($high, $low, $close);
            return [
                ["True Range", $outpdl],
            ];
        },
        gnuplot => \&_plot_gnuplot_general,
    },
};

has 'momentum' => {

};

has 'cycle' => {
    ht_dcperiod => {
        name => 'Hilbert Transform - Dominant Cycle Period',
    },
    ht_dcphase => {
        name => 'Hilbert Transform - Dominant Cycle Phase',
    },
    ht_phasor => {
        name => 'Hilbert Transform - Phasor Components',
    },
    ht_sine => {
        name => 'Hilbert Transform - Sine Wave',
    },
    ht_trendmode => {
        name => 'Hilbert Transform - Trend vs Cycle Mode',
    },
};

has 'volume' => {
    ad => {
        name => 'Chaikin A/D line',
        params => [
            # no params
        ],
        input => [qw/high low close volume/],
        code => sub {
            my ($obj, $high, $low, $close, $volume) = @_;
            say "Executing ta_ad" if $obj->debug;
            my $outpdl = PDL::ta_ad($high, $low, $close, $volume);
            return [
                ["Chaikin A/D", $outpdl],
            ];
        },
        gnuplot => \&_plot_gnuplot_general,
    },
    adosc => {
        name => 'Chaikin A/D Oscillator',
        params => [
            # key, pretty name, type, default value
            [ 'InFastPeriod', 'Fast MA Period Window (2 - 100000)', PDL::long, 3],
            [ 'InSlowPeriod', 'Slow MA Period Window (2 - 100000)', PDL::long, 10],
        ],
        input => [qw/high low close volume/],
        code => sub {
            my ($obj, $high, $low, $close, $volume, @args) = @_;
            say "Executing ta_adosc with parameters ", Dumper(\@args) if $obj->debug;
            my $fast = $args[0];
            my $slow = $args[1];
            my $outpdl = PDL::ta_adosc($high, $low, $close, $volume, @args);
            return [
                ["Chaikin A/D($fast,$slow)", $outpdl],
            ];
        },
        gnuplot => \&_plot_gnuplot_general,
    },
    obv => {
        name => 'On Balance Volume',
        params => [
            # no params
        ],
        input => [qw/close volume/],
        code => sub {
            my ($obj, $close, $volume) = @_;
            say "Executing ta_obv" if $obj->debug;
            my $outpdl = PDL::ta_obv($close, $volume);
            return [
                ["OBV", $outpdl],
            ];
        },
        gnuplot => \&_plot_gnuplot_general,
    },
};

has 'pattern' => {

};

has 'statistic' => {
};

has 'price' => {
    avgprice => {
        name => 'Average Price',
        params => [
            # no params
        ],
        input => [qw/open high low close/],
        code => sub {
            my ($obj, $open, $high, $low, $close) = @_;
            say "Executing ta_avgprice" if $obj->debug;
            my $outpdl = PDL::ta_avgprice($open, $high, $low, $close);
            return [
                ["Avg. Price", $outpdl],
            ];
        },
        gnuplot => \&_plot_gnuplot_general,
    },
    medprice => {
        name => 'Median Price',
        params => [
            # no params
        ],
        input => [qw/high low/],
        code => sub {
            my ($obj, $high, $low) = @_;
            say "Executing ta_medprice" if $obj->debug;
            my $outpdl = PDL::ta_medprice($high, $low);
            return [
                ["Median Price", $outpdl],
            ];
        },
        gnuplot => \&_plot_gnuplot_general,
    },
    typprice => {
        name => 'Typical Price',
        params => [
            # no params
        ],
        input => [qw/high low close/],
        code => sub {
            my ($obj, $high, $low, $close) = @_;
            say "Executing ta_typprice" if $obj->debug;
            my $outpdl = PDL::ta_typprice($high, $low, $close);
            return [
                ["Typical Price", $outpdl],
            ];
        },
        gnuplot => \&_plot_gnuplot_general,
    },
    wclprice => {
        name => 'Weighted Close Price',
        params => [
            # no params
        ],
        input => [qw/high low close/],
        code => sub {
            my ($obj, $high, $low, $close) = @_;
            say "Executing ta_wclprice" if $obj->debug;
            my $outpdl = PDL::ta_wclprice($high, $low, $close);
            return [
                ["Wt. Close Price", $outpdl],
            ];
        },
        gnuplot => \&_plot_gnuplot_general,
    },
};

has group_name => {
    overlaps => 'Overlap Studies',
    volatility => 'Volatility Indicators',
    momentum => 'Momentum Indicators',
    cycle => 'Cycle Indicators',
    volume => 'Volume Indicators',
    pattern => 'Pattern Recognition',
    statistic => 'Statistic Functions',
    price => 'Price Transform',
};

has group_key => {
    'Overlap Studies' => 'overlaps',
    'Volatility Indicators' => 'volatility',
    'Momentum Indicators' => 'momentum',
    'Cycle Indicators' => 'cycle',
    'Volume Indicators' => 'volume',
    'Pattern Recognition' => 'pattern',
    'Statistic Functions' => 'statistic',
    'Price Transform' => 'price',
};

sub get_groups {
    my $self = shift;
    ## NEEDS TO BE IN THIS ORDER
    my @groups = (
        'Overlap Studies',
        'Volatility Indicators',
        'Momentum Indicators',
        'Cycle Indicators',
        'Volume Indicators',
        'Pattern Recognition',
        'Statistic Functions',
        'Price Transform',
    );
    return wantarray ? @groups : \@groups;
}

sub get_funcs($) {
    my ($self, $grp) = @_;
    $grp = $self->group_key->{$grp} if defined $grp;
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
    $grp = $self->group_key->{$grp} if defined $grp;
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
    my $fn_name = $iref->{func};
    my $fn_key;
    my $grp = $self->group_key->{$iref->{group}} if defined $iref->{group};
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

sub execute_ohlcv($$) {
    my ($self, $data, $iref) = @_;
    return unless ref $data eq 'PDL';
    my $fn_key = $self->_find_func_key($iref);
    return unless defined $fn_key;
    # ok now we found the function so let's invoke it
    my $grp = $self->group_key->{$iref->{group}} if defined $iref->{group};
    return unless defined $grp;
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
        push @input_pdls, $data(,(5)) if /volume/i;
    }
    return &$coderef($self, @input_pdls, @args) if ref $coderef eq 'CODE';
}

sub get_plot_args($$$) {
    my ($self, $xdata, $output, $iref) = @_;
    my $fn_key = $self->_find_func_key($iref);
    return unless defined $fn_key;
    my $grp = $self->group_key->{$iref->{group}} if defined $iref->{group};
    return unless defined $grp;
    my $plotref = $self->$grp->{$fn_key}->{lc($self->plot_engine)};
    return &$plotref($self, $xdata, $output) if ref $plotref eq 'CODE';
}

1;
__END__
### COPYRIGHT: 2014 Vikas N. Kumar. All Rights Reserved.
### AUTHOR: Vikas N Kumar <vikas@cpan.org>
### DATE: 17th Aug 2014
### LICENSE: Refer LICENSE file
