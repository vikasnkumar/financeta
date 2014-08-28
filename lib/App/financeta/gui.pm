package App::financeta::gui;
use strict;
use warnings;
use 5.10.0;
use feature 'say';

our $VERSION = '0.08';
$VERSION = eval $VERSION;

use App::financeta::mo;
use Carp;
use File::Spec;
use File::ShareDir 'dist_file';
use DateTime;
use POE 'Loop::Prima';
use Prima qw(
    Application Buttons MsgBox Calendar ComboBox Notebooks
    ScrollWidget DetailedList
);
use Prima::Utils ();
use Data::Dumper;
use Capture::Tiny ();
use Finance::QuoteHist;
use PDL::Lite;
use PDL::IO::Misc;
use PDL::NiceSlice;
use PDL::Graphics::Gnuplot;
use App::financeta::indicators;
use Scalar::Util qw(blessed);
use Browser::Open ();

$PDL::doubleformat = "%0.6lf";
$| = 1;
has debug => 0;
has timezone => 'America/New_York';
has brand => (default => sub { __PACKAGE__ });
has main => (builder => '_build_main');
has icon => (builder => '_build_icon');
has tmpdir => ( default => sub {
    return $ENV{TEMP} || $ENV{TMP} if $^O =~ /Win32|Cygwin/i;
    return $ENV{TMPDIR} || '/tmp';
});
has plot_engine => 'gnuplot';
has current => {};
has indicator => (builder => '_build_indicator');

sub _build_indicator {
    my $self = shift;
    return App::financeta::indicators->new(debug => $self->debug,
                                            plot_engine => $self->plot_engine);
}

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
    my $mw = new Prima::MainWindow(
        name => 'main',
        text => $self->brand,
        size => [800, 600],
        centered => 1,
        menuItems => $self->_menu_items,
        # force border styles for consistency
        borderIcons => bi::All,
        borderStyle => bs::Sizeable,
        windowState => ws::Normal,
        icon => $self->icon,
        # origin
        left => 10,
        top => 0,
    );
    $mw->maximize;
    return $mw;
}

sub _menu_items {
    my $self = shift;
    return [
        [
            '~Security' => [
                [
                    'security_wizard', '~New', 'Ctrl+N', '^N',
                    sub {
                        my ($win, $item) = @_;
                        my $gui = $win->menu->data($item);
                        if ($gui->security_wizard($win)) {
                            my $bar = $gui->progress_bar_create($win,
                                'Downloading...');
                            # download security data
                            my ($data, $symbol) = $gui->download_data($bar);
                            if (defined $data) {
                                $gui->display_data($win, $data);
                                my $type = $gui->current->{plot_type} || 'OHLC';
                                $gui->plot_data($win, $data, $symbol, $type);
                                $win->menu->security_close->enabled(1);
                                $win->menu->plot_ohlc->enabled(1);
                                $win->menu->plot_ohlcv->enabled(1);
                                $win->menu->plot_close->enabled(1);
                                $win->menu->plot_closev->enabled(1);
                                $win->menu->plot_cdl->enabled(1);
                                $win->menu->plot_cdlv->enabled(1);
                                $win->menu->add_indicator->enabled(1);
                            }
                            $gui->progress_bar_close($bar);
                        }
                    },
                    $self,
                ],
                [
                    '-security_close', '~Close', 'Ctrl+W', '^W',
                    sub {
                        my ($win, $item) = @_;
                        my $gui = $win->menu->data($item);
                        $gui->close_current_tab($win);
                    },
                    $self,
                ],
                [
                    'app_exit', 'E~xit', 'Ctrl+Q', '^Q',
                    sub {
                        my ($win, $item) = @_;
                        my $gui = $win->menu->data($item);
                        $gui->close_all($win);
                    },
                    $self,
                ],
            ],
        ],
        [
            '~Plot' => [
                [
                    '-*plot_ohlc', 'OHLC', '', '',
                    sub {
                        my ($win, $item) = @_;
                        my $gui = $win->menu->data($item);
                        my ($data, $symbol, $indicators) = $gui->get_tab_data($win);
                        $gui->plot_data($win, $data, $symbol, 'OHLC', $indicators);
                        $win->menu->check('plot_ohlc');
                        $win->menu->uncheck('plot_ohlcv');
                        $win->menu->uncheck('plot_close');
                        $win->menu->uncheck('plot_closev');
                        $win->menu->uncheck('plot_cdl');
                        $win->menu->uncheck('plot_cdlv');
                    },
                    $self,
                ],
                [
                    '-plot_ohlcv', 'OHLC & Volume', '', '',
                    sub {
                        my ($win, $item) = @_;
                        my $gui = $win->menu->data($item);
                        my ($data, $symbol, $indicators) = $gui->get_tab_data($win);
                        $gui->plot_data($win, $data, $symbol, 'OHLCV', $indicators);
                        $win->menu->check('plot_ohlcv');
                        $win->menu->uncheck('plot_ohlc');
                        $win->menu->uncheck('plot_close');
                        $win->menu->uncheck('plot_closev');
                        $win->menu->uncheck('plot_cdl');
                        $win->menu->uncheck('plot_cdlv');
                    },
                    $self,
                ],
                [
                    '-plot_close', 'Close Price', '', '',
                    sub {
                        my ($win, $item) = @_;
                        my $gui = $win->menu->data($item);
                        my ($data, $symbol, $indicators) = $gui->get_tab_data($win);
                        $gui->plot_data($win, $data, $symbol, 'CLOSE', $indicators);
                        $win->menu->check('plot_close');
                        $win->menu->uncheck('plot_ohlc');
                        $win->menu->uncheck('plot_ohlcv');
                        $win->menu->uncheck('plot_closev');
                        $win->menu->uncheck('plot_cdl');
                        $win->menu->uncheck('plot_cdlv');
                    },
                    $self,
                ],
                [
                    '-plot_closev', 'Close Price & Volume', '', '',
                    sub {
                        my ($win, $item) = @_;
                        my $gui = $win->menu->data($item);
                        my ($data, $symbol, $indicators) = $gui->get_tab_data($win);
                        $gui->plot_data($win, $data, $symbol, 'CLOSEV', $indicators);
                        $win->menu->check('plot_closev');
                        $win->menu->uncheck('plot_ohlc');
                        $win->menu->uncheck('plot_ohlcv');
                        $win->menu->uncheck('plot_close');
                        $win->menu->uncheck('plot_cdl');
                        $win->menu->uncheck('plot_cdlv');
                    },
                    $self,
                ],
                [
                    '-plot_cdl', 'Candlesticks', '', '',
                    sub {
                        my ($win, $item) = @_;
                        my $gui = $win->menu->data($item);
                        my ($data, $symbol, $indicators) = $gui->get_tab_data($win);
                        $gui->plot_data($win, $data, $symbol, 'CANDLE', $indicators);
                        $win->menu->check('plot_cdl');
                        $win->menu->uncheck('plot_ohlc');
                        $win->menu->uncheck('plot_ohlcv');
                        $win->menu->uncheck('plot_close');
                        $win->menu->uncheck('plot_closev');
                        $win->menu->uncheck('plot_cdlv');
                    },
                    $self,
                ],
                [
                    '-plot_cdlv', 'Candlesticks & Volume', '', '',
                    sub {
                        my ($win, $item) = @_;
                        my $gui = $win->menu->data($item);
                        my ($data, $symbol, $indicators) = $gui->get_tab_data($win);
                        $gui->plot_data($win, $data, $symbol, 'CANDLEV', $indicators);
                        $win->menu->check('plot_cdlv');
                        $win->menu->uncheck('plot_ohlc');
                        $win->menu->uncheck('plot_ohlcv');
                        $win->menu->uncheck('plot_close');
                        $win->menu->uncheck('plot_closev');
                        $win->menu->uncheck('plot_cdl');
                    },
                    $self,
                ],
            ],
        ],
        [
            '~Analysis' => [
                [
                    '-add_indicator', 'Add Indicator', 'Ctrl+I', '^I',
                    sub {
                        my ($win, $item) = @_;
                        my $gui = $win->menu->data($item);
                        my ($data, $symbol, $indicators) = $gui->get_tab_data($win);
                        # ok add an indicator which also plots it
                        if ($gui->add_indicator($win, $data, $symbol)) {
                            $win->menu->remove_indicator->enabled(1);
                        }
                    },
                    $self,
                ],
                [
                    '-remove_indicator', 'Remove Indicator', 'Ctrl+Shift+I', '^#I',
                    sub {
                        my ($win, $item) = @_;
                        my $gui = $win->menu->data($item);
                        # ok remove the indicator and update the plots and
                        # display tables
                        $gui->remove_indicator($win);
                    },
                    $self,
                ],
            ],
        ],
        [
            '~Help' => [
                [
                    'help_viewer', 'Documentation', 'F1', kb::F1,
                    sub {
                        my $url = 'https://vikasnkumar.github.io/financeta/';
                        my $ok = Browser::Open::open_browser($url, 1);
                        if (not defined $ok) {
                            message("Error finding a browser to open $url");
                        } elsif ($ok != 0) {
                            message("Error opening $url");
                        }
                    },
                    $self,
                ],
                [
                    'about_logo', 'About Logo', '', kb::NoKey,
                    sub {
                        message_box('About Logo', 'http://www.perl.com',
                                mb::Ok | mb::Information);
                    }, $self,
                ],
            ],
        ],
    ];
}

