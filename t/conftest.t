#!perl -T

use 5.006;
use strict;
use warnings;
use File::Temp qw/tempdir/;
use File::Copy::Recursive qw/dircopy/;
use Test::More  tests => 17;

BEGIN { use_ok( 'Site::Configuration' ); }
require_ok( 'Site::Configuration' );

# create a simple test file in a temporary directory
my $dir = tempdir('votestXXXXXX', TMPDIR => 1, CLEANUP => 0);

open my $fh, ">", $dir . "/test.conf";

print $fh <<EOF;
# test configuration file
name =  test configuration
[top]
clusters = cluster1

[cluster1]
Name=Example Cluster 1
EOF

close $fh;


# START OF TESTS

# Plain constructor test; calling new() should result in an instance.
isa_ok(my $siteconf = Site::Configuration->new(), 'Site::Configuration');

# default property
is($siteconf->{CONFDIR}, "/etc/siteinfo", "default confdir value");
is($siteconf->confdir, "/etc/siteinfo", "confdir getter");
ok($siteconf->confdir($dir), "confdir setter");
is($siteconf->confdir, $dir, "set confdir value persists");

# constructor with confdir param
isa_ok(my $siteconf2 = Site::Configuration->new($dir), "Site::Configuration");
is($siteconf->confdir, $dir, "confdir set in constructor");

# readconfig
isa_ok(my $conf = $siteconf->readconfig("test.conf"), 'HASH');

is($conf->{DEFAULT}{name}, "test configuration", "DEFAULT section");
is($conf->{top}{clusters}, "cluster1", "top section");
is($conf->{cluster1}{Name}, "Example Cluster 1");

ok($conf->{cluster1}{Name} = "new name for cluster 1", "overwrite value");
ok($conf->{cluster2}{Name} = "new cluster 2", "new section and parameter");

ok($siteconf->writeconfig($conf), "write the new configuration");

# read the same config file in another object
my $conf2 = $siteconf2->readconfig("test.conf");

# compare both objects

subtest 'compare configurations' => sub {
  plan tests => 10;
  foreach my $key (keys %{$conf}) {
    ok(exists($conf2->{$key}), "keys in one conf appear in the other");
    # values are hashes too!
    foreach my $subkey (keys $conf->{$key}) {
      ok(exists($conf2->{$key}{$subkey}), "subkeys in one conf appear in the other");
      is($conf->{$key}{$subkey}, $conf2->{$key}{$subkey}, "subkey entries are identical");
    }
  }
};

done_testing;
