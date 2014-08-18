package PDL::Finance::TA::Indicators;
use strict;
use warnings;
use 5.10.0;

our $VERSION = '0.03';
$VERSION = eval $VERSION;

use PDL::Finance::TA::Mo;
use PDL::Finance::Talib;

has overlays => {
    bbands => {
        name => 'Bollinger Bands',
        func => 'ta_bbands',
        params => [
            ['Period', PDL::long, 5],
            ['Upper Deviation multiplier', PDL::float, 2.0],
            ['Lower Deviation multiplier', PDL::float, 2.0],
            # this will show up in a combo list
            ['Moving Average Type', 'ARRAY',
                [
                qw/SMA EMA WMA DEMA TEMA TRIMA KAMA MAMA T3/
                ]
            ],
        ],
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
        return $r->{$fn}->{params} if defined $fn;
    }
}

1;
__END__
### COPYRIGHT: 2014 Vikas N. Kumar. All Rights Reserved.
### AUTHOR: Vikas N Kumar <vikas@cpan.org>
### DATE: 17th Aug 2014
### LICENSE: Refer LICENSE file