sub close_all {
    my ($self, $win) = @_;
    my $pwin = $win->{plot};
    $pwin->close if $pwin;
    say "Closing all open windows" if $self->debug;
    $win->close if $win;
    $::application->close;
}

sub run {
    my $self = shift;
    $self->main->show;
    $self->disable_menu_options; # to be safe
    run Prima;
}

sub progress_bar_create {
    my ($self, $win, $text) = @_;
    $text = 'Loading...' unless length $text;
    my $bar = Prima::Window->create(
        name => 'progress_bar',
        text => $text,
        size => [160, 100],
        origin => [0, 0],
        widgetClass => wc::Dialog,
        borderStyle => bs::Dialog,
        borderIcons => 0,
        centered => 1,
        owner => $win,
        visible => 1,
        pointerType => cr::Wait,
        onPaint => sub {
            my ($w, $canvas) = @_;
            $canvas->color(cl::Blue);
            $canvas->bar(0, 0, $w->{-progress}, $w->height);
            $canvas->color(cl::Back);
            $canvas->bar($w->{-progress}, 0, $w->size);
            $canvas->color(cl::Yellow);
            $canvas->font(size => 16, style => fs::Bold);
            $canvas->text_out($w->text, 0, 10);
        },
        syncPaint => 1,
        onTop => 1,
    );
    $bar->{-progress} = 0;
    $bar->repaint;
    $win->pointerType(cr::Wait);
    $win->repaint;
    return $bar;
}

sub progress_bar_update {
    my ($self, $bar) = @_;
    if ($bar and defined $bar->{-progress}) {
        $bar->{-progress} += 5;
        $bar->repaint;
    }
}

sub progress_bar_close {
    my ($self, $bar) = @_;
    if ($bar) {
        $bar->owner->pointerType(cr::Default);
        $bar->close;
    }
}

sub security_wizard {
    my ($self, $win) = @_;
    my $w = Prima::Dialog->new(
        name => 'sec_wizard',
        centered => 1,
        origin => [200, 200],
        size => [640, 480],
        text => 'Security Wizard',
        icon => $self->icon,
        visible => 1,
        taskListed => 0,
        onExecute => sub {
            my $dlg = shift;
            my $sec = $self->current->{symbol} || '';
            $dlg->input_symbol->text($sec);
            $dlg->btn_ok->enabled(length($sec) ? 1 : 0);
            $dlg->btn_cancel->enabled(1);
            if ($self->current->{start_date}) {
                my $dt = $self->current->{start_date};
                $dlg->cal_start->date($dt->day, $dt->month - 1, $dt->year - 1900);
            } else {
                $dlg->cal_start->date_from_time(gmtime);
                # reduce 1 year
                my $yr = $dlg->cal_start->year;
                $dlg->cal_start->year($yr - 1);
            }
            if ($self->current->{end_date}) {
                my $dt = $self->current->{end_date};
                $dlg->cal_end->date($dt->day, $dt->month - 1, $dt->year - 1900);
            } else {
                $dlg->cal_end->date_from_time(gmtime);
            }
            $dlg->chk_force_download->checked(0);
            $self->current->{force_download} = 0;
        },
    );
    $w->owner($win) if defined $win;
    $w->insert(
        Label => text => 'Enter Security Symbol',
        name => 'label_symbol',
        alignment => ta::Left,
        autoHeight => 1,
        origin => [ 20, 440],
        autoWidth => 1,
        font => { height => 14, style => fs::Bold },
        hint => 'Stock symbols are available at Yahoo! Finance',
    );
    $w->insert(
        InputLine => name => 'input_symbol',
        alignment => ta::Left,
        autoHeight => 1,
        width => 100,
        autoTab => 1,
        maxLen => 10,
        origin => [ 200, 440],
        font => { height => 16 },
        onChange => sub {
            my $inp = shift;
            my $owner = $inp->owner;
            unless (length $inp->text) {
                $owner->btn_ok->enabled(0);
            } else {
                $owner->btn_ok->enabled(1);
            }
        },
    );
    $w->insert(
        Button => name => 'btn_help',
        text => 'Symbol Search',
        height => 20,
        autoWidth => 1,
        origin => [340, 440],
        default => 0,
        enabled => 1,
        font => { height => 12, style => fs::Bold },
        onClick => sub {
            my $url = 'http://finance.yahoo.com';
            my $ok = Browser::Open::open_browser($url, 1);
            if (not defined $ok) {
                message("Error finding a browser to open $url");
            } elsif ($ok != 0) {
                message("Error opening $url");
            }
        },
    );
    $w->insert(
        Label => text => 'Select Start Date',
        name => 'label_enddate',
        alignment => ta::Center,
        autoHeight => 1,
        autoWidth => 1,
        origin => [ 20, 410 ],
        font => { height => 14, style => fs::Bold },
    );
    $w->insert(
        Calendar => name => 'cal_start',
        useLocale => 1,
        size => [ 220, 200 ],
        origin => [ 20, 200 ],
        font => { height => 16 },
        onChange => sub {
            my $cal = shift;
            $self->current->{start_date} = new DateTime(
                year => 1900 + $cal->year(),
                month => 1 + $cal->month(),
                day => $cal->day(),
                time_zone => $self->timezone,
            );
        },
    );
    $w->insert(
        Label => text => 'Select End Date',
        name => 'label_enddate',
        alignment => ta::Center,
        autoHeight => 1,
        autoWidth => 1,
        origin => [ 260, 410 ],
        font => { height => 14, style => fs::Bold },
    );
    $w->insert(
        Calendar => name => 'cal_end',
        useLocale => 1,
        size => [ 220, 200 ],
        origin => [ 260, 200 ],
        font => { height => 16 },
        onChange => sub {
            my $cal = shift;
            $self->current->{end_date} = new DateTime(
                year => 1900 + $cal->year(),
                month => 1 + $cal->month(),
                day => $cal->day(),
                time_zone => $self->timezone,
            );
        },
    );
    $w->insert(
        CheckBox => name => 'chk_force_download',
        text => 'Force Download',
        origin => [ 20, 170 ],
        font => { height => 14, style => fs::Bold },
        onCheck => sub {
            my $chk = shift;
            my $owner = $chk->owner;
            if ($chk->checked) {
                $self->current->{force_download} = 1;
            } else {
                $self->current->{force_download} = 0;
            }
        },
    );
    $w->insert(
        Button => name => 'btn_cancel',
        text => 'Cancel',
        autoHeight => 1,
        autoWidth => 1,
        origin => [ 20, 40 ],
        modalResult => mb::Cancel,
        default => 0,
        enabled => 1,
        font => { height => 16, style => fs::Bold },
        onClick => sub {
            delete $self->current->{symbol};
            delete $self->current->{start_date};
            delete $self->current->{end_date};
            delete $self->current->{force_download};
        },
    );
    $w->insert(
        Button => name => 'btn_ok',
        text => 'OK',
        autoHeight => 1,
        autoWidth => 1,
        origin => [ 150, 40 ],
        modalResult => mb::Ok,
        default => 1,
        enabled => 0,
        font => { height => 16, style => fs::Bold },
        onClick => sub {
            my $btn = shift;
            my $owner = $btn->owner;
            $self->current->{symbol} = $owner->input_symbol->text;
            unless (defined $self->current->{start_date}) {
                my $cal = $owner->cal_start;
                $self->current->{start_date} = new DateTime(
                    year => 1900 + $cal->year(),
                    month => 1 + $cal->month(),
                    day => $cal->day(),
                    time_zone => $self->timezone,
                );
            }
            unless (defined $self->current->{end_date}) {
                my $cal = $owner->cal_end;
                $self->current->{end_date} = new DateTime(
                    year => 1900 + $cal->year(),
                    month => 1 + $cal->month(),
                    day => $cal->day(),
                    time_zone => $self->timezone,
                );
            }
        },
    );
    my $res = $w->execute();
    $w->end_modal;
    return $res == mb::Ok;
}

