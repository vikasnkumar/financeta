package PDL::Finance::TA::Indicators;
use strict;
use warnings;
use 5.10.0;

our $VERSION = '0.03';
$VERSION = eval $VERSION;

use PDL::Finance::TA::Mo;
use PDL::Finance::Talib;

has overlaps => {
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

sub types {
    my $self = shift;
    return {
        overlaps => $self->overlaps,
    };
}

1;
