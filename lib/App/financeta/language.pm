package App::financeta::language::grammar;
use strict;
use warnings;
use 5.10.0;
use feature 'say';

our $VERSION = '0.09';
$VERSION = eval $VERSION;

use Pegex::Base;
extends 'Pegex::Grammar';

use constant text => <<GRAMMAR;
self: word* %% +
word: / ( NS+ ) /
GRAMMAR

1;

package App::financeta::language::receiver;
use strict;
use warnings;
use 5.10.0;
use feature 'say';

our $VERSION = '0.09';
$VERSION = eval $VERSION;

use Pegex::Base;
extends 'Pegex::Tree';

sub got_word {
    my ($self, $got) = @_;
    return uc $got;
}

sub final {
    my ($self, $got) = @_;
    $self->flatten($got);
    return wantarray ? @$got : $got;
}

1;

package App::financeta::language;
use strict;
use warnings;
use 5.10.0;
use feature 'say';

our $VERSION = '0.09';
$VERSION = eval $VERSION;

use Carp;
use Pegex::Parser;
use App::financeta::mo;

$| = 1;
has debug => 0;

has grammar => (default => sub {
    return App::financeta::language::grammar->new;
});

has receiver => (default => sub {
    return App::financeta::language::receiver->new;
});

has parser => (builder => '_build_parser');

sub _build_parser {
    my $self = shift;
    return Pegex::Parser->new(
        grammar => $self->grammar,
        receiver => $self->receiver,
        debug => $self->debug,
        throw_on_error => 0,
    );
}

sub compile {
    my ($self, $text) = @_;
    return $self->parser->parse($text);
}

1;

__END__
### COPYRIGHT: 2014 Vikas N. Kumar. All Rights Reserved.
### AUTHOR: Vikas N Kumar <vikas@cpan.org>
### DATE: 3rd Sept 2014
### LICENSE: Refer LICENSE file
