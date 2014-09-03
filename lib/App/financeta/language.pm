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
%grammar financeta
%version 0.09

program: statement* EOS
statement: comment | instruction

comment: /- HASH ANY* EOL/ | blank-line
blank-line: /- EOL/

_: / BLANK* EOL?/
__: / BLANK+ EOL?/
line-ending: /- SEMI - EOL?/

instruction: 'dummy'
GRAMMAR

1;

package App::financeta::language::receiver;
use strict;
use warnings;
use 5.10.0;
use feature 'say';

our $VERSION = '0.09';
$VERSION = eval $VERSION;

use Data::Dumper;
use Pegex::Base;
extends 'Pegex::Tree';

has debug => 0;

sub got_comment {} # strip the comments out

sub final {
    my ($self, $got) = @_;
    $self->flatten($got);
    say Dumper($got) if $self->debug;
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

has receiver => (builder => '_build_receiver');

sub _build_receiver {
    my $self = shift;
    return App::financeta::language::receiver->new(debug => $self->debug);
}

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
    return unless (defined $text and length $text);
    return $self->parser->parse($text);
}

1;

__END__
### COPYRIGHT: 2014 Vikas N. Kumar. All Rights Reserved.
### AUTHOR: Vikas N Kumar <vikas@cpan.org>
### DATE: 3rd Sept 2014
### LICENSE: Refer LICENSE file
