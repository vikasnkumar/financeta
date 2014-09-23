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

use Pegex::Base;
extends 'Pegex::Tree';

has debug => 0;

has preset_vars => {};

has const_vars => {
    positive => 1e-6,
    negative => -1e-6,
    zero => 0,
    lookback => 1,
};

has local_vars => {};

has index_vars => 0;

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
    $got = lc $got; # case-insensitive
    return "\$$got" if exists $self->preset_vars->{$got};
    return "\$$got" if exists $self->local_vars->{$got};
    $self->local_vars->{$got} = 1;
}

sub got_quantity {
    my ($self, $got) = @_;
    if (ref $got eq 'ARRAY') {
        $self->flatten($got);
        $got = shift @$got;
    }
    return 'QTY::' . $got;
}

sub got_price {
    my ($self, $got) = @_;
    if (ref $got eq 'ARRAY') {
        $self->flatten($got);
        $got = shift @$got;
    }
    return { price => $got };
}

sub got_value_expression {
    my ($self, $got) = @_;
    if (ref $got eq 'ARRAY') {
        $self->flatten($got);
        XXX {value_expression => $got};
    }
    return $got;
}

sub got_buy_sell {
    my ($self, $got) = @_;
    if (ref $got eq 'ARRAY') {
        $self->flatten($got);
        $got = shift @$got;
    }
    return { trigger => lc $got };
}

sub got_compare_op {
    my ($self, $got) = @_;
    $got = lc $got;
    $got = '==' if ($got eq 'is' or $got eq 'equals');
    return { compare => $got};
}

sub got_not_op {
    my ($self, $got) = @_;
    $got = lc $got;
    $got = '!' if $got eq 'not';
    return { complement => $got };
}

sub got_logic_op {
    my ($self, $got) = @_;
    $got = lc $got;
    $got = '&&' if $got eq 'and';
    $got = '||' if $got eq 'or';
    return { logic => $got };
}

sub got_state_op_pre {
    my ($self, $got) = @_;
    return 'ACT::' . lc $got;
}

sub got_state_op_post {
    my ($self, $got) = @_;
    return 'DIRXN::' . lc $got;
}

sub got_state {
    my ($self, $got) = @_;
    if (ref $got eq 'ARRAY') {
        $self->flatten($got);
        XXX {state => $got};
    }
    return $got if $got =~ /^\$/;
    $got = 0 if $got eq 'zero';
    return 'STATE::' . lc $got;
}

sub got_comparison_state {
    my ($self, $got) = @_;
    if (ref $got eq 'ARRAY') {
        $self->flatten($got);
    } else {
        XXX {comparison_state => $got};
    }
    my ($var, $act, $state, $dirxn) = @$got;
    my $fn;
    if ($act eq 'ACT::becomes') {
        if ($state =~ /^\$/) {
            # state is a variable
            $fn = 'merge';
        } else {
            $state =~ s/^STATE:://;
            # use the const_var values
            $state = $self->const_vars->{$state} if $state =~ /\w/;
            $fn = 'become';
        }
    } elsif ($act eq 'ACT::crosses') {
        $dirxn = 'DIRXN::below' unless defined $dirxn;
        $fn = "x$1" if $dirxn =~ /DIRXN::(.*)/;
        if ($state =~ /STATE::(.*)/) {
            $state = $1;
            # use the const_var values
            $state = $self->const_vars->{$state} if $state =~ /\w/;
        }
    } else {
        XXX {comparison_state => $got};
    }
    unless (defined $fn) {
        XXX {comparison_state => $got};
    }
    return { $fn => [ $var, $state ] };
}

sub got_order {
    my ($self, $got) = @_;
    $self->flatten($got) if ref $got eq 'ARRAY';
    my $res = {};
    # merge the order trigger details into one hash
    foreach (@$got) {
        if (ref $_ eq 'HASH') {
            $res = { %$res, %{$_} };
        } else {
            XXX {order => $got};
        }
    }
    return { order => $res };
}

sub got_conditions {
    my ($self, $got) = @_;
    # conditions have to be in the order that the user asked them
    return { conditions => $got };
}

sub got_instruction {
    my ($self, $got) = @_;
    my $res = {};
    # merge the order trigger details into one hash
    foreach (@$got) {
        if (ref $_ eq 'HASH') {
            $res = { %$res, %{$_} };
        } else {
            XXX { instruction => $got };
        }
    }
    return $res;
}

sub final {
    my ($self, $got) = @_;
    $self->flatten($got) if ref $got eq 'ARRAY';
    YYY $got if $self->debug;
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
    # update the debug flag to keep it dynamic
    $self->receiver->debug($self->debug);
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
