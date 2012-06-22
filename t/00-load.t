#!perl -T

use Test::More tests => 2;

BEGIN {
    use_ok( 'Site::Configuration' ) || print "Bail out!\n";
    use_ok( 'Site::Configuration::VO' ) || print "Bail out!\n";
}

diag( "Testing Site::Configuration $Site::Configuration::VERSION, Perl $], $^X" );
