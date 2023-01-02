#!/usr/bin/env perl

use strict;
use warnings;
$| = 1;
use Prima qw(Application MsgBox);

my $icon_path = 'chart-line-solid.png';
my $gui = Prima::MainWindow->new(
    size => [640, 480],
    text => "Test Icon",
    centered => 1,
    borderIcons => bi::All,
    borderStyle => bs::Sizeable,
    windowState => ws::Normal,
    icon => Prima::Icon->load($icon_path),
    ownerIcon => 1,
    menuItems => [
        [ '~Action' => [
            [ 'first_item', '~First', 'Ctrl+F', '^F',
                sub {
                    my ($w, $item) = @_;
                    print "$item called\n";
                },
            ],
            [ '-second_item', '~Second', 'Ctrl+S', '^S',
                sub {
                    my ($w, $item) = @_;
                    print "$item called\n";
                },
            ],
            [ 'exit_app', '~Exit', 'Ctrl+Q', '^Q',
                sub {
                    my ($w, $item) = @_;
                    print "$item called\n";
                    $w->close if $w;
                    $::application->close;
                },
            ], ],
        ],
    ],
);
run Prima;
