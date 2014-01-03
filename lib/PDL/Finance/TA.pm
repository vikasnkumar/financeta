package PDL::Finance::TA;
use 5.10.0;
BEGIN {
    use Exporter();
    our $VERSION = '0.01';
    $VERSION = eval $VERSION;
}

use PDL::Finance::TA::Perl;

our @EXPORT = qw(
    movavg
);

1;
__END__
### COPYRIGHT: 2014 Vikas N. Kumar. All Rights Reserved.
### AUTHOR: Vikas N Kumar <vikas@cpan.org>
### DATE: 3rd Jan 2014
### LICENSE: Refer LICENSE file
