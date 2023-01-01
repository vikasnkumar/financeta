package App::financeta::utils;
use strict;
use warnings;
use 5.10.0;
use feature 'say';
use Carp;
use Data::Dumper ();
use Exporter qw(import);

our $VERSION = '0.11';
$VERSION = eval $VERSION;

our @EXPORT_OK = (
    qw(dumper)
);

sub dumper {
    Data::Dumper->new([@_])->Indent(1)->Sortkeys(1)->Terse(1)->Useqq(1)->Dump;
}

1;
__END__
### COPYRIGHT: 2014-2023 Vikas N. Kumar. All Rights Reserved.
### AUTHOR: Vikas N Kumar <vikas@cpan.org>
### DATE: 1st Jan 2023
### LICENSE: Refer LICENSE file

=head1 NAME

App::financeta::utils

=head1 SYNOPSIS

App::financeta::utils is an internal utility library for App::financeta.

=head1 VERSION

0.11


=head1 METHODS

=over

=item B<dumper>

L<Data::Dumper> with the Terse option set.

=back

=head1 SEE ALSO

=over

=item L<App::financeta::gui>

This is the GUI internal details being used by C<App::financeta>.

=item L<financeta>

The commandline script that calls C<App::financeta>.

=back

=head1 COPYRIGHT

Copyright (C) 2013-2023. Vikas N Kumar <vikas@cpan.org>. All Rights Reserved.

=head1 LICENSE

This is free software. You can redistribute it or modify it under the terms of
GNU General Public License version 3. Refer LICENSE file in the top level source directory for more
information.
