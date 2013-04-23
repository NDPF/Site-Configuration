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

package Site::Configuration::VO;

use 5.006;
use strict;
use warnings;
use Site::Configuration;

=head1 NAME

Site::Configuration::VO - Access Virtual Organisation configuration

=head1 VERSION

Version 0.04

=cut

our $VERSION = '0.04';

=head1 SYNOPSIS

    use Site::Configuration::VO;

    my $voconf = Site::Configuration::VO->new();
    my @fqans = $voconf->get_fqans(I<vo>);
    my $param = $voconf->get_vo_param(I<vo>,I<param> [, I<fqan> ] )


=cut

sub new {
  my $class = shift;
  my $self = { SITECONFIG => Site::Configuration->new("/etc/vo-support/vos"),
	       VOCONF => {},
	       ERRMSG => []
	     };
  bless ($self, $class);
  return $self;
}

# return and clear
sub errmsg {
  my $self = shift;
  my @ret = @{$self->{ERRMSG}};
  $self->{ERRMSG} = [];
  return @ret;
}

sub confdir {
  my $self = shift;
  return $self->{SITECONFIG}->confdir(@_); # transparent?
}


sub get_vo_param {
  my $self = shift;
  my ($vo, $param, $fqan) = @_;
  if (!defined $fqan) { $fqan = "DEFAULT" }
  # check if we already have the VO
  $self->_readvo($vo) or return undef;
  # look up the parameter
  my $val = $self->{VOCONF}->{$vo}->{$fqan}{$param};
  return $val;
}

sub get_fqans {
  my $self = shift;
  my $vo = shift;
  my @fqans = (); # return value.
  $self->_readvo($vo) or return ();
  for my $section (keys %{$self->{VOCONF}->{$vo}}) {
    if ($section =~ m{^/[[:alpha:]]}) {
      push @fqans, $section
    }
  }
  return @fqans;
}

sub _readvo {
  my $self = shift;
  my $vo = shift;
  # read vo configuration only once
  if ( ! defined $self->{VOCONF}->{$vo}) {
    $self->{VOCONF}->{$vo} = $self->{SITECONFIG}->readconfig($vo . ".conf");
  }
  if ( ! defined $self->{VOCONF}->{$vo}) {
    push @{$self->{ERRMSG}}, $_ foreach $self->{SITECONFIG}->errmsg();
    push @{$self->{ERRMSG}}, "Cannot not read configuration for VO '$vo'.";
    return undef;
  }
  return $self->{VOCONF}->{$vo};
}

=head1 DESCRIPTION

The Site::Configuration::VO module provides read access to the
configuration of Virtual Organisations on the local system. Like
Site::Configuration, the configuration files are in Ini file format,
one file per VO. The default directory to look for configuration files
is /etc/vo-support/vos, but it can be overridden by using the confdir
object method.

VO configuration is organised in a single file named I<vo>.conf, with
sections for each FQAN. Settings that are global to the VO go in the
top section called [DEFAULT], but this section header may be
omitted. Any settings preceding the first FQAN is considered to be in
the [DEFAULT] section.

The constructor accepts a single optional argument, which is the directory
to read the VO configuration files from.

    my $voconf = Site::Configuration::VO->new();
    my $voconf = Site::Configuration::VO->new("/etc/othervos");

The configuration directory may be changed by using the confdir() method.

    my $oldconfig = $voconfig->confdir();
    $voconf->confdir("/etc/othervo");

Be aware that changing the directory after accessing a VO's parameters won't work
as Site::Configuration::VO keeps the handle to the original file.

The FQANs for a VO are enumerated with the get_fqans() method.

    my @fqans = $voconf->get_fqans(I<vo>);

Specific VO parameters are retrieved with the get_vo_param() method.

    my $defaultse = $voconf->get_vo_param(pvier, "defaultse")
    my $poolprefix = $voconf->get_vo_param(pvier, "poolprefix", "/pvier" )

The first form retrieves a VO global parameter. The second form looks up a
parameter in a specific FQAN section.

=head2 File Format

The VO configuration files are found in /etc/vo-support/I<vo>.conf, unless the
directory was changed as described above. The files are in Ini file format,
see L<Config::IniFiles>.

    # example configuration file for pvier
    SoftwareDir = /data/esia/pvier
    DefaultSE = tbn18.nikhef.nl

    [/pvier]
    poolaccounts = 30
    poolprefix = pvier
    groupmapping = pvier

    [/pvier/Role=lcgadmin]
    poolprefix = pvsgm
    poolaccounts = 10


=head2 Error Handling

In case of errors, get_fqans() returns an empty list and
get_vo_param() returns undef.  The array of error messages may be
retrieved using the errmsg() method.

      print STDERR "$_\n" foreach $voconf->errmsg();

Any errors that occur on consecutive calls will accumulate in this array;
the errmsg() method clears the array again.

=head1 FILES

/etc/vo-support/vos/*.conf

=head1 SEE ALSO

L<Site::Configuration>, L<Config::IniFiles>

=head1 AUTHOR

Dennis van Dok <dennisvd@nikhef.nl>

Please report any bugs or feature requests to <grid-mw-security-support@nikhef.nl>.

=head1 COPYRIGHT AND LICENSE

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


1; # End of Site::Configuration::VO
