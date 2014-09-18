package App::financeta::language::grammar;
use strict;
use warnings;
use 5.10.0;
use feature 'say';

our $VERSION = '0.10';
$VERSION = eval $VERSION;

use Pegex::Base;
extends 'Pegex::Grammar';

use constant text => <<GRAMMAR;
%grammar financeta
%version 0.10

program: statement* EOS
statement: comment | instruction

comment: /- HASH ANY* EOL/ | blank-line
blank-line: /- EOL/

_: / BLANK* EOL?/
__: / BLANK+ EOL?/
line-ending: /- SEMI - EOL?/

instruction: order - /(i:'when'|'if')/ - conditions line-ending
conditions: single-condition | nested-condition

nested-condition: start-nested single-condition end-nested
single-condition: any-condition-expr+ % logic-op
any-condition-expr: single-condition-expr | nested-condition-expr
nested-condition-expr: start-nested single-condition-expr end-nested
single-condition-expr: comparison | complement
comparison: comparison-state | comparison-basic
comparison-state: - variable - state-op-pre - state - state-op-post? -
comparison-basic: - value - compare-op - value -

complement: - not-op - value-expression
value: complement | value-expression
state: /((i:'positive' | 'negative' | 'zero'))/ | value-expression
value-expression: variable | number
state-op-pre: /((i: 'becomes' | 'crosses' ))/
state-op-post: /(i: 'from') - ((i: 'above' | 'below'))/
compare-op: /((i:'is' | 'equals'))/ |
    /([ BANG EQUAL LANGLE RANGLE] EQUAL | (: LANGLE | RANGLE ))/
not-op: /((i:'not') | BANG)/
logic-op: /((i:'and' | 'or'))/ | /([ AMP PIPE ]{2})/

# instruction-task
order: buy-sell quantity? - /(i:'at')/ - price -
buy-sell: - /((i:'buy' | 'sell'))/ -
quantity: number
price: variable | number
variable: DOLLAR identifier

# basic tokens
start-nested: /- LPAREN -/
end-nested: /- RPAREN -/
identifier: /(! keyword)( ALPHA [ WORDS ]*)/
keyword: /(i:
        'buy' | 'sell' | 'at' | 'equals' | 'true' | 'false' | 'if' |
        'when' | 'and' | 'or' | 'not' | 'above' | 'is' |
        'becomes' | 'crosses' | 'below' | 'from' | 'to' |
        'positive' | 'negative' | 'zero' | 'over' | 'into'
        )/
number: real-number | integer | boolean
real-number: /('-'? DIGIT* '.' DIGIT+)/
integer: /('-'? DIGIT+)/
boolean: /((i:'true'|'false'))/

GRAMMAR

1;

package App::financeta::language::receiver;
use strict;
use warnings;
use 5.10.0;
use feature 'say';

our $VERSION = '0.10';
$VERSION = eval $VERSION;

use Data::Dumper;
use Pegex::Base;
extends 'Pegex::Tree';

has debug => 0;

has preset_vars => {};

sub got_comment {} # strip the comments out

sub got_boolean {
    my ($self, $got) = @_;
    if (ref $got eq 'ARRAY') {
        $self->flatten($got);
        $got = shift @$got;
    }
    return ($got eq 'true') ? 1 : 0;
}

sub got_variable {
    my ($self, $got) = @_;
    if (ref $got eq 'ARRAY') {
        $self->flatten($got);
        $got = shift @$got;
    }
    return "\$$got" if exists $self->preset_vars->{$got};
    $self->parser->throw_error("$got is not a defined variable\n");
}

sub got_price {
    my ($self, $got) = @_;
    if (ref $got eq 'ARRAY') {
        $self->flatten($got);
        $got = shift @$got;
    }
    return $got;
}

sub final {
    my ($self, $got) = @_;
    $self->flatten($got) if ref $got eq 'ARRAY';
    say Dumper($got) if $self->debug;
    return wantarray ? @$got : $got;
}

1;

package App::financeta::language;
use strict;
use warnings;
use 5.10.0;
use feature 'say';

our $VERSION = '0.10';
$VERSION = eval $VERSION;

use Carp;
use Pegex::Parser;
use App::financeta::mo;

$| = 1;
has debug => 0;

has preset_vars => {};

has grammar => (default => sub {
    return App::financeta::language::grammar->new;
});

has receiver => (builder => '_build_receiver');

sub _build_receiver {
    my $self = shift;
    return App::financeta::language::receiver->new(
        debug => $self->debug,
        preset_vars => $self->preset_vars,
    );
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
    my ($self, $text, $presets) = @_;
    return unless (defined $text and length $text);
    # update the preset vars if necessary
    $self->receiver->preset_vars($presets || $self->preset_vars);
    return $self->parser->parse($text);
}

1;

__END__
### COPYRIGHT: 2014 Vikas N. Kumar. All Rights Reserved.
### AUTHOR: Vikas N Kumar <vikas@cpan.org>
### DATE: 3rd Sept 2014
### LICENSE: Refer LICENSE file
