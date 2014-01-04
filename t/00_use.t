use Test::More;

BEGIN { use_ok('PDL::Finance::TA'); }

SKIP: {
    eval { require Alien::TALib };
    skip 'Alien::TALib is not installed', 1 if $@;
    use_ok('PDL::Finance::TA::TALib');
}

done_testing();

__END__
### COPYRIGHT: 2013 Vikas N. Kumar. All Rights Reserved.
### AUTHOR: Vikas N Kumar <vikas@cpan.org>
### DATE: 21st Mar 2013
### LICENSE: Refer LICENSE file

