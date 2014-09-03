use Test::More;

use_ok('App::financeta::language');

my $lang = new_ok('App::financeta::language');
can_ok($lang, 'grammar');
can_ok($lang, 'receiver');
can_ok($lang, 'parser');
can_ok($lang, 'compile');

my $text = << 'TEST1';
financeta
TEST1
is($lang->compile($text), 'FINANCETA', 'compiler works');

done_testing();

__END__
### COPYRIGHT: 2014 Vikas N. Kumar. All Rights Reserved.
### AUTHOR: Vikas N Kumar <vikas@cpan.org>
### DATE: 3rd Sept 2014
### LICENSE: Refer LICENSE file
