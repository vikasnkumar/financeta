package App::financeta::tradereport;
use strict;
use warnings;
use 5.10.0;
use feature 'say';

our $VERSION = '0.10';
$VERSION = eval $VERSION;

use App::financeta::mo;
use Carp;
use File::ShareDir 'dist_file';
use File::HomeDir;
use DateTime;
use POE 'Loop::Prima';
use Prima qw(Application DetailedList ScrollWidget MsgBox StdDlg);
use PDL::Lite;

$| = 1;
has debug => 0;
has parent => undef;
has main => (builder => '_build_main');
has icon => (builder => '_build_icon');
has brand => __PACKAGE__;
has tab_name => undef;

sub _build_icon {
    my $self = shift;
    my $icon_path = dist_file('App-financeta', 'icon.gif');
    my $icon = Prima::Icon->create;
    say "Icon path: $icon_path" if $self->debug;
    $icon->load($icon_path) or carp "Unable to load $icon_path";
    return $icon;
}

sub _build_main {
    my $self = shift;
    my $mw = new Prima::Window(
        name => 'tradereport',
        text => $self->brand,
        size => [640, 480],
        owner => $self->parent->main,
        centered => 1,
        # force border styles for consistency
        borderIcons => bi::All,
        borderStyle => bs::Sizeable,
        windowState => ws::Normal,
        icon => $self->icon,
        # origin
        left => 10,
        top => 0,
        visible => 0,
        menuItems => [[
            '~Action' => [
                [
                    'save_report', '~Save', 'Ctrl+S', '^S',
                    sub {
                        my ($win, $item) = @_;
                        my $trw = $win->menu->data($item);
                        $trw->save;
                    },
                    $self,
                ],
                [
                    'close_window', '~Close', 'Ctrl+W', '^W',
                    sub {
                        my ($win, $item) = @_;
                        my $trw = $win->menu->data($item);
                        $trw->close;
                    },
                    $self,
                ],
            ],
        ]],
        onDestroy => sub {
            if ($self->parent and $self->tab_name) {
                $self->parent->close_tradereport($self->tab_name);
            }
        },
    );
    $self->_create_sheet($mw, []);
    $self->_create_label($mw, 0.0);
    return $mw;
}

sub _create_label {
    my ($self, $mw, $grosspnl) = @_;
    my $txt = sprintf "Net Income: \$%0.02f", $grosspnl;
    my $color = ($grosspnl > 0) ? cl::Blue : cl::Red;
    my @sz = $mw->size;
    return $mw->insert('Label',
        name => 'tradereport_label',
        pack => { fill => 'both' },
        text => $txt,
        origin => [20, 20],
        autoHeight => 1,
        width => $sz[0],
        alignment => ta::Left,
        font => { height => 14, style => fs::Bold },
        color => $color,
        hint => 'This is the sum total P&L',
    );
}

sub _create_sheet {
    my ($self, $mw, $items) = @_;
    my @sz = $mw->size;
    $sz[0] *= 0.80;
    $sz[1] *= 0.80;
    my $headers = ['Date', 'Entry', 'Price($)', 'Quantity', 'Date', 'Exit', 'Price($)',
        'Quantity', 'Net($)'];
    return $mw->insert('DetailedList',
        name => 'tradereport_sheet',
        pack => { expand => 1, fill => 'both' },
        items => $items || [],
        origin => [ 10, 40 ],
        headers => $headers,
        hScroll => 1,
        vScroll => 1,
        growMode => gm::Client | gm::GrowHiX | gm::GrowHiY,
        columns => scalar @$headers,
        size => \@sz,
        visible => 1,
        onSort => sub {
            my ($p, $col, $dir) = @_;
            return if $col != 1; # only sort by date which is the first column
            if ($dir) {
                $p->{items} = [
                    sort {$$a[$col] <=> $$b[$col]}
                    @{$self->{items}}
                ];
            } else {
                $p->{items} = [
                    sort {$$b[$col] <=> $$a[$col]}
                    @{$self->{items}}
                ];
            }
            $p->clear_event;
        },
    );
}

