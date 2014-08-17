package PDL::Finance::TA;
use strict;
use warnings;
use 5.10.0;
use feature 'say';

our $VERSION = '0.03';
$VERSION = eval $VERSION;

use PDL::Finance::TA::Mo;
use Carp;
use File::Spec;
use DateTime;
use POE 'Loop::Prima';
use Prima qw(
    Application Buttons MsgBox Calendar ComboBox Notebooks
    ScrollWidget DetailedList HelpViewer
);
use Prima::Utils ();
use Data::Dumper;
use Capture::Tiny ();
use Finance::QuoteHist;
use PDL::Lite;
use PDL::IO::Misc;
use PDL::NiceSlice;
use PDL::Graphics::Gnuplot;
use PDL::Finance::TA::Indicators;

$PDL::doubleformat = "%0.6lf";
$| = 1;
has debug => 0;
has timezone => 'America/New_York';
has brand => (default => sub { __PACKAGE__ });
has main => (builder => '_build_main');
has icon => (builder => '_build_icon');
has use_pgplot => 0;

sub _build_icon {
    my $self = shift;
    my $pkg = __PACKAGE__ . '.pm';
    $pkg =~ s|::|/|g;
    my $pkgpath = File::Spec->canonpath(File::Spec->rel2abs($INC{$pkg}));
    $pkgpath =~ s|\.pm$||g;
    my $icon_path = File::Spec->catfile($pkgpath, 'images', 'icon.gif');
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
                    'security_wizard',
                    '~New', 'Ctrl+N', '^N',
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
                                $gui->plot_data($win, $data, $symbol, 'OHLC');
                            }
                            $win->menu->plot_ohlc->enabled(1);
                            $win->menu->plot_ohlcv->enabled(1);
                            $win->menu->plot_close->enabled(1);
                            $win->menu->plot_closev->enabled(1);
                            $win->menu->add_indicator->enabled(1);
                            $gui->progress_bar_close($bar);
                        }
                    },
                    $self,
                ],
                [
                    'app_exit',
                    'E~xit', 'Alt+X', '@X',
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
                    'plot_ohlc',
                    '~OHLC', 'Ctrl+O', '^P',
                    sub {
                        my ($win, $item) = @_;
                        my $gui = $win->menu->data($item);
                        my ($data, $symbol) = $gui->get_tab_data($win);
                        $gui->plot_data($win, $data, $symbol, 'OHLC');
                    },
                    $self,
                ],
                [
                    'plot_ohlcv',
                    'OHLC Volume', '', '',
                    sub {
                        my ($win, $item) = @_;
                        my $gui = $win->menu->data($item);
                        my ($data, $symbol) = $gui->get_tab_data($win);
                        $gui->plot_data($win, $data, $symbol, 'OHLCV');
                    },
                    $self,
                ],
                [
                    'plot_close',
                    'Close Price', '', '',
                    sub {
                        my ($win, $item) = @_;
                        my $gui = $win->menu->data($item);
                        my ($data, $symbol) = $gui->get_tab_data($win);
                        $gui->plot_data($win, $data, $symbol, 'CLOSE');
                    },
                    $self,
                ],
                [
                    'plot_closev',
                    'Close Price Volume', '', '',
                    sub {
                        my ($win, $item) = @_;
                        my $gui = $win->menu->data($item);
                        my ($data, $symbol) = $gui->get_tab_data($win);
                        $gui->plot_data($win, $data, $symbol, 'CLOSEV');
                    },
                    $self,
                ],
            ],
        ],
        [
            '~Analysis' => [
                [
                    'add_indicator',
                    'Add Indicator', 'Ctrl+I', '^I',
                    sub {
                        my ($win, $item) = @_;
                        my $gui = $win->menu->data($item);
                        my ($data, $symbol) = $gui->get_tab_data($win);
                        # ok add an indicator which also plots it
                        $gui->add_indicator($win, $data, $symbol);
                    },
                    $self,
                ],
            ],
        ],
        [
            '~Help' => [
                [
                    'help_viewer',
                    'Help Viewer', '', kb::NoKey,
                    sub {
                        my ($win, $item) = @_;
                        my $gui = $win->menu->data($item);
                        $::application->open_help(__PACKAGE__);
                    },
                    $self,
                ],
                [
                    'about_logo',
                    'About Logo', '', kb::NoKey,
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
    # disable the appropriate menu options
    $self->main->menu->plot_ohlc->enabled(0);
    $self->main->menu->plot_ohlcv->enabled(0);
    $self->main->menu->plot_close->enabled(0);
    $self->main->menu->plot_closev->enabled(0);
    $self->main->menu->add_indicator->enabled(0);
    run Prima;
}

has current => {};

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
    );
    $w->insert(
        InputLine => name => 'input_symbol',
        alignment => ta::Left,
        autoHeight => 1,
        width => 60,
        autoTab => 1,
        maxLen => 10,
        origin => [ 180, 440],
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
        default => 1,
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
        default => 0,
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

sub add_indicator {
    my ($self, $win, $data, $symbol) = @_;
    if ($self->indicator_wizard($win)) {
    }
}

has indicator => (default => sub { PDL::Finance::TA::Indicators->new });

sub indicator_wizard {
    my ($self, $win) = @_;
    my $w = Prima::Dialog->new(
        name => 'ind_wizard',
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
    my @groups = $self->indicator->get_groups;
    $w->insert(Label => name => 'label_groups',
        text => 'Select Group',
        font => { style => fs::Bold, height => 16 },
        alignment => ta::Left,
        autoHeight => 1,
        autoWidth => 1,
        origin => [20, 440],
    );
    $w->insert(ComboBox =>
        name => 'cbox_groups',
        style => cs::DropDownList,
        height => 30,
        width => 180,
        hScroll => 0,
        multiSelect => 0,
        multiColumn => 0,
        dragable => 0,
        focusedItem => -1,
        font => { height => 16 },
        items => ['', @groups],
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
                }
                $owner->btn_ok->enabled(1);
            } else {
                $owner->btn_ok->enabled(0);
            }
        },
    );
    $w->insert(Label => name => 'label_funcs',
        text => 'Select Function',
        font => { style => fs::Bold, height => 16 },
        alignment => ta::Left,
        autoHeight => 1,
        autoWidth => 1,
        origin => [20, 400],
    );
    $w->insert(ComboBox =>
        name => 'cbox_funcs',
        style => cs::DropDownList,
        height => 30,
        width => 180,
        hScroll => 0,
        font => { height => 16 },
        multiSelect => 0,
        multiColumn => 0,
        dragable => 0,
        focusedItem => -1,
        items => [],
        origin => [180, 400],
        onChange => sub {
            my $cbox = shift;
            my $owner = $cbox->owner;
            my $lbox = $cbox->List;
            my $index = $lbox->focusedItem;
            my $txt = $lbox->get_item_text($index);
            my @params = $self->indicator->get_params($txt);
            $owner->btn_ok->enabled(1);
        },
    );
    $w->insert(
        Button => name => 'btn_cancel',
        text => 'Cancel',
        autoHeight => 1,
        autoWidth => 1,
        origin => [ 20, 40 ],
        modalResult => mb::Cancel,
        default => 1,
        enabled => 1,
        font => { height => 16, style => fs::Bold },
        onClick => sub {
        },
    );
    $w->insert(
        Button => name => 'btn_ok',
        text => 'OK',
        autoHeight => 1,
        autoWidth => 1,
        origin => [ 150, 40 ],
        modalResult => mb::Ok,
        default => 0,
        enabled => 0,
        font => { height => 16, style => fs::Bold },
        onClick => sub {
            my $btn = shift;
            my $owner = $btn->owner;
        },
    );

    #TODO:
    my $res = $w->execute();
    $w->end_modal;
    return $res == mb::Ok;
}