sub remove_indicator($) {
    my ($self, $win) = @_;
    my $result = $self->remove_indicator_wizard($win);
    if ($result and ref $result eq 'HASH') {
        say "Removing indicator: ", Dumper($result) if $self->debug;
        # we know here the name of the indicator, the index of the indicator and
        # the columns in the data to remove.
        # let's do that.
        my ($data, $symbol, $indicators, $headers) = $self->get_tab_data_by_name($win, $result->{tab});
        return unless $headers;
        my $total_cols = $data->dim(1);
        my @ncols = (0 .. $total_cols - 1); # get a list of column numbers
        my @nhdrs = (@$headers);
        return unless $result->{columns};
        my @cols2rem = @{$result->{columns}};
        foreach my $c (@cols2rem) {
            $ncols[$c] = undef;
            $nhdrs[$c] = undef;
        }
        @nhdrs = grep { defined $_ } @nhdrs;
        @ncols = grep { defined $_ } @ncols;
        say "New Headers: ", Dumper(\@nhdrs) if $self->debug;
        say "Remaining columns: ", Dumper(\@ncols) if $self->debug;
        my $ndata = $data->dice('X', \@ncols);
        my $nindics = [];
        if ($indicators) {
            my $index = $result->{indicator_index};
            for (0 .. scalar(@$indicators) - 1) {
                next if $_ == $index;
                push @$nindics, $indicators->[$_];
            }
        }
        if ($self->set_tab_data_by_name($win, $result->{tab}, $ndata, $symbol, $nindics, \@nhdrs)) {
            say "Successfully set data" if $self->debug;
            $self->display_data($win, $ndata, $symbol);
            my ($adata, $asymbol, $aindicators) = $self->get_tab_data($win);
            my $type = $self->current->{plot_type} || 'OHLC';
            $self->plot_data($win, $adata, $asymbol, $type, $aindicators);
            # disable remove indicator if there are no indicators left
            unless (scalar @$aindicators) {
                #$self->main->menu->remove_indicator->enabled(0);
            }
        }
    }
}

sub remove_indicator_wizard {
    my ($self, $win) = @_;
    my $w = Prima::Dialog->new(
        name => 'rem_ind_wizard',
        centered => 1,
        origin => [200, 200],
        size => [640, 280],
        text => 'Remove Indicator Wizard',
        icon => $self->icon,
        visible => 1,
        taskListed => 0,
        onExecute => sub {
            my $dlg = shift;
            $dlg->cbox_tabs->List->focusedItem(-1);
            $dlg->cbox_inds->List->focusedItem(-1);
            $dlg->btn_cancel->enabled(1);
            $dlg->btn_ok->enabled(0);
        },
    );
    $w->owner($win) if defined $win;
    my %tabs = $self->get_tab_names($win);
    say "Current tabs: ", Dumper(\%tabs) if $self->debug;
    my $result = {};
    $w->insert(Label => name => 'label_tabs',
        text => 'Select Security',
        font => { style => fs::Bold, height => 16 },
        alignment => ta::Left,
        autoHeight => 1,
        autoWidth => 1,
        origin => [20, 240],
        hint => 'This is a list of already open tabs',
        hintVisible => 1,
    );
    $w->insert(ComboBox =>
        name => 'cbox_tabs',
        style => cs::DropDownList,
        height => 30,
        width => 360,
        hScroll => 0,
        multiSelect => 0,
        multiColumn => 0,
        dragable => 0,
        focusedItem => -1,
        font => { height => 14 },
        items => ['', keys %tabs],
        origin => [180, 240],
        onChange => sub {
            my $cbox = shift;
            my $owner = $cbox->owner;
            my $lbox = $cbox->List;
            my $index = $lbox->focusedItem;
            my $txt = $lbox->get_item_text($index);
            if (defined $txt and length $txt) {
                my $indicators = $self->get_tab_indicators($owner->owner, $txt);
                my @inds = ();
                if ($indicators) {
                    foreach (@$indicators) {
                        push @inds, $_->{indicator}->{func};
                    }
                }
                say "Current indicators for tab $txt: ", Dumper(\@inds) if $self->debug;
                if (scalar @inds) {
                    $owner->cbox_inds->items(\@inds);
                    $owner->btn_ok->enabled(1);
                } else {
                    $owner->cbox_inds->items([]);
                    $owner->btn_ok->enabled(0);
                }
                $result->{tab} = $txt;
            } else {
                $owner->cbox_inds->items([]);
                $owner->cbox_inds->focusedItem(-1);
                $owner->cbox_inds->text('');
                $owner->btn_ok->enabled(0);
                delete $result->{tab};
            }
        },
    );
    $w->cbox_tabs->text('');
    $w->insert(Label => name => 'label_inds',
        text => 'Select Indicator',
        font => { style => fs::Bold, height => 16 },
        alignment => ta::Left,
        autoHeight => 1,
        autoWidth => 1,
        origin => [20, 200],
        hint => 'These indicators are already present in the selected tab',
        hintVisible => 1,
    );
    $w->insert(ComboBox =>
        name => 'cbox_inds',
        style => cs::DropDownList,
        height => 30,
        width => 360,
        hScroll => 0,
        font => { height => 14 },
        multiSelect => 0,
        multiColumn => 0,
        dragable => 0,
        focusedItem => -1,
        text => '',
        items => [],
        origin => [180, 200],
        onChange => sub {
            my $cbox = shift;
            my $owner = $cbox->owner;
            my $lbox = $cbox->List;
            my $index = $lbox->focusedItem;
            my $txt = $lbox->get_item_text($index);
            if (defined $txt) {
                $owner->btn_ok->enabled(1);
                $result->{indicator} = $txt;
                $result->{indicator_index} = $index;
            } else {
                $owner->btn_ok->enabled(0);
                $cbox->items([]);
                $cbox->focusedItem(-1);
                $cbox->text('');
                delete $result->{indicator};
                delete $result->{indicator_index};
            }
        },
    );
    $w->insert(
        Button => name => 'btn_cancel',
        text => 'Cancel',
        autoHeight => 1,
        autoWidth => 1,
        origin => [ 20, 20 ],
        modalResult => mb::Cancel,
        default => 0,
        enabled => 1,
        font => { height => 16, style => fs::Bold },
        onClick => sub {
            $result = {};
        },
    );
    $w->insert(
        Button => name => 'btn_ok',
        text => 'OK',
        autoHeight => 1,
        autoWidth => 1,
        origin => [ 150, 20 ],
        modalResult => mb::Ok,
        default => 1,
        enabled => 0,
        font => { height => 16, style => fs::Bold },
        onClick => sub {
            my $btn = shift;
            my $owner = $btn->owner;
            my $indicators = $self->get_tab_indicators($owner->owner, $result->{tab});
            my @inds = ();
            if ($indicators) {
                my $iref = $indicators->[$result->{indicator_index}]->{indicator};
                if ($iref->{func} eq $result->{indicator}) {
                    $result->{columns} = $indicators->[$result->{indicator_index}]->{columns};
                } else {
                    carp "Cannot find the columns to remove";
                }
            } else {
                carp "Invalid indicators for tab: ", $result->{tab};
            }
            say Dumper($result) if $self->debug;
        },
    );
    my $res = $w->execute();
    $w->end_modal;
    return ($res == mb::Ok) ? $result : undef;
}

sub add_indicator($$$) {
    my ($self, $win, $data, $symbol) = @_;
    if ($self->add_indicator_wizard($win)) {
        my $iref = $self->current->{indicator};
        say Dumper($iref) if $self->debug;
        my $output = $self->indicator->execute_ohlcv($data, $iref);
        unless (defined $output) {
            message_box('Indicator Error',
                "Unable to run the indicator on data.",
                mb::Ok | mb::Error);
            return;
        }
        $self->display_data($win, $data, $symbol, $iref, $output);
        my ($ndata, $nsymbol, $indicators) = $self->get_tab_data($win);
        my $type = $self->current->{plot_type} || 'OHLC';
        $self->plot_data($win, $ndata, $nsymbol, $type, $indicators);
        return 1;
    }
    0;
}

