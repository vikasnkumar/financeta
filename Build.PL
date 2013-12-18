use strict;
use warnings;
use Module::Build::PDL;
use Alien::TALib;

my $alien = Alien::TALib->new;
my $build = Module::Build::PDL->new(
    module_name => 'PDL::Finance::TA',
    license => 'perl',
    dist_author => 'Vikas N. Kumar <vikas@cpan.org>',
    dist_abstract => 'PDL::Finance::TA is a wrapper for ta-lib from http://ta-lib.org using PDL',
    dist_version_from => 'lib/PDL/Finance/TA.pd',
    create_readme => 0,
    create_license => 1,
    configure_requires => {
        'Alien::TALib' => 0,
        'Module::Build' => 0,
        'Module::Build::PDL' => 0,
        'Software::License' => 0,
    },
    build_requires => {
        'Alien::TALib' => 0,
        'Module::Build' => 0,
        'Module::Build::PDL' => 0,
        'Test::More' => 0,
    },
    requires => {
        'perl' => '5.10.0',
        'PDL'  => '2.006',
    },
    recommends => {
        'lib::abs' => 0,
    },
    dynamic_config => 1,
    extra_compiler_flags => $alien->cflags(),
    extra_linker_flags => $alien->libs(),
    meta_merge => {
        resources => {
            repository => "https://github.com/vikasnkumar/PDL-Finance-TA",
            bugtracker => "https://github.com/vikasnkumar/PDL-Finance-TA/issues",
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