has tmpdir => ( default => sub {
    return $ENV{TEMP} || $ENV{TMP} if $^O =~ /Win32|Cygwin/i;
    return $ENV{TMPDIR} || '/tmp';
});

sub download_data {
    my ($self, $pbar) = @_;
#    say Dumper($self->current);
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
        say "$csv has downloaded data for analysis" if $self->debug;
        unless (scalar @quotes) {
            message("Failed to download $symbol data", mb::Ok);
            unlink $csv;
            return;
        }
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
    my ($self, $win, $data) = @_;
    return unless defined $win and defined $data;
    my @tabsize = $win->size();
    my $symbol = $self->current->{symbol};
    my @tabs = grep { $_->name =~ /data_tabs/ } $win->get_widgets();
    say "Tabs: @tabs" if $self->debug;
    unless (@tabs) {
        $win->insert('Prima::TabbedNotebook',
            name => 'data_tabs',
            size => \@tabsize,
            origin => [ 0, 0 ],
            style => tns::Simple,
            growMode => gm::Client,
            onChange => sub {
                my ($w, $oldidx, $newidx) = @_;
                my $owner = $w->owner;
                say "Tab changed from $oldidx to $newidx" if $self->debug;
                return if $oldidx == $newidx;
                # ok find the detailed-list object and use it
                my ($data, $symbol) = $self->_get_tab_data($w, $newidx);
                $self->plot_data($owner, $data, $symbol);
            },
        );
    }
    my $nt = $win->data_tabs;
    my $nt_tabs = $nt->tabs;
    $nt->tabs([@$nt_tabs, $symbol]);
    $tabsize[0] *= 0.98;
    $tabsize[1] *= 0.96;
    my $pc = $nt->pageCount;
    say "TabCount: $pc" if $self->debug;
    my $items = $data->transpose->unpdl;
    my $tz = $self->timezone;
    # reformat
    foreach my $arr (@$items) {
        my $dt = DateTime->from_epoch(epoch => $arr->[0], time_zone => $tz)->ymd('-');
        $arr->[0] = $dt;
    }
    my $dl = $nt->insert_to_page($pc, 'DetailedList',
        name => "tab_$symbol",
        pack => { expand => 1, fill => 'both' },
        items => $items,
        origin => [ 10, 10 ],
        headers => ['Date', 'Open', 'High', 'Low', 'Close', 'Volume'],
        columns => 6,
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
    );
    $nt->pageIndex($pc);
    $dl->{-pdl} = $data;
    $dl->{-symbol} = $symbol;
}

