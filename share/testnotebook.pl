#!/usr/bin/env perl

use strict;
use warnings;
$| = 1;
use Prima qw(Application Notebooks MsgBox);

my $gui = Prima::MainWindow->new(
    size => [640, 480],
    menuItems => [
        [ '~Action' => [
            [ 'open_tab', '~New', 'Ctrl+N', '^N',
                sub {
                    my $win = shift;
                    # create tabbed-notebook
                    unless (grep { $_->name =~ /mynote/ } $win->get_widgets()) {
                        $win->insert('Prima::TabbedNotebook',
                            name => 'mynote',
                            size => [640, 480],
                            growMode => gm::Client,
                            style => tns::Simple,
                            origin => [0, 0],
                        );
                        print "Created tabbed notebook\n";
                    }
                    # enable close tab menu option
                    $win->menu->close_tab->enabled(1);

                    # add a tab to existing list of tabs
                    my $note = $win->mynote;
                    my $current_tabs = $note->tabs;
                    my $new_tab = scalar(@$current_tabs) + 1;
                    if (scalar @$current_tabs) {
                        $note->tabs([@{$current_tabs}, "tab$new_tab"]);
                    } else {
                        $note->tabs(["tab$new_tab"]);
                    }
                    my $pageno = $note->pageCount;
                    $note->insert_to_page($pageno, Button => name =>
                        "btn_$pageno", origin => [ 20, 20 ], text => "Button $pageno",
                        onClick => sub { message("hello from $pageno"); },
                    );
                    print "Inserted tab$new_tab to $pageno\n";
                },
            ],
            [ '-close_tab', '~Close', 'Ctrl+W', '^W',
                sub {
                    my $win = shift;
                    return unless (grep { $_->name =~ /mynote/ } $win->get_widgets());
                    my $note = $win->mynote;
                    my $idx = $note->pageIndex;
                    if ($note->pageCount == 1) {
                        $note->close;
                    } else {
                        my @widgets = $note->widgets_from_page($idx);
                        map { $_->close } @widgets if @widgets;
                        $note->Notebook->delete_page($idx);
            
                        my @ntabs = @{$note->TabSet->tabs};
                        print "Existing tabs: ", join(',', @ntabs), "\n";
                        splice(@ntabs, $idx, 1);
                        print "Updated tabs: ", join(',', @ntabs), "\n";
                
                        $note->TabSet->tabs(\@ntabs);
                    }
                },
            ],
            [ 'exit_app', '~Exit', 'Ctrl+Q', '^Q',
                sub {
                    my $win = shift;
                    $win->close if $win;
                    $::application->close;
                },
            ], ],
        ],
    ],
);


run Prima;