sub indicator_parameter_wizard {
    my ($self, $gbox, $fn_name, $grp, $params) = @_;
    if ($gbox) {
        # remove the current parameter screen
        my @widgets = $gbox->get_widgets;
        if (@widgets) {
            map { $_->close() } @widgets;
        }
    } else {
        return;
    }
    # if all are defined create the parameter screen
    if (defined $fn_name and defined $grp and defined $params) {
        $gbox->text("$fn_name Parameters");
        my @origin = $gbox->origin;
        my @size = $gbox->size;
        say "Gbox: Origin: @origin  Size: @size" if $self->debug;
        my $num = scalar @$params;
        my $sz_x = $size[0] / 2; # label and value
        my $sz_y = $size[1] / ($num + 1);
        my $count = 0;
        $self->current->{indicator}->{params} = {};
        # if no params just write that
        unless (scalar @$params) {
            $gbox->insert('Label',
                text => "There are no parameters to configure.",
                name => "label_$grp\_noparams",
                alignment => ta::Left,
                autoHeight => 1,
                autoWidth => 1,
                origin => [$origin[0] + 10,
                    $origin[1] + $count * $sz_y - 40],
                font => {height => 16},
            );
        }
        foreach my $p (reverse @$params) {
            next unless ref $p eq 'ARRAY';
            my $hkey = $p->[0];
            my $label = $p->[1];
            my $type = $p->[2];
            my $typeclass = blessed($type) if $type;
            my $value = $p->[3];
            if (defined $type and $type eq 'ARRAY' and ref $value eq 'ARRAY') {
                # use ComboBox
                $self->current->{indicator}->{params}->{$hkey} = $value->[0];
                $self->current->{indicator}->{params}->{$hkey . '_index'} = 0;
                $gbox->insert(Label => text => $label,
                    name => "label_$grp\_$count",
                    alignment => ta::Left,
                    autoHeight => 1,
                    autoWidth => 1,
                    origin => [$origin[0] + 10,
                                $origin[1] + $count * $sz_y - 40],
                    font => {height => 13},
                );
                $gbox->insert(ComboBox => style => cs::DropDownList,
                    name => "cbox_$grp\_$count",
                    height => 30,
                    width => $sz_x - 50,
                    autoHeight => 1,
                    font => { height => 16 },
                    hScroll => 0,
                    multiSelect => 0,
                    multiColumn => 0,
                    dragable => 0,
                    focusedItem => -1,
                    items => $value,
                    autoTab => 1,
                    origin => [$origin[0] + 10 + $sz_x,
                                $origin[1] + $count * $sz_y - 40],
                    onChange => sub {
                        my $cbox = shift;
                        my $lbox = $cbox->List;
                        my $index = $lbox->focusedItem;
                        $self->current->{indicator}->{params}->{$hkey} = $lbox->get_item_text($index);
                        $self->current->{indicator}->{params}->{$hkey . '_index'} = $index;
                    },
                );
            } elsif (defined $typeclass and $typeclass eq 'PDL::Type') {
                # use InputLine for all numbers
                $self->current->{indicator}->{params}->{$hkey} = $value;
                $gbox->insert(Label => text => $label,
                    name => "label_$grp\_$count",
                    alignment => ta::Left,
                    autoHeight => 1,
                    autoWidth => 1,
                    origin => [$origin[0] + 10,
                                $origin[1] + $count * $sz_y - 40],
                    font => {height => 13},
                );
                $gbox->insert(InputLine => name => "input_$grp\_$count",
                    alignment => ta::Left,
                    autoHeight => 1,
                    width => $sz_x - 50,
                    autoTab => 1,
                    maxLen => 20,
                    origin => [$origin[0] + 10 + $sz_x,
                                $origin[1] + $count * $sz_y - 40],
                    text => $value,
                    font => {height => 16},
                    onChange => sub {
                        my $il = shift;
                        my $val = undef;
                        my $txt = $il->text;
                        return unless length $txt;
                        if ($type->symbol eq 'PDL_B') {
                            # byte buffer
                            $val = $txt;
                        } elsif ($type->symbol eq 'PDL_F' or $type->symbol eq 'PDL_D') {
                            # is a real number
                            if ($txt =~ /^(\d+\.?\d*)|(\.\d+)$/) {
                                $val = sprintf "%0.04f", $txt;
                            } else {
                                message_box('Parameter Error',
                                    "$label has to be a real number",
                                    mb::Ok | mb::Error);
                                return;
                            }
                        } else {
                            # is an integer form
                            if ($txt =~ /^([+-]?\d+)$/) {
                                $val = sprintf "%d", $txt;
                            } else {
                                message_box('Parameter Error',
                                    "$label has to be an integer",
                                    mb::Ok | mb::Error);
                                return;
                            }
                        }
                        $self->current->{indicator}->{params}->{$hkey} = $val;
                    },
                );
            } else {
                # use checkbox
                $self->current->{indicator}->{params}->{$hkey} = ($value) ? 1 : 0;
                $gbox->insert(CheckBox => name => "chk_$grp\_$count",
                    alignment => ta::Left,
                    autoTab => 1,
                    origin => [$origin[0] + 10,
                                $origin[1] + $count * $sz_y - 40],
                    text => $label,
                    font => {height => 13},
                    onCheck => sub {
                        my $chk = shift;
                        $self->current->{indicator}->{params}->{$hkey} =
                                $chk->checked ? 1 : 0;
                    },
                );
            }
            $count++;
        }
    } else {
        $gbox->text("Indicator Parameters");
        delete $self->current->{indicator}->{params};
    }
}