sub _get_tab_data {
    my ($self, $nb, $idx) = @_;
    my @nt = $nb->widgets_from_page($idx);
    my ($dl) = grep { $_->name =~ /^tab_/i } @nt;
    say "Found ", $dl->name if $self->debug;
    return ($dl->{-pdl}, $dl->{-symbol});
}

sub get_tab_data {
    my ($self, $win) = @_;
    return unless $win;
    my @tabs = grep { $_->name =~ /data_tabs/ } $win->get_widgets();
    return unless @tabs;
    my $idx = $win->data_tabs->pageIndex;
    $self->_get_tab_data($win->data_tabs, $idx);
}

sub plot_data {
    my $self = shift;
    if ($self->use_pgplot) {
        say "Using PGPLOT to do plotting" if $self->debug;
        eval 'require PDL::Graphics::PGPLOT::Window' or
            croak 'You asked for PGPLOT but PDL::Graphics::PGPLOT is not installed';
        return $self->plot_data_pgplot(@_);
    } else {
        say "Using Gnuplot to do plotting" if $self->debug;
        return $self->plot_data_gnuplot(@_);
    }
}

sub plot_data_pgplot {
    my ($self, $win, $data, $sym, $type) = @_;
    return unless defined $data;
    my $pwin = PDL::Graphics::PGPLOT::Window->new(
            Device => '/xw',
        );
    $win->{plot} = $pwin;
    $pwin->line($data(0:-1,(0)), $data(0:-1,(4)),
        { COLOR => 'CYAN', AXIS => [ 'BCNSTZ', 'BCNST' ]});
    $pwin->release;
    $pwin->focus;
}

