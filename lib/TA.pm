package PDL::Finance::TA;
use strict;
use warnings;
use 5.10.0;
use feature 'say';

our $VERSION = '0.02';
$VERSION = eval $VERSION;

use PDL::Finance::TA::Mo;
use Carp;
use File::Spec;
use DateTime;
use POE 'Loop::Prima';
use Prima qw(
    Application Buttons MsgBox Calendar ComboBox Notebooks
    ScrollWidget DetailedList
);
use Prima::Utils ();
use Data::Dumper;
use Finance::QuoteHist;
use PDL::Lite;
use PDL::IO::Misc;
use PDL::NiceSlice;
use PDL::Graphics::Gnuplot;
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
                            # download security data
                            my $data = $gui->download_data();
                            $gui->display_data($win, $data);
                            $gui->plot_data($win, $data);
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
            '~Analysis' => [
                [
                    'ohlc_plot',
                    '~OHLC Plot', 'Ctrl+O', '^P',
                    sub {
                        my ($win, $item) = @_;
                        my $gui = $win->menu->data($item);
                        my $data = $gui->get_tab_data($win);
                        $gui->plot_data($win, $data);
                    },
                    $self,
                ],
            ],
        ],
        [
            '~Help' => [
                ['About Logo', '', kb::NoKey, sub {
                    message_box('About Logo', 'http://www.perl.com',
                                mb::Ok | mb::Information);
                }, ]
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
    run Prima;
}

has current => {};

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

has tmpdir => ( default => sub {
    return $ENV{TEMP} || $ENV{TMP} if $^O =~ /Win32|Cygwin/i;
    return $ENV{TMPDIR} || '/tmp';
});

sub download_data {
    my ($self) = @_;
#    say Dumper($self->current);
    my $start = $self->current->{start_date};
    my $end = $self->current->{end_date};
    my $symbol = $self->current->{symbol};
    #TODO: check symbol validity
    my $csv = sprintf "%s_%d_%d.csv", $symbol, $start->ymd(''), $end->ymd('');
    $csv = File::Spec->catfile($self->tmpdir, $csv);
    my $data;
    unlink $csv if $self->current->{force_download};
    unless (-e $csv) {
        my $fq = new Finance::QuoteHist(
            symbols => [ $symbol ],
            start_date => $start->mdy('/'),
            end_date => $end->mdy('/'),
            auto_proxy => 1,
        );
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
        $fq->clear_cache;
        close $fh;
        say "$csv has downloaded data for analysis";
        $data = pdl(@quotes)->transpose;
    } else {
        ## now read this back into a PDL using rcol
        say "$csv already present. loading it...";
        $data = PDL->rcols($csv, [], { COLSEP => ',', DEFTYPE => PDL::double});
    }
    return $data;
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
                say "Tab changed from $oldidx to $newidx";
                return if $oldidx == $newidx;
                # ok find the detailed-list object and use it
                my $data = $self->_get_tab_data($w, $newidx);
                $self->plot_data($owner, $data);
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
}

sub _get_tab_data {
    my ($self, $nb, $idx) = @_;
    my @nt = $nb->widgets_from_page($idx);
    my ($dl) = grep { $_->name =~ /^tab_/i } @nt;
    say "Found ", $dl->name if $self->debug;
    return $dl->{-pdl};
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
    my ($self, $win, $data) = @_;
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
    my ($self, $win, $data, $symbol) = @_;
    return unless defined $data;
    my $pwin = $win->{plot} || gpwin('x11', size => [1280, 960, 'px']);
    $win->{plot} = $pwin;
    $pwin->plot({
            title => $symbol,
            xlabel => 'Date',
            ylabel => 'Price',
            xdata => 'time',
            xtics => {format => '%Y-%m-%d', rotate => -90, },
        },
        with => 'financebars', $data(,(0)), $data(,(1)), $data(,(2)),
        $data(,(3)), $data(,(4))
    );
}

1;
__END__
### COPYRIGHT: 2014 Vikas N. Kumar. All Rights Reserved.
### AUTHOR: Vikas N Kumar <vikas@cpan.org>
### DATE: 3rd Jan 2014
### LICENSE: Refer LICENSE file

=head1 NAME

PDL::Finance::TA

=head1 SYNOPSIS

PDL::Finance::TA is a perl module allowing the user to perform technical
analysis on financial data stored as PDLs.

=head1 VERSION

0.02

=head1 METHODS

=over

=item B<movavg $p, $N>

The C<movavg()> function takes two arguments, a pdl object and the number of
elements over which to calculate the simple moving average. It can be invoked in two
ways:

    use PDL;
    use PDL::Finance::TA 'movavg';
    my $ma_13 = $p->movavg(13); # the 13-day moving average
    my $ma_21 = movavg($p, 21); # the 21-day moving average

For a nice example on how to use moving averages and plot them see
I<examples/movavg.pl>.

=begin HTML

<p><img
src="http://vikasnkumar.github.io/PDL-Finance-TA/images/pgplot_movavg.png"
alt="Simple Moving Average plot of YAHOO stock for 2013" /></p>

=end HTML

=item B<expmovavg $p, $N, $alpha>

The C<expmovavg()> function takes three arguments, a pdl object, the number of
elements over which to calculate the exponential moving avergage and the
exponent to use to calculate the moving average. If the number of elements is 0
or C<undef> then all the elements are used to calculate the value. If the
exponent argument is C<undef>, the value of (2 / (N + 1)) is assumed.

For a nice example on how to use and compare exponential moving average to the
simple moving average look at I<examples/expmovavg.pl>.

=begin HTML

<p><img
src="http://vikasnkumar.github.io/PDL-Finance-TA/images/pgplot_expmovavg.png"
alt="Exponential Moving Average plot of YAHOO stock for 2013" /></p>

=end HTML

=back

=head1 COPYRIGHT

Copyright (C) 2013-2014. Vikas N Kumar <vikas@cpan.org>. All Rights Reserved.

=head1 LICENSE

This is free software. You can redistribute it or modify it under the terms of
Perl itself. Refer LICENSE file in the top level source directory for more
information.