sub add_indicator_wizard {
    my ($self, $win) = @_;
    my $w = Prima::Dialog->new(
        name => 'add_ind_wizard',
        centered => 1,
        origin => [200, 200],
        size => [640, 480],
        text => 'Technical Analysis Indicator Wizard',
        icon => $self->icon,
        visible => 1,
        taskListed => 0,
        onExecute => sub {
            my $dlg = shift;
            $dlg->cbox_groups->List->focusedItem(-1);
            $dlg->cbox_funcs->List->focusedItem(-1);
            $dlg->btn_cancel->enabled(1);
            $dlg->btn_ok->enabled(0);
        },
    );
    $w->owner($win) if defined $win;
    $self->current->{indicator} = {}; # reset
    my @groups = $self->indicator->get_groups;
    $w->insert(Label => name => 'label_groups',
        text => 'Select Group',
        font => { style => fs::Bold, height => 16 },
        alignment => ta::Left,
        autoHeight => 1,
        autoWidth => 1,
        origin => [20, 440],
        hint => 'This is a list of indicator groups',
        hintVisible => 1,
    );
    $w->insert(ComboBox =>
        name => 'cbox_groups',
        style => cs::DropDownList,
        height => 30,
        width => 360,
        hScroll => 0,
        multiSelect => 0,
        multiColumn => 0,
        dragable => 0,
        focusedItem => -1,
        font => { height => 14 },
        items => [ '', @groups],
        origin => [180, 440],
        onChange => sub {
            my $cbox = shift;
            my $owner = $cbox->owner;
            my $lbox = $cbox->List;
            my $index = $lbox->focusedItem;
            my $txt = $lbox->get_item_text($index);
            if (defined $txt and length $txt) {
                my @funcs = $self->indicator->get_funcs($txt);
                if (scalar @funcs) {
                    $owner->cbox_funcs->items(\@funcs);
                } else {
                    $owner->cbox_funcs->items([]);
                }
                $owner->btn_ok->enabled(1);
                $self->current->{indicator}->{group} = $txt;
            } else {
                $owner->cbox_funcs->items([]);
                $owner->cbox_funcs->focusedItem(-1);
                $self->indicator_parameter_wizard($owner->gbox_params);
                $owner->cbox_funcs->text('');
                $owner->btn_ok->enabled(0);
                delete $self->current->{indicator}->{group};
            }
        },
    );
    $w->cbox_groups->text('');
    $w->insert(Label => name => 'label_funcs',
        text => 'Select Function',
        font => { style => fs::Bold, height => 16 },
        alignment => ta::Left,
        autoHeight => 1,
        autoWidth => 1,
        origin => [20, 400],
        hint => 'Each indicator group has multiple indicators it supports',
        hintVisible => 1,
    );
    $w->insert(ComboBox =>
        name => 'cbox_funcs',
        style => cs::DropDownList,
        height => 30,
        width => 360,
        hScroll => 0,
        font => { height => 14 },
        multiSelect => 0,
        multiColumn => 0,
        dragable => 0,
        focusedItem => -1,
        text => '',
        items => [],
        origin => [180, 400],
        onChange => sub {
            my $cbox = shift;
            my $owner = $cbox->owner;
            my $lbox = $cbox->List;
            my $index = $lbox->focusedItem;
            my $txt = $lbox->get_item_text($index);
            my $grp = $self->current->{indicator}->{group};
            if (defined $grp) {
                # $params is an array-ref
                my $params = $self->indicator->get_params($txt, $grp);
                $self->current->{indicator}->{func} = $txt;
                say Dumper($params) if $self->debug;
                $owner->btn_ok->enabled(1);
                $self->indicator_parameter_wizard($owner->gbox_params,
                        $txt, $grp, $params);
            } else {
                $owner->btn_ok->enabled(0);
                $cbox->items([]);
                $cbox->focusedItem(-1);
                delete $self->current->{indicator}->{func};
                $self->indicator_parameter_wizard($owner->gbox_params);
                $cbox->text('');
            }
        },
    );
    $w->insert(
        Button => name => 'btn_cancel',
        text => 'Cancel',
        autoHeight => 1,
        autoWidth => 1,
        origin => [ 20, 20 ],
        modalResult => mb::Cancel,
        default => 0,
        enabled => 1,
        font => { height => 16, style => fs::Bold },
        onClick => sub {
            delete $self->current->{indicator};
        },
    );
    $w->insert(
        Button => name => 'btn_ok',
        text => 'OK',
        autoHeight => 1,
        autoWidth => 1,
        origin => [ 360, 20 ],
        modalResult => mb::Ok,
        default => 1,
        enabled => 0,
        font => { height => 16, style => fs::Bold },
        onClick => sub {
            say Dumper($self->current->{indicator}) if $self->debug;
        },
    );
    $w->insert(
        Button => name => 'btn_help',
        text => 'Indicator Help',
        autoHeight => 1,
        autoWidth => 1,
        origin => [ 150, 20 ],
        default => 0,
        enabled => 1,
        font => { height => 16, style => fs::Bold },
        onClick => sub {
            my $url = 'https://vikasnkumar.github.io/financeta/indicators.html';
            my $ok = Browser::Open::open_browser($url, 1);
            if (not defined $ok) {
                message("Error finding a browser to open $url");
            } elsif ($ok != 0) {
                message("Error opening $url");
            }
        },
    );
    $w->insert(GroupBox => name => 'gbox_params',
        text => 'Indicator Parameters',
        size => [600, 300],
        origin => [20, 60],
        font => { height => 16, style => fs::Bold },
    );
    my $res = $w->execute();
    $w->end_modal;
    return $res == mb::Ok;
}

sub download_data {
    my ($self, $pbar) = @_;
    $self->progress_bar_update($pbar) if $pbar;
    my $start = $self->current->{start_date};
    my $end = $self->current->{end_date};
    my $symbol = $self->current->{symbol};
    #TODO: check symbol validity
    my $csv = sprintf "%s_%d_%d.csv", $symbol, $start->ymd(''), $end->ymd('');
    $csv = File::Spec->catfile($self->tmpdir, $csv);
    $self->progress_bar_update($pbar) if $pbar;
    my $data;
    unlink $csv if $self->current->{force_download};
    unless (-e $csv) {
        my $fq = new Finance::QuoteHist(
            symbols => [ $symbol ],
            start_date => $start->mdy('/'),
            end_date => $end->mdy('/'),
            auto_proxy => 1,
        );
        $self->progress_bar_update($pbar) if $pbar;
        open my $fh, '>', $csv or die "$!";
        my @quotes = ();
        foreach my $row ($fq->quotes) {
            my ($sym, $date, $o, $h, $l, $c, $vol) = @$row;
            my ($yy, $mm, $dd) = split /\//, $date;
            my $epoch = DateTime->new(
                year => $yy,
                month => $mm,
                day => $dd,
                hour => 16, minute => 0, second => 0,
                time_zone => $self->timezone,
            )->epoch;
            say $fh "$epoch,$o,$h,$l,$c,$vol";
            push @quotes, pdl($epoch, $o, $h, $l, $c, $vol);
        }
        $self->progress_bar_update($pbar) if $pbar;
        $fq->clear_cache;
        close $fh;
        unless (scalar @quotes) {
            message_box('Error',
                "Failed to download $symbol data. Check if '$symbol' is correct",
                mb::Ok | mb::Error);
            unlink $csv;
            return;
        }
        say "$csv has downloaded data for analysis" if $self->debug;
        $self->progress_bar_update($pbar) if $pbar;
        $data = pdl(@quotes)->transpose;
        $self->progress_bar_update($pbar) if $pbar;
    } else {
        ## now read this back into a PDL using rcol
        $self->progress_bar_update($pbar) if $pbar;
        say "$csv already present. loading it..." if $self->debug;
        $data = PDL->rcols($csv, [], { COLSEP => ',', DEFTYPE => PDL::double});
        $self->progress_bar_update($pbar) if $pbar;
    }
    return ($data, $symbol);
}

