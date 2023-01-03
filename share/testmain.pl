#!/usr/bin/env perl

use strict;
use warnings;
$| = 1;
use Path::Tiny qw(path);
use Prima qw(Application MsgBox);
my $curfile = path($0)->absolute;
print $curfile, "\n";

my $icon_path = $curfile->sibling('chart-line-solid.png');
my $editor_gui;
my $another_gui;
my $gui;
$gui = Prima::MainWindow->new(
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
            [ 'second_item', '~Editor', 'Ctrl+S', '^S',
                sub {
                    my ($w, $item) = @_;
                    print "$item called\n";
                    $editor_gui = Prima::Window->new(
                        name => 'editor',
                        size => [640, 480],
                        text => 'Test Icon 2',
                        centered => 1, 
                        borderIcons => bi::All,
                        borderStyle => bs::Sizeable,
                        windowState => ws::Normal,
                        icon => Prima::Icon->load($icon_path),
                        owner => $gui,
                        menuItems => [[
                            '~Editor' => [
                                [
                                    'editor_one', '~Save', 'Ctrl+S', '^S',
                                    sub {
                                        my ($w2, $i2) = @_;
                                        print "$i2 called\n";
                                    },
                                ],
                                [
                                    'editor_quit', '~Close', 'Ctrl+W', '^W',
                                    sub {
                                        my ($w2, $i2) = @_;
                                        print "$i2 called\n";
                                        $w2->close;
                                    },
                                ],
                            ],
                        ]],
                    );
                    $editor_gui->show;
                },
            ],
            [ 'third_item', '~Another Window', 'Ctrl+S', '^S',
                sub {
                    my ($w, $item) = @_;
                    print "$item called\n";
                    $another_gui = Prima::Window->new(
                        name => 'another',
                        size => [640, 480],
                        text => 'Test Icon 3',
                        centered => 1, 
                        borderIcons => bi::All,
                        borderStyle => bs::Sizeable,
                        windowState => ws::Normal,
                        owner => $gui,
                        menuItems => [[
                            '~Another' => [
                                [
                                    'another_one', '~Save', 'Ctrl+S', '^S',
                                    sub {
                                        my ($w2, $i2) = @_;
                                        print "$i2 called\n";
                                    },
                                ],
                                [
                                    'another_quit', '~Close', 'Ctrl+W', '^W',
                                    sub {
                                        my ($w2, $i2) = @_;
                                        print "$i2 called\n";
                                        $w2->close;
                                    },
                                ],
                            ],
                        ]],
                    );
                    $another_gui->show;
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
