use strict;
use warnings;
use Module::Build;

my $build = Module::Build->new(
    module_name => 'App::financeta',
    license => 'gpl',
    dist_author => 'Vikas N. Kumar <vikas@cpan.org>',
    dist_abstract => 'App::financeta is a Technical Analysis GUI',
    dist_version_from => 'lib/App/financeta.pm',
    create_readme => 0,
    configure_requires => {
        'Module::Build' => 0,
        'Software::License' => 0,
        'Pod::Readme' => 0,
    },
    build_requires => {
        'Module::Build' => 0,
        'Test::More' => 0,
        'File::Spec' => 0,
        'File::ShareDir' => 0,
    },
    requires => {
        'perl' => '5.10.0',
        'Carp' => 0,
        'Data::Dumper' => 0,
        'File::Spec' => 0,
        'File::ShareDir' => 0,
        'PDL'  => '2.007',
        'DateTime' => 0,
        'Finance::QuoteHist' => 1.20,
        'PDL::Finance::Talib' => '0.006',
        'Prima' => 1.39,
        'DateTime::Format::Strptime' => 0,
        'POE::Loop::Prima' => 0,
        'PDL::Graphics::Gnuplot' => 0,
        'Capture::Tiny' => 0,
        'Scalar::Util' => 0,
        'Getopt::Long' => 0,
    },
    dynamic_config => 1,
    add_to_cleanup => [ qw/*.bak _Inline/ ],
    meta_merge => {
        resources => {
            repository => "https://github.com/vikasnkumar/financeta",
            bugtracker => "https://github.com/vikasnkumar/financeta/issues",
        },
        keywords => [qw/ finance technical-analysis technical analysis/],
        no_index => {
            directory => [qw/ t share /],
        },
    },
    share_dir => 'share',
    installdirs => ($^O =~ /Darwin/i) ? 'core' : 'site',
);

$build->add_build_element('image');
$build->create_build_script;
$build->dispatch('distmeta');
$build->dispatch('manifest');

__END__
#### COPYRIGHT: 2013. Vikas N Kumar. All Rights Reserved
#### AUTHOR: Vikas N Kumar <vikas@cpan.org>
#### DATE: 18th Dec 2013
#### LICENSE: Refer LICENSE file.
