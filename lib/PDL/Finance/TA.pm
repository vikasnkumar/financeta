package PDL::Finance::TA;
use 5.10.0;

BEGIN {
    use Exporter();
    our @ISA = qw/Exporter/;
    our $VERSION = '0.01';
    $VERSION = eval $VERSION;
    our @EXPORT;
    our @EXPORT_OK = qw(
        movavg
    );
    our %EXPORT_TAGS = (
        Func => [@EXPORT_OK],
        Internal => [],
    );
}
use PDL::Finance::TA::Perl;

*movavg = \&PDL::Finance::TA::Perl::movavg;

1;
__END__
### COPYRIGHT: 2014 Vikas N. Kumar. All Rights Reserved.
### AUTHOR: Vikas N Kumar <vikas@cpan.org>
### DATE: 3rd Jan 2014
### LICENSE: Refer LICENSE file