sub display_data {
    my ($self, $win, $data, $symbol, $iref, $output) = @_;
    return unless defined $win and defined $data;
    my @tabsize = $win->size();
    $symbol = $self->current->{symbol} unless defined $symbol;
    my @tabs = grep { $_->name =~ /data_tabs/ } $win->get_widgets();
    say "Tabs: @tabs" if $self->debug;
    unless (@tabs) {
        $win->insert('Prima::TabbedNotebook',
            name => 'data_tabs',
            size => \@tabsize,
            origin => [ 0, 0 ],
            style => tns::Simple,
            growMode => gm::Client,
            visible => 1,
            onChange => sub {
                my ($w, $oldidx, $newidx) = @_;
                my $owner = $w->owner;
                say "Tab changed from $oldidx to $newidx" if $self->debug;
                return if $oldidx == $newidx;
                # ok find the detailed-list object and use it
                my ($data, $symbol, $indicators) = $self->_get_tab_data($w, $newidx);
                my $type = $self->current->{plot_type} || 'OHLC';
                $self->plot_data($owner, $data, $symbol, $type, $indicators);
            },
        );
    }
    my $nt = $win->data_tabs;
    my $nt_tabs = $nt->tabs;
    # create unique tab-names
    if (scalar @$nt_tabs) {
        my %tabnames = map { $_ => 1 } @$nt_tabs;
        say "$symbol tab already exists" if exists $tabnames{$symbol} and $self->debug;
        say "$symbol tab will be added" if not exists $tabnames{$symbol} and $self->debug;
        $nt->tabs([@$nt_tabs, $symbol]) if not exists $tabnames{$symbol};
    } else {
        say "$symbol tab will be added" if $self->debug;
        $nt->tabs([$symbol]);
    }
    my $pc = $nt->pageCount;
    say "TabCount: $pc" if $self->debug;
    my $pageno = $pc;
    # find the existing tab with the same symbol info and remove the widget
    # there and get that page number
    # default headers
    my $headers = ['Date', 'Open', 'High', 'Low', 'Close', 'Volume'];
    my $existing_indicators = [];
    for my $idx (0 .. $pc) {
        my @wids = $nt->widgets_from_page($idx);
        next unless @wids;
        my @dls = grep { $_->name eq "tab_$symbol" } @wids;
        if (@dls) {
            foreach (@dls) {
                say "Found existing ", $_->name, " at $idx" if $self->debug;
                $headers = $_->headers if defined $_->headers;
                push @$existing_indicators, @{$_->{-indicators}} if exists $_->{-indicators};
                $nt->delete_widget($_);
            }
            $pageno = $idx;
            last;
        }
    }
    # handle the current indicator first
    if ($output and scalar @$output) {
        my @cols = ();
        foreach my $a (@$output) {
            # add the DetailedList column number
            push @cols, scalar(@$headers);
            # add the header
            push @$headers, $a->[0];
            # splice the indicator PDL into $data
            $data = $data->glue(1, $a->[1]) if ref $a->[1] eq 'PDL';
        }
        # add the current indicator to the bottom of the list
        push @$existing_indicators, {indicator => $iref, data => $output, columns => \@cols};
    }
    say "Data dimension: ", Dumper([$data->dims]) if $self->debug;
    say "Updated headers: ", Dumper($headers) if $self->debug;
    my $items = $data->transpose->unpdl;
    my $tz = $self->timezone;
    # reformat
    foreach my $arr (@$items) {
        my $dt = DateTime->from_epoch(epoch => $arr->[0], time_zone => $tz)->ymd('-');
        $arr->[0] = $dt;
        for (my $i = 1; $i < scalar @$arr; ++$i) {
            $arr->[$i] = '' if $arr->[$i] =~ /BAD/i;
        }
    }
    $tabsize[0] *= 0.98;
    $tabsize[1] *= 0.96;
    my $dl = $nt->insert_to_page($pageno, 'DetailedList',
        name => "tab_$symbol",
        pack => { expand => 1, fill => 'both' },
        items => $items,
        origin => [ 10, 10 ],
        headers => $headers,
        hScroll => 1,
        growMode => gm::Client | gm::GrowHiX | gm::GrowHiY,
        columns => scalar @$headers,
        onSort => sub {
            my ($p, $col, $dir) = @_;
            return if $col != 1;
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
        title => $symbol,
        titleSpace => 30,
        size => \@tabsize,
        visible => 1,
    );
    $nt->pageIndex($pageno);
    $dl->{-pdl} = $data;
    $dl->{-symbol} = $symbol;
    $dl->{-indicators} = $existing_indicators if defined $existing_indicators;
    1;
}

sub disable_menu_options {
    my $self = shift;
    my $win = $self->main;
    # disable the menu option now that we have nothing open
    $win->menu->security_close->enabled(0);
    $win->menu->plot_ohlc->enabled(0);
    $win->menu->plot_ohlcv->enabled(0);
    $win->menu->plot_close->enabled(0);
    $win->menu->plot_closev->enabled(0);
    $win->menu->plot_cdl->enabled(0);
    $win->menu->plot_cdlv->enabled(0);
    $win->menu->add_indicator->enabled(0);
    $win->menu->remove_indicator->enabled(0);
}

sub close_current_tab {
    my ($self, $win) = @_;
    return unless $win;
    my @tabs = grep { $_->name =~ /data_tabs/ } $win->get_widgets();
    return unless @tabs;
    my $nt = $win->data_tabs;
    my $idx = $nt->pageIndex;
    if ($nt->pageCount == 1) {
        $nt->close;
        if ($win->{plot}) {
            $win->{plot}->close();
        }
        $self->disable_menu_options;
    } else {
        my @wids = $nt->widgets_from_page($idx);
        # close child widgets explicitly
        map { $_->close } @wids if @wids;
        $nt->Notebook->delete_page($idx);
        my @ntabs = @{$nt->TabSet->tabs};
        say "Existing tabs: ", Dumper(\@ntabs) if $self->debug;
        splice(@ntabs, $idx, 1);
        say "New tabs: ", Dumper(\@ntabs) if $self->debug;
        $nt->TabSet->tabs(\@ntabs);
    }
}

sub _get_tab_data {
    my ($self, $nb, $idx) = @_;
    my @nt = $nb->widgets_from_page($idx);
    return unless @nt;
    my ($dl) = grep { $_->name =~ /^tab_/i } @nt;
    if ($dl) {
        say "Found ", $dl->name if $self->debug;
        return ($dl->{-pdl}, $dl->{-symbol}, $dl->{-indicators});
    }
}

sub get_tab_data {
    my ($self, $win) = @_;
    return unless $win;
    my @tabs = grep { $_->name =~ /data_tabs/ } $win->get_widgets();
    return unless @tabs;
    my $idx = $win->data_tabs->pageIndex;
    return $self->_get_tab_data($win->data_tabs, $idx);
}

sub get_tab_data_by_name($$) {
    my ($self, $win, $name) = @_;
    return unless $win;
    my @tabs = grep { $_->name =~ /data_tabs/ } $win->get_widgets();
    return unless @tabs;
    my $pc = $win->data_tabs->pageCount - 1;
    return unless $pc >= 0;
    say "Looking for $name" if $self->debug;
    for my $idx (0 .. $pc) {
        my @nt = $win->data_tabs->widgets_from_page($idx);
        next unless @nt;
        my ($dl) = grep { $_->name =~ /^tab_/i } @nt;
        if ($dl and $dl->{-symbol} eq $name) {
            say "Found $name on page $idx" if $self->debug;
            return ($dl->{-pdl},
                    $dl->{-symbol},
                    $dl->{-indicators},
                    [$dl->headers]);
        }
    }
    return undef;
}

sub set_tab_data_by_name($$) {
    my ($self, $win, $name, $p, $s, $ind, $hdr) = @_;
    return unless $win;
    return unless $name;
    my @tabs = grep { $_->name =~ /data_tabs/ } $win->get_widgets();
    return unless @tabs;
    my $pc = $win->data_tabs->pageCount - 1;
    return unless $pc >= 0;
    my $found;
    for my $idx (0 .. $pc) {
        my @nt = $win->data_tabs->widgets_from_page($idx);
        next unless @nt;
        my ($dl) = grep { $_->name =~ /^tab_/i } @nt;
        if ($dl and $dl->{-symbol} eq $name) {
            say "Found $name on page $idx" if $self->debug;
            $dl->{-pdl} = $p;
            $dl->{-indicators}= $ind;
            $dl->headers($hdr);
            return 1;
        }
    }
}

sub get_tab_names($) {
    my ($self, $win) = @_;
    return unless $win;
    my @tabs = grep { $_->name =~ /data_tabs/ } $win->get_widgets();
    return unless @tabs;
    my $pc = $win->data_tabs->pageCount - 1;
    return unless $pc >= 0;
    my %names = ();
    for my $idx (0 .. $pc) {
        my @nt = $win->data_tabs->widgets_from_page($idx);
        next unless @nt;
        my ($dl) = grep { $_->name =~ /^tab_/i } @nt;
        $names{$dl->{-symbol}} = $dl->name if ($dl);
    }
    return wantarray ? %names : \%names;
}

sub get_tab_indicators {
    my ($self, $win, $txt) = @_;
    my ($data, $sym, $indicators, $headers) = $self->get_tab_data_by_name($win, $txt);
    return $indicators;
}

sub plot_data {
    my $self = shift;
    if (lc($self->plot_engine) eq 'gnuplot') {
        say "Using Gnuplot to do plotting" if $self->debug;
        return $self->plot_data_gnuplot(@_);
    }
    carp $self->plot_engine . " is not supported yet.";
}

sub plot_data_gnuplot {
    my ($self, $win, $data, $symbol, $type, $indicators) = @_;
    return unless defined $data;
    # use the x11 term by default first
    my $term = 'x11';
    # if the wxt term is there use that instead since it is just better
    # if the aqua term is there use that if wxt isn't there
    if ($^O =~ /Darwin/i) {
        Capture::Tiny::capture {
            my @terms = PDL::Graphics::Gnuplot::terminfo();
            $term = 'aqua' if grep {/aqua/} @terms;
            $term = 'wxt' if grep {/wxt/} @terms;
        };
    } elsif ($^O =~ /Win32|Cygwin/i) {
        Capture::Tiny::capture {
            my @terms = PDL::Graphics::Gnuplot::terminfo();
            $term = 'wxt' if (grep {/wxt/} @terms) > 0;
            $term = 'windows' if (grep {/windows/} @terms) > 0;
            # on Cygwin it may be x11
        };
    }
    say "Using term $term" if $self->debug;
    my $pwin = $win->{plot} || gpwin($term, size => [1024, 768, 'px']);
    $win->{plot} = $pwin;
    $symbol = $self->current->{symbol} unless defined $symbol;
    $type = $self->current->{plot_type} unless defined $type;
    my @general_plot = ();
    my @volume_plot = ();
    my @addon_plot = ();
    $self->indicator->color_idx(0); # reset color index
    if (defined $indicators and scalar @$indicators) {
        # ok now create a list of indicators to plot
        foreach (@$indicators) {
            my $iref = $_->{indicator};
            my $idata = $_->{data};
            my $iplot = $self->indicator->get_plot_args($data(,(0)), $idata, $iref);
            next unless $iplot;
            if (ref $iplot eq 'ARRAY') {
                push @general_plot, @$iplot if scalar @$iplot;
            } elsif (ref $iplot eq 'HASH') {
                my $iplot_gen = $iplot->{general};
                push @general_plot, @$iplot_gen if $iplot_gen and scalar @$iplot_gen;
                my $iplot_vol = $iplot->{volume};
                push @volume_plot, @$iplot_vol if $iplot_vol and scalar @$iplot_vol;
                my $iplot_addon = $iplot->{additional};
                push @addon_plot, @$iplot_addon if $iplot_addon and scalar @$iplot_addon;
            } else {
                carp 'Unable to handle plot arguments in ' . ref($iplot) . ' form!';
            }
        }
    }
    $pwin->reset();
    # use multiplot
    $pwin->multiplot();
    if ($type eq 'OHLC') {
        my %addon_gen = ();
        if (@addon_plot) {
            $addon_gen{size} = ["1, 0.7"];
            $addon_gen{origin} = [0, 0.3];
            $addon_gen{bmargin} = 0;
            $addon_gen{lmargin} = 9;
            $addon_gen{rmargin} = 2;
        }
        $pwin->plot({
                object => '1 rectangle from screen 0,0 to screen 1,1 fillcolor rgb "black" behind',
                title => ["$symbol Open-High-Low-Close", textcolor => 'rgb "white"'],
                key => ['on', 'outside', textcolor => 'rgb "yellow"'],
                border => 'linecolor rgbcolor "white"',
                xlabel => ['Date', textcolor => 'rgb "yellow"'],
                ylabel => ['Price', textcolor => 'rgb "yellow"'],
                xdata => 'time',
                xtics => {format => '%Y-%m-%d', rotate => -90, textcolor => 'orange', },
                ytics => {textcolor => 'orange'},
                label => [1, $self->brand, textcolor => 'rgb "cyan"', at => "graph 0.90,0.03"],
                %addon_gen,
            },
            {
                with => 'financebars',
                linecolor => 'white',
                legend => 'Price',
            },
            $data(,(0)), $data(,(1)), $data(,(2)), $data(,(3)), $data(,(4)),
            @general_plot,
        );
        if (@addon_plot) {
            $pwin->plot({
                    object => '1',
                    title => '',
                    key => ['on', 'outside', textcolor => 'rgb "yellow"'],
                    border => 'linecolor rgbcolor "white"',
                    ylabel => '',
                    xlabel => '',
                    xtics => '',
                    ytics => {textcolor => 'orange'},
                    bmargin => 0,
                    tmargin => 0,
                    lmargin => 9,
                    rmargin => 2,
                    size => ["1,0.3"], #bug in P:G:G
                    origin => [0, 0],
                    label => [1, "", at => "graph 0.90,0.03"],
                },
                @addon_plot,
            );
        }
    } elsif ($type eq 'OHLCV') {
        my %addon_gen = ();
        my %addon_vol = ();
        if (@addon_plot) {
            $addon_gen{size} = ["1, 0.6"]; #bug in P:G:G
            $addon_gen{origin} = [0, 0.4];
            $addon_vol{size} = ["1, 0.2"]; #bug in P:G:G
            $addon_vol{origin} = [0, 0];
        } else {
            $addon_gen{size} = ["1, 0.7"]; #bug in P:G:G
            $addon_gen{origin} = [0, 0.3];
            $addon_vol{size} = ["1, 0.3"]; #bug in P:G:G
            $addon_vol{origin} = [0, 0];
            $addon_vol{object} = '1'; # needed as otherwise the addon plot does it
        }
        $pwin->plot({
                object => '1 rectangle from screen 0,0 to screen 1,1 fillcolor rgb "black" behind',
                xlabel => ['Date', textcolor => 'rgb "yellow"'],
                ylabel => ['Price', textcolor => 'rgb "yellow"'],
                title => ["$symbol Price & Volume", textcolor => "rgb 'white'"],
                key => ['on', 'outside', textcolor => 'rgb "yellow"'],
                border => 'linecolor rgbcolor "white"',
                xdata => 'time',
                xtics => {format => '%Y-%m-%d', rotate => -90, textcolor => 'orange', },
                ytics => {textcolor => 'orange'},
                bmargin => 0,
                lmargin => 9,
                rmargin => 2,
                %addon_gen,
                label => [1, $self->brand, textcolor => 'rgb "cyan"', at => "graph 0.90,0.03"],
            },
            {
                with => 'financebars',
                linecolor => 'white',
                legend => 'Price',
            },
            $data(,(0)), $data(,(1)), $data(,(2)), $data(,(3)), $data(,(4)),
            @general_plot,
        );
        if (@addon_plot) {
            $pwin->plot({
                    object => '1',
                    title => '',
                    key => ['on', 'outside', textcolor => 'rgb "yellow"'],
                    border => 'linecolor rgbcolor "white"',
                    ylabel => '',
                    xlabel => '',
                    xtics => '',
                    ytics => {textcolor => 'orange'},
                    bmargin => 0,
                    tmargin => 0,
                    lmargin => 9,
                    rmargin => 2,
                    size => ["1,0.2"], #bug in P:G:G
                    origin => [0, 0.2],
                    label => [1, "", at => "graph 0.90,0.03"],
                },
                @addon_plot,
            );
        }
        $pwin->plot({
                title => '',
                key => ['on', 'outside', textcolor => 'rgb "yellow"'],
                border => 'linecolor rgbcolor "white"',
                ylabel => ['Volume (in 1M)', textcolor => 'rgb "yellow"'],
                xlabel => '',
                xtics => '',
                ytics => {textcolor => 'orange'},
                bmargin => 0,
                tmargin => 0,
                lmargin => 9,
                rmargin => 2,
                %addon_vol,
                label => [1, "", at => "graph 0.90,0.03"],
            },
            {
                with => 'impulses',
                legend => 'Volume',
                linecolor => 'cyan',
            },
            $data(,(0)), $data(,(5)) / 1e6,
            @volume_plot,
        );
    } elsif ($type eq 'CANDLE') {
        my %addon_gen = ();
        if (@addon_plot) {
            $addon_gen{size} = ["1, 0.7"];
            $addon_gen{origin} = [0, 0.3];
            $addon_gen{bmargin} = 0;
            $addon_gen{lmargin} = 9;
            $addon_gen{rmargin} = 2;
        }
        # use candlesticks feature of Gnuplot
        $pwin->plot({
                object => '1 rectangle from screen 0,0 to screen 1,1 fillcolor rgb "black" behind',
                title => ["$symbol Open-High-Low-Close", textcolor => 'rgb "white"'],
                key => ['on', 'outside', textcolor => 'rgb "yellow"'],
                border => 'linecolor rgbcolor "white"',
                xlabel => ['Date', textcolor => 'rgb "yellow"'],
                ylabel => ['Price', textcolor => 'rgb "yellow"'],
                ytics => {textcolor => 'orange'},
                xdata => 'time',
                xtics => {format => '%Y-%m-%d', rotate => -90, textcolor => 'orange', },
                label => [1, $self->brand, textcolor => 'rgb "cyan"', at => "graph 0.90,0.03"],
                %addon_gen,
            },
            {
                with => 'candlesticks',
                linecolor => 'white',
                legend => 'Price',
            },
            $data(,(0)), $data(,(1)), $data(,(2)), $data(,(3)), $data(,(4)),
            @general_plot,
        );
        if (@addon_plot) {
            $pwin->plot({
                    object => '1',
                    title => '',
                    key => ['on', 'outside', textcolor => 'rgb "yellow"'],
                    border => 'linecolor rgbcolor "white"',
                    ylabel => '',
                    xlabel => '',
                    xtics => '',
                    ytics => {textcolor => 'orange'},
                    bmargin => 0,
                    tmargin => 0,
                    lmargin => 9,
                    rmargin => 2,
                    size => ["1,0.3"], #bug in P:G:G
                    origin => [0, 0],
                    label => [1, "", at => "graph 0.90,0.03"],
                },
                @addon_plot,
            );
        }
    } elsif ($type eq 'CANDLEV') {
        my %addon_gen = ();
        my %addon_vol = ();
        if (@addon_plot) {
            $addon_gen{size} = ["1, 0.6"]; #bug in P:G:G
            $addon_gen{origin} = [0, 0.4];
            $addon_vol{size} = ["1, 0.2"]; #bug in P:G:G
            $addon_vol{origin} = [0, 0];
        } else {
            $addon_gen{size} = ["1, 0.7"]; #bug in P:G:G
            $addon_gen{origin} = [0, 0.3];
            $addon_vol{size} = ["1, 0.3"]; #bug in P:G:G
            $addon_vol{origin} = [0, 0];
            $addon_vol{object} = '1'; # needed as otherwise the addon plot does it
        }
        $pwin->plot({
                object => '1 rectangle from screen 0,0 to screen 1,1 fillcolor rgb "black" behind',
                title => ["$symbol Price & Volume", textcolor => "rgb 'white'"],
                key => ['on', 'outside', textcolor => 'rgb "yellow"'],
                border => 'linecolor rgbcolor "white"',
                xlabel => ['Date', textcolor => 'rgb "yellow"'],
                ylabel => ['Price', textcolor => 'rgb "yellow"'],
                xdata => 'time',
                ytics => {textcolor => 'orange'},
                xtics => {format => '%Y-%m-%d', rotate => -90, textcolor => 'orange', },
                tmargin => '',
                bmargin => 0,
                lmargin => 9,
                rmargin => 2,
                %addon_gen,
                label => [1, $self->brand, textcolor => 'rgb "cyan"', at => "graph 0.90,0.03"],
            },
            {
                with => 'candlesticks',
                linecolor => 'white',
                legend => 'Price',
            },
            $data(,(0)), $data(,(1)), $data(,(2)), $data(,(3)), $data(,(4)),
            @general_plot,
        );
        if (@addon_plot) {
            $pwin->plot({
                    object => '1',
                    title => '',
                    key => ['on', 'outside', textcolor => 'rgb "yellow"'],
                    border => 'linecolor rgbcolor "white"',
                    ylabel => '',
                    xlabel => '',
                    xtics => '',
                    ytics => {textcolor => 'orange'},
                    bmargin => 0,
                    tmargin => 0,
                    lmargin => 9,
                    rmargin => 2,
                    size => ["1,0.2"], #bug in P:G:G
                    origin => [0, 0.2],
                    label => [1, "", at => "graph 0.90,0.03"],
                },
                @addon_plot,
            );
        }
        $pwin->plot({
                title => '',
                ylabel => ['Volume (in 1M)', textcolor => 'rgb "yellow"'],
                key => ['on', 'outside', textcolor => 'rgb "yellow"'],
                border => 'linecolor rgbcolor "white"',
                xtics => '',
                xlabel => '',
                ytics => {textcolor => 'orange'},
                bmargin => 0,
                tmargin => 0,
                lmargin => 9,
                rmargin => 2,
                %addon_vol,
                label => [1, "", at => "graph 0.90,0.03"],
            },
            {
                with => 'impulses',
                legend => 'Volume',
                linecolor => 'cyan',
            },
            $data(,(0)), $data(,(5)) / 1e6,
            @volume_plot,
        );
    } elsif ($type eq 'CLOSEV') {
        my %addon_gen = ();
        my %addon_vol = ();
        if (@addon_plot) {
            $addon_gen{size} = ["1, 0.6"]; #bug in P:G:G
            $addon_gen{origin} = [0, 0.4];
            $addon_vol{size} = ["1, 0.2"]; #bug in P:G:G
            $addon_vol{origin} = [0, 0];
        } else {
            $addon_gen{size} = ["1, 0.7"]; #bug in P:G:G
            $addon_gen{origin} = [0, 0.3];
            $addon_vol{size} = ["1, 0.3"]; #bug in P:G:G
            $addon_vol{origin} = [0, 0];
            $addon_vol{object} = '1'; # needed as otherwise the addon plot does it
        }
        $pwin->plot({
                object => '1 rectangle from screen 0,0 to screen 1,1 fillcolor rgb "black" behind',
                title => ["$symbol Price & Volume", textcolor => "rgb 'white'"],
                key => ['on', 'outside', textcolor => 'rgb "yellow"'],
                border => 'linecolor rgbcolor "white"',
                ylabel => ['Close Price', textcolor => 'rgb "yellow"'],
                xlabel => ['Date', textcolor => 'rgb "yellow"'],
                xdata => 'time',
                xtics => {format => '%Y-%m-%d', rotate => -90, textcolor => 'orange', },
                ytics => {textcolor => 'orange'},
                bmargin => 0,
                lmargin => 9,
                rmargin => 2,
                %addon_gen,
                label => [1, $self->brand, textcolor => 'rgb "cyan"', at => "graph 0.90,0.03"],
            },
            {
                with => 'lines',
                linecolor => 'white',
                legend => 'Close Price',
            },
            $data(,(0)), $data(,(4)),
            @general_plot,
        );
        if (@addon_plot) {
            $pwin->plot({
                    object => '1',
                    title => '',
                    key => ['on', 'outside', textcolor => 'rgb "yellow"'],
                    border => 'linecolor rgbcolor "white"',
                    ylabel => '',
                    xlabel => '',
                    xtics => '',
                    ytics => {textcolor => 'orange'},
                    bmargin => 0,
                    tmargin => 0,
                    lmargin => 9,
                    rmargin => 2,
                    size => ["1,0.2"], #bug in P:G:G
                    origin => [0, 0.2],
                    label => [1, "", at => "graph 0.90,0.03"],
                },
                @addon_plot,
            );
        }
        $pwin->plot({
                title => '',
                key => ['on', 'outside', textcolor => 'rgb "yellow"'],
                border => 'linecolor rgbcolor "white"',
                ylabel => ['Volume (in 1M)', textcolor => 'rgb "yellow"'],
                xlabel => '',
                xtics => '',
                ytics => {textcolor => 'orange'},
                bmargin => 0,
                tmargin => 0,
                lmargin => 9,
                rmargin => 2,
                %addon_vol,
                label => [1, "", at => "graph 0.90,0.03"],
            },
            {
                with => 'impulses',
                legend => 'Volume',
                linecolor => 'cyan',
            },
            $data(,(0)), $data(,(5)) / 1e6,
            @volume_plot,
        );
    } else {
        $type = 'CLOSE';
        my %addon_gen = ();
        if (@addon_plot) {
            $addon_gen{size} = ["1, 0.7"];
            $addon_gen{origin} = [0, 0.3];
            $addon_gen{bmargin} = 0;
            $addon_gen{lmargin} = 9;
            $addon_gen{rmargin} = 2;
        }
        $pwin->plot({
                object => '1 rectangle from screen 0,0 to screen 1,1 fillcolor rgb "black" behind',
                title => ["$symbol Close Price", textcolor => 'rgb "white"'],
                key => ['on', 'outside', textcolor => 'rgb "yellow"'],
                border => 'linecolor rgbcolor "white"',
                xlabel => ['Date', textcolor => 'rgb "yellow"'],
                ylabel => ['Close Price', textcolor => 'rgb "yellow"'],
                xdata => 'time',
                xtics => {format => '%Y-%m-%d', rotate => -90, textcolor => 'orange', },
                ytics => {textcolor => 'orange'},
                label => [1, $self->brand, textcolor => 'rgb "cyan"', at => "graph 0.90,0.03"],
                %addon_gen,
            },
            {
                with => 'lines',
                linecolor => 'white',
                legend => 'Close Price',
            },
            $data(,(0)), $data(,(4)),
            @general_plot,
        );
        if (@addon_plot) {
            $pwin->plot({
                    object => '1',
                    title => '',
                    key => ['on', 'outside', textcolor => 'rgb "yellow"'],
                    border => 'linecolor rgbcolor "white"',
                    ylabel => '',
                    xlabel => '',
                    xtics => '',
                    ytics => {textcolor => 'orange'},
                    bmargin => 0,
                    tmargin => 0,
                    lmargin => 9,
                    rmargin => 2,
                    size => ["1,0.3"], #bug in P:G:G
                    origin => [0, 0],
                    label => [1, "", at => "graph 0.90,0.03"],
                },
                @addon_plot,
            );
        }
    }
    $pwin->end_multi;
    # make the current plot type the type
    $self->current->{plot_type} = $type if defined $type;
}

1;
__END__
### COPYRIGHT: 2014 Vikas N. Kumar. All Rights Reserved.
### AUTHOR: Vikas N Kumar <vikas@cpan.org>
### DATE: 3rd Jan 2014
### LICENSE: Refer LICENSE file
