#!perl -T

use 5.006;
use strict;
use warnings;
use File::Temp qw/tempdir/;
use File::Copy::Recursive qw/dircopy/;
use Test::More ; # tests => 3;

BEGIN { use_ok( 'Site::Configuration::VO' ); }
require_ok( 'Site::Configuration::VO' );

# The tests are done on a set of known files in testdata. First, this
# data is copied to a temporary directory to safely work on.

my $dir = tempdir('votestXXXXXX', TMPDIR => 1, CLEANUP => 0);
dircopy("testdata", $dir);

# confdir is the base configuration directory, normally /etc/vo-config
my $confdir = $dir . "/testdata/conf";

# START OF TESTS

# Plain constructor test; calling new() should result in an instance.
my $voconf = Site::Configuration::VO->new();
isa_ok($voconf, 'Site::Configuration::VO');

# Calling new with parameters should set these in the object.
my $voconf2 = Site::Configuration::VO->new(vo => "testvo", confdir => $confdir);
is($voconf2->confdir, $confdir, 'Confdir set in constructor');
is($voconf2->vo, "testvo", "VO set in constructor");

# Getter/setter functionality
$voconf->confdir($confdir);
is($voconf->confdir, $confdir, "Confdir setter");

$voconf->vo("atlas");
is($voconf->vo, "atlas", "VO setter");


# Getting parameters and fail conditions; VO atlas is not configured
# so this should result in undef and errmsg being filled.
my $p = $voconf->get_vo_param(param => "foo");
ok( ! defined $p, "get_vo_param on non-configured VO gives undef");
my @msg = $voconf->errmsg;
like(join(' ',@msg), qr/Cannot read configuration for VO 'atlas'/, "get_vo_param on non-configured VO gives errmsg");
# errmsg should clear itsself after each all
cmp_ok($voconf->errmsg, '==', 0, "errmsg clears itsself");


done_testing;
