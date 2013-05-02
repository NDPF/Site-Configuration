#!perl -T

use 5.006;
use strict;
use warnings;
use File::Temp qw/tempdir/;
use File::Copy::Recursive qw/dircopy/;
use Test::More  tests => 19;

BEGIN { use_ok( 'Site::Configuration::VO' ); }
require_ok( 'Site::Configuration::VO' );

# The tests are done on a set of known files in testdata. First, this
# data is copied to a temporary directory to safely work on.

my $dir = tempdir('votestXXXXXX', TMPDIR => 1, CLEANUP => 0);
dircopy("testdata", $dir);

mkdir $dir . "/vos" or die "cannot mkdir $dir/vos";
open my $fh, ">", "$dir/vos/pvier.conf" or
  die "cannot open file $dir/vos/pvier.conf for writing";
print $fh <<EOF;
[DEFAULT]
enabled=true

# example configuration file for VO pvier
# Each FQAN has its own section
[/pvier/Role=lcgadmin]
## set poolaccounts to the number of gridmapdir entries to create
## gridmapdir entries
#poolaccounts = 0
## Set poolprefix to the name of the pool accounts without the numeric tail
#poolprefix =
## Set groupmapping if this FQAN should be used in the groupmapfile
groupmapping=pvier
EOF
close $fh;

open $fh, ">", "$dir/vos/ops.conf" or
  die "cannot open file $dir/vos/ops.conf for writing";
print $fh <<EOF;
[/ops]
poolaccounts = 0
EOF
close $fh;

# confdir is the base configuration directory, normally /etc/vo-config
my $confdir = $dir;

# START OF TESTS

# Plain constructor test; calling new() should result in an instance.
isa_ok(my $voconf = Site::Configuration::VO->new(), 'Site::Configuration::VO');

# Calling new with parameters should set these in the object.
my $voconf2 = Site::Configuration::VO->new(vo => "testvo", confdir => $confdir);
is($voconf2->confdir, $confdir, 'Confdir set in constructor');
is($voconf2->vo, "testvo", "VO set in constructor");

# Getter/setter functionality
is($voconf->confdir($confdir), $confdir, "confdir setter");
is($voconf->confdir, $confdir, "Confdir getter");

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

# Get a VO parameter from a configured VO
my $gm = $voconf->get_vo_param(vo => "pvier",
			       fqan => "/pvier/Role=lcgadmin",
			       param => "groupmapping") or
  diag($voconf->errmsg);

is($gm, "pvier", "get_vo_param on configured VO");

# test enabled/disable/re-enable
$voconf->vo("pvier");
ok($voconf->isenabled, "isenabled");
ok($voconf->disable, "disable");
ok(!$voconf->isenabled, "VO is disabled");
ok($voconf->enable, "enable");
ok($voconf->isenabled, "isenabled (again)");

# test enabled of non-configured vo
ok(!defined($voconf->isenabled(vo => "unknownvo")), "Unknown VO enabled state is undefined");

# test enabled of vo without default section
ok($voconf->isenabled(vo => "ops"), "VO without DEFAULT section is enabled");

done_testing;
