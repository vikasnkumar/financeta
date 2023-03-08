package App::financeta::gui::progress_bar;
use strict;
use warnings;
use 5.10.0;

use App::financeta::mo;
use Log::Any '$log', filter => \&App::financeta::utils::log_filter;
use Prima qw(Application  sys::GUIException Utils );

$|=1;

has owner => (required => 1);
has gui => (required => 1);
has bar => ( builder => '_build_bar' );
has title => (required => 1);
has bar_width => 160;
has bar_height => 80;

sub _build_bar {
    my $self = shift;
    my $gui = $self->gui;
    $log->debug("Creating progress bar for " . ref($gui));
    my $bar = Prima::Window->create(
        name => 'progress_bar',
        text => $self->title,
        size => [$self->bar_width, $self->bar_height],
        origin => [0, 0],
        widgetClass => wc::Dialog,
        borderStyle => bs::Single,
        borderIcons => bi::TitleBar,
        centered => 1,
        owner => $self->owner,
        visible => 1,
        pointerType => cr::Wait,
        onPaint => sub {
            my ($w, $canvas) = @_;
            $canvas->color(cl::Blue);
            $canvas->bar(0, 0, $w->{-progress}, $w->height);
            $canvas->color(cl::Back);
            $canvas->bar($w->{-progress}, 0, $w->size);
            #$canvas->color(cl::Yellow);
            #$canvas->font(size => 16, style => fs::Bold);
            #$canvas->text_out($w->text, 0, 10);
        },
        syncPaint => 1,
        onTop => 1,
    );
    $bar->{-progress} = 0;
    $bar->repaint;
    $bar->owner->pointerType(cr::Wait);
    $bar->owner->repaint;
    return $bar;
}

sub update {
    my ($self, $val) = @_;
    ## is percentage
    if (defined $val and ($val > 0 and $val < 1)) {
        $self->bar->{-progress} += ($val * $self->bar_width);
    } else {#is absolute
        $self->bar->{-progress} += $val // 5;
    }
    $self->bar->repaint;
}

sub close {
    my $self = shift;
    $self->bar->owner->pointerType(cr::Default);
    $self->bar->close;
}

sub progress {
    return shift->bar->{-progress};
}

1;
__END__
### COPYRIGHT: 2013-2023. Vikas N. Kumar. All Rights Reserved.
### AUTHOR: Vikas N Kumar <vikas@cpan.org>
### DATE: 30th Aug 2014
### LICENSE: Refer LICENSE file
