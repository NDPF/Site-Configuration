use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Site::Configuration',
    AUTHOR              => q{Dennis van Dok <dennisvd@nikhef.nl>},
    VERSION_FROM        => 'lib/Site/Configuration.pm',
    ABSTRACT_FROM       => 'lib/Site/Configuration.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'apache')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Site-Configuration-*' },
);
