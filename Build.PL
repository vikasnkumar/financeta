use strict;
use warnings;
use Module::Build::PDL;

sub check_alien_talib {
    return undef if $^O =~ /MSWin32|Cygwin/i;
    eval 'require Alien::TALib' || return undef;
    return Alien::TALib->new;
}
my $alien = check_alien_talib();
my %talib = (
    extra_compiler_flags => $alien->cflags(),
    extra_linker_flags => $alien->libs(),
    auto_features => {
        talib_support => {
            description => "Use TALib instead of pure perl interface where applicable",
            configure_requires => {
                'Alien::TALib' => 0,
            },
            requires => {
                'Alien::TALib' => 0,
            },
        },
    },
) if $alien;

my $class = 'Module::Build::PDL';
$class = 'Module::Build' unless $alien;

my $build = $class->new(
    module_name => 'PDL::Finance::TA',
    license => 'perl',
    dist_author => 'Vikas N. Kumar <vikas@cpan.org>',
    dist_abstract => 'PDL::Finance::TA provides technical analysis functions for PDL',
    create_readme => 0,
    create_license => 1,
    configure_requires => {
        'Module::Build' => 0,
        'Module::Build::PDL' => 0,
        'Software::License' => 0,
    },
    build_requires => {
        'Module::Build' => 0,
        'Module::Build::PDL' => 0,
        'Test::More' => 0,
    },
    requires => {
        'perl' => '5.10.0',
        'PDL'  => '2.006',
    },
    %talib,
    share_dir => {
        dist => [qw/examples/],
    },
    dynamic_config => 1,
    add_to_cleanup => [ qw/*.bak _Inline/ ],
    meta_merge => {
        resources => {
            repository => "https://github.com/vikasnkumar/PDL-Finance-TA",
            bugtracker => "https://github.com/vikasnkumar/PDL-Finance-TA/issues",
        },
        keywords => [qw/ finance technical-analysis technical analysis/],
        no_index => {
            directory => [qw/ t examples /],
        },
    },
);

$build->create_build_script;
$build->dispatch('distmeta');
$build->dispatch('manifest');

__END__
#### COPYRIGHT: 2013. Vikas N Kumar. All Rights Reserved
#### AUTHOR: Vikas N Kumar <vikas@cpan.org>
#### DATE: 18th Dec 2013
#### LICENSE: Refer LICENSE file.