sub plot_data_gnuplot {
    my ($self, $win, $data, $symbol, $type) = @_;
    return unless defined $data;
    # use the x11 term by default first
    my $term = 'x11';
    # if the wxt term is there use that instead since it is just better
    # if the aqua term is there use that if wxt isn't there
    Capture::Tiny::capture {
        my @terms = PDL::Graphics::Gnuplot::terminfo();
        $term = 'aqua' if grep {/aqua/} @terms;
        $term = 'wxt' if grep {/wxt/} @terms;
    };
    say "Using term $term" if $self->debug;
    my $pwin = $win->{plot} || gpwin($term, size => [1024, 768, 'px']);
    $win->{plot} = $pwin;
    $symbol = $self->current->{symbol} unless defined $symbol;
    $type = $self->current->{plot_type} unless defined $type;
    given ($type) {
        when ('OHLC') {
            $pwin->reset();
            $pwin->plot({
                    title => "$symbol Open-High-Low-Close",
                    xlabel => 'Date',
                    ylabel => 'Price',
                    xdata => 'time',
                    xtics => {format => '%Y-%m-%d', rotate => -90, },
                },
                {
                    with => 'financebars',
                    linecolor => 'red',
                    legend => 'Price',
                },
                $data(,(0)), $data(,(1)), $data(,(2)), $data(,(3)), $data(,(4)),
            );
        }
        when ('OHLCV') {
            # use multiplot
            $pwin->reset();
            $pwin->multiplot(title => "$symbol Price & Volume");
            $pwin->plot({
                    xlabel => '',
                    ylabel => 'Price',
                    xdata => 'time',
                    xtics => {format => '%Y-%m-%d', rotate => -90, },
                    bmargin => 0,
                    lmargin => 9,
                    rmargin => 2,
                    size => ["1,0.7"], #bug in P:G:G
                    origin => [0, 0.3],
                },
                {
                    with => 'financebars',
                    linecolor => 'red',
                    legend => 'Price',
                },
                $data(,(0)), $data(,(1)), $data(,(2)), $data(,(3)), $data(,(4)),
            );
            $pwin->plot({
                    ylabel => 'Volume (in 1M)',
                    xlabel => 'Date',
                    tmargin => 0,
                    lmargin => 9,
                    rmargin => 2,
                    size => ["1,0.3"], #bug in P:G:G
                    origin => [0, 0],
                },
                {with => 'impulses', legend => 'Volume', linecolor => 'blue'},
                $data(,(0)), $data(,(5)) / 1e6,
            );
            $pwin->end_multi;
        }
        when ('CLOSEV') {
            # use multiplot
            $pwin->reset();
            $pwin->multiplot(title => "$symbol Close Price & Volume");
            $pwin->plot({
                    xlabel => '',
                    ylabel => 'Close Price',
                    xdata => 'time',
                    xtics => {format => '%Y-%m-%d', rotate => -90, },
                    bmargin => 0,
                    lmargin => 9,
                    rmargin => 2,
                    size => ["1,0.7"], #bug in P:G:G
                    origin => [0, 0.3],
                },
                {
                    with => 'lines',
                    linecolor => 'blue',
                    legend => 'Close Price',
                },
                $data(,(0)), $data(,(4)),
            );
            $pwin->plot({
                    ylabel => 'Volume (in 1M)',
                    xlabel => 'Date',
                    tmargin => 0,
                    lmargin => 9,
                    rmargin => 2,
                    size => ["1,0.3"], #bug in P:G:G
                    origin => [0, 0],
                },
                {with => 'impulses', legend => 'Volume', linecolor => 'green'},
                $data(,(0)), $data(,(5)) / 1e6,
            );
            $pwin->end_multi;
        }
        default {
            $type = 'CLOSE';
            $pwin->reset();
            $pwin->plot({
                    title => "$symbol Close Price",
                    xlabel => 'Date',
                    ylabel => 'Close Price',
                    xdata => 'time',
                    xtics => {format => '%Y-%m-%d', rotate => -90, },
                },
                {
                    with => 'lines',
                    linecolor => 'blue',
                    legend => 'Close Price',
                },
                $data(,(0)), $data(,(4))
            );
        }
    }
    # make the current plot type the type
    $self->current->{plot_type} = $type if defined $type;
}

1;
__END__
### COPYRIGHT: 2014 Vikas N. Kumar. All Rights Reserved.
### AUTHOR: Vikas N Kumar <vikas@cpan.org>
### DATE: 3rd Jan 2014
### LICENSE: Refer LICENSE file
