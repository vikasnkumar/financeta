package PDL::Finance::TA::Indicators;
use strict;
use warnings;
use 5.10.0;
use feature 'say';

our $VERSION = '0.03';
$VERSION = eval $VERSION;

use PDL::Finance::TA::Mo;
use PDL::Lite;
use PDL::NiceSlice;
use PDL::Finance::Talib;
use Data::Dumper;

$PDL::doubleformat = "%0.6lf";
has debug => 0;

has overlays => {
    bbands => {
        name => 'Bollinger Bands',
#        func => 'ta_bbands',
        params => [
            # key, pretty name, type, default value
            [ 'InTimePeriod', 'Period Window', PDL::long, 5],
            [ 'InNbDevUp', 'Upper Deviation multiplier', PDL::float, 2.0],
            [ 'InNbDevDn', 'Lower Deviation multiplier', PDL::float, 2.0],
            # this will show up in a combo list
            [ 'InMAType', 'Moving Average Type', 'ARRAY',
                [
                qw/SMA EMA WMA DEMA TEMA TRIMA KAMA MAMA T3/
                ],
            ],
        ],
        code => sub {
            my ($obj, $inpdl, @args) = @_;
            say "Executing ta_bbands with parameters: ", Dumper(\@args) if $obj->debug;
            my ($upper, $middle, $lower) = PDL::ta_bbands($inpdl, @args);
            return [
                ['Upper Band', $upper],
                ['Middle Band', $middle],
                ['Lower Band', $lower],
            ];
        },
    },
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

sub execute_ohlc($$) {
    my ($self, $data, $iref) = @_;
    return unless ref $data eq 'PDL';
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
    # ok now we found the function so let's invoke it
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
    # only send the close price in
    return &$coderef($self, $data(,(4)), @args);
}

1;
__END__
### COPYRIGHT: 2014 Vikas N. Kumar. All Rights Reserved.
### AUTHOR: Vikas N Kumar <vikas@cpan.org>
### DATE: 17th Aug 2014
### LICENSE: Refer LICENSE file
