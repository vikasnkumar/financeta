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

sub get_funcs {
    my ($self, $grp) = @_;
    $grp = lc $grp if defined $grp;
    if (defined $grp and $self->has($grp)) {
        my $r = $self->$grp;
        my @funcs = ();
        foreach my $k (keys $r) {
            push @funcs, $r->{$k}->{name};
        }
        return wantarray ? @funcs : \@funcs;
    }
}

sub get_params {
    my ($self, $fn_name) = @_;
    return unless defined $fn_name;

}

sub types {
    my $self = shift;
    return {
        overlays => $self->overlays,
    };
}

1;