sub update {
    my ($self, $tabname, $buysells) = @_;
    $self->tab_name($tabname) if defined $tabname;
    return unless defined $buysells;
    my $longs = $buysells->{longs};
    my $shorts = $buysells->{shorts};
    my $qty = $buysells->{quantity};
    my @items = ();
    my $tz = $self->parent->timezone;
    my $grosspnl = $buysells->{longs_pnl} + $buysells->{shorts_pnl};
    if (defined $longs and not $longs->isnull and not $longs->isempty) {
        my $longitems = $longs->transpose->unpdl;     
        foreach my $arr (@$longitems) {
            my $dt1 = DateTime->from_epoch(epoch => $arr->[0], time_zone => $tz)->ymd('-');
            my $dt2 = DateTime->from_epoch(epoch => $arr->[2], time_zone => $tz)->ymd('-');
            my $pnl = sprintf "%0.02f", (($arr->[3] - $arr->[1]) * $qty);
            my $row = [ $dt1, 'BUY', $arr->[1], $qty, $dt2, 'SELL', $arr->[3], $qty, $pnl ];
            push @items, $row;
        }
    }
    if (defined $shorts and not $shorts->isnull and not $shorts->isempty) {
        my $shortitems = $shorts->transpose->unpdl;     
        foreach my $arr (@$shortitems) {
            my $dt1 = DateTime->from_epoch(epoch => $arr->[0], time_zone => $tz)->ymd('-');
            my $dt2 = DateTime->from_epoch(epoch => $arr->[2], time_zone => $tz)->ymd('-');
            my $pnl = sprintf "%0.02f", (($arr->[1] - $arr->[3]) * $qty);
            my $row = [ $dt1, 'SELL', $arr->[1], $qty, $dt2, 'BUY', $arr->[3], $qty, $pnl];
            push @items, $row;
        }
    }
    $self->main->tradereport_sheet->close;
    $self->main->tradereport_label->close;
    $self->_create_sheet($self->main, \@items);
    $self->_create_label($self->main, $grosspnl);
    $self->main->show;
    $self->main->bring_to_front;
    1;
}

sub close {
    my $self = shift;
    if ($self->parent) {
        $self->parent->close_tradereport($self->tab_name);
    }
    $self->main->close;
}

sub save {
    my $self = shift;
    my @headers = $self->main->tradereport_sheet->headers;
    my $items = $self->main->tradereport_sheet->items;
    unless (scalar @$items) {
        message("Nothing to save in the report");
        return;
    }
    my $symbol = $self->tab_name;
    $symbol =~ s/tab_//g;
    my $docdir = File::HomeDir->my_documents || File::HomeDir->my_home;
    my $ext = 'csv';
    my $dlg = Prima::SaveDialog->new(
        defaultExt => $ext,
        fileName => "tradereport_$symbol",
        filter => [
            ['CSV files' => "*.$ext"],
            ['All files' => '*'],
        ],
        filterIndex => 0,
        multiSelect => 0,
        overwritePrompt => 1,
        pathMustExist => 1,
        directory => $docdir,
    );
    my $filename = $dlg->fileName if $dlg->execute;
    if ($filename) {
        if ($^O !~ /Win32/) {
            $filename = File::Spec->catfile($docdir, $filename) unless ($filename =~ /^\//);
        } else {
            $filename .= ".$ext" unless $filename =~ /\.$ext$/; #windows is weird
        }
    } else {
        carp "Saving the report was canceled.";
        return;
    }
    CORE::open (my $fh, '>', $filename) or message("Unable to open $filename to write the report");
    if ($fh) {
        say $fh join(',', @headers);
        foreach my $arr (@$items) {
            say $fh join(',', @$arr);
        }
        CORE::close $fh;
        say "Done writing $filename" if $self->debug;
    }
}

1;
__END__
### COPYRIGHT: 2014 Vikas N. Kumar. All Rights Reserved.
### AUTHOR: Vikas N Kumar <vikas@cpan.org>
### DATE: 29th Sept 2014
### LICENSE: Refer LICENSE file
