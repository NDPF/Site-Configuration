#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Site::Configuration' ) || print "Bail out!\n";
}

diag( "Testing Site::Configuration $Site::Configuration::VERSION, Perl $], $^X" );
