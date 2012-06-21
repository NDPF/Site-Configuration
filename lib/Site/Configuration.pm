# Experimental perl module
#  Copyright 2012  Stichting FOM
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

package Site::Configuration;

use 5.006;
use strict;
use warnings;
use Carp;
use Config::IniFiles;

=head1 NAME

Site::Configuration - Access site-local configuration data

=head1 VERSION

Version 0.02

=cut

BEGIN {
  use Exporter ();
  our ($VERSION, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS);
  $VERSION = "0.02";
  @ISA = qw(Exporter);
  @EXPORT = qw(&get_vo_param &readconfig);
  %EXPORT_TAGS = ( );
  @EXPORT_OK = qw( );
}

our @EXPORT_OK;

our $confdir = "/etc/siteinfo";

# configuration holds all of the hashes tied into INI files.
my %configuration = ();


=head1 SYNOPSIS

This module reads configuration files from /etc/siteinfo/ and returns
the data as tied hashes. The format of the configuration files must be
Ini files.

    use Site::Configuration;

    my $ceconf = readconfig("ce.conf");

    my $node = $ce->{CE};

    ...

=head1 EXPORT


=head1 SUBROUTINES/METHODS

=head2 readconfig SCALAR

read the given configuration file and return a tied hash For more
documentation on tied hashes and Ini files see L<Config::IniFiles>.

=cut

sub readconfig($) {
  my $conf = shift;
  # don't read the configuration again.
  return $configuration{$conf} if defined $configuration{$conf};

  # Sanity: does the configuration file exist?
  -f "$confdir/$conf" or croak "Missing configuration file $confdir/$conf, stopping";

  tie my %ini, 'Config::IniFiles',
    ( -file => "$confdir/$conf", 
      -fallback => "DEFAULT",
      -handle_trailing_comment => 1,
      -allowcontinue => 1,
      -nocase => 1) or
	do {
	  print STDERR $_ foreach @Config::IniFiles::errors;
	  croak "Can't read configuration file $conf, stopped"
	};
  # store the configuration hash. Why must this be a ref?
  $configuration{$conf} = \%ini;
  return \%ini;
};

=head2 get_vo_param LIST

look up the first element of LIST as a section in vo.conf, and the second
element as the key in that section. Return the associated value, if any.
CAVEAT: this is all but deprecated because it's going to move
to the vo-support package.

=cut

# Arguments: vo, param
sub get_vo_param($$) {
  my $vo = shift;
  my $param = shift;

  if (! $configuration{"vo.conf"}) {
    readconfig("vo.conf");
  }

  if ($configuration{"vo.conf"}{$vo}{$param}) {
    return $configuration{"vo.conf"}{$vo}{$param};
  } else {
    return $configuration{"vo.conf"}->{DEFAULT}{$param};
  }
}

=head1 AUTHOR

Dennis van Dok, C<< <dennisvd at nikhef.nl> >>

=head1 BUGS

Please report any bugs or feature requests to C<grid-mw-security-support at nikhef.nl>.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Site::Configuration


=head1 LICENSE AND COPYRIGHT

Copyright 2012 Stichting FOM

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    L<http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.


=cut

1; # End of Site::Configuration
