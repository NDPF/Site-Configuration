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
use Carp;

=head1 NAME

Site::Configuration::VO - Access Virtual Organisation configuration

=head1 VERSION

Version 0.05

=cut

our $VERSION = '0.05';

=head1 SYNOPSIS

    use Site::Configuration::VO;

    my $voconf = Site::Configuration::VO->new();
    my @fqans = $voconf->get_fqans(vo => "atlas");
    my $param = $voconf->get_vo_param( vo    => "atlas",
                                       param => "poolprefix",
                                       fqan  => "/atlas/Role=pilot" );
    $voconf->vo("atlas");
    $voconf->set_vo_param( param => "poolaccounts",
                           fqan  => "/atlas/Role=pilot",
                           value => "100" )

=cut


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

=head1 METHODS

Here follows the detailed documentation of the public methods.

=head2 new (constructor)

The constructor can be called with two named parameters: B<confdir> for
the configuration directory to use (defaults to F</etc/vo-support/vos>)
and B<vo> to indicate which VO to use in subsequent calls to other methods.
Both can be set and reset at any time.
Example:
    my $voconfig = Site::Configuration::VO->new(vo => "atlas")

=cut

sub new {
  my $class = shift;
  my %params = @_;
  my $confdir = $params{confdir} // "/etc/vo-support/vos";
  my $self = { SITECONF => Site::Configuration->new($confdir),
	       VO => $params{vo},
	       VOCONF => {},
	       ERRMSG => [],  # array of accumulated error messages
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

=head2 accessors: vo and confdir

Two accessor methods allow getting and setting of the VO
and configuration directory.
    $voconfig->vo();        # returns current VO
    $voconfig->vo("atlas"); # sets current VO

    $voconfig->confdir();       # returns current configuration directory
    $voconfig->confdir("/tmp"); # sets current configuration directory

=cut

# getter/setter
sub vo {
  my $self = shift;
  if (@_) { $self->{VO} = shift }
  return $self->{VO};
}

sub confdir {
  my $self = shift;
  return $self->{SITECONF}->confdir(@_); # transparent?
}

=head2 get_vo_param

This method retrieves parameters from the VO configuration file.
The parameters that may be passed are:

=over

=item B<vo>

The VO of which to retrieve the configuration.

=item B<fqan>

The FQAN section in the config file to retrieve
the parameter from. If this is not specified, the [DEFAULT]
section is used (if no [DEFAULT] section is present, this
refers to all parameters in the file before the first FQAN
section).

=item B<param> (mandatory)

The name of the parameter to retrieve.

=back

=head3 Return Value

=over

=item The requested parameter

In case the parameter was found in the file

=item undef

This can happen in three situations:

=over

=item The VO wasn't specified, and no VO was ever set in the object.

=item The configuration file for the VO could not be read.

=item The requested parameter was missing in the configuration file.

=back

The only way to distinguish between these cases is by calling
the errmsg() method.

=back

=cut

sub get_vo_param {
  my $self = shift;
  my %params = @_;
  my $vo = $params{'vo'} // $self->{VO} or
    croak "get_vo_param: VO not set.";

  my $fqan = $params{fqan} // "DEFAULT";

  my $param = $params{param};
  if (!defined $param) {
      croak "get_vo_param: missing 'param' argument";
  }
  # check if we already have the VO
  $self->_readvo($vo) or return undef;
  # look up the parameter
  my $val = $self->{VOCONF}->{$vo}->{$fqan}{$param};
  return $val;
}

=head2 set_vo_param

The counterpart of retrieving VO parameters is this method which sets
them. This immediately results in the rewriting of the configuration
file. The following parameters may be passed:

=over

=item vo

=item fqan

=item param

=item value

=back

=head3 Return Value

Returns undef in case of failure, 1 otherwise.

=cut

# This may be dangerous; going to try and rewrite the original config file!
# TODO: this code is so much like get_vo_param it should be refactored
# into a single module.

sub set_vo_param {
  my $self = shift;
  my %params = @_;
  my $vo = $params{vo} // $self->{VO};
  my $fqan = $params{fqan} // "DEFAULT";
  foreach $_ (qw(param value)) {
    if ( ! defined $params{$_} ) {
      croak "Missing parameter '$_' to function set_vo_param";
    }
  }
  my ($param, $value) = ($params{param}, $params{value});

  $self->_readvo($vo) or return undef;
  if ( ! defined $self->{VOCONF}->{$vo}) {
    push @{$self->{ERRMSG}}, "Cannot set VO parameter.";
    return undef;
  }
  $self->{VOCONF}->{$vo}->{$fqan}{$param} = $value;
  if (! defined $self->{SITECONF}->writeconfig($self->{VOCONF}->{$vo}) ) {
    push @{$self->{ERRMSG}}, $_ foreach $self->{SITECONF}->errmsg();
    push @{$self->{ERRMSG}}, "Cannot write configuration for VO '$vo'.";
    return undef;
  }
  return 1;
}

=head2 get_fqans

Returns a list of FQANs configured for the VO; this is the list of
sections in the configuration file that start with a '/' and a
letter. Other sections are ignored.

This method takes a single optional parameter to specify the VO.
    my @fqans = $voconfig->get_fqans(vo => "atlas");

In case of an error, returns an array with just one undefined element

=cut

sub get_fqans {
  my $self = shift;
  my %params = @_;
  my $vo = $params{vo} // $self->{VO};
  if ( ! defined $vo ) {
    push @{$self->{ERRMSG}}, "get_fqans: VO not specified";
    return undef;
  }

  my @fqans = (); # return value.
  $self->_readvo($vo) or return (undef);
  for my $section (keys %{$self->{VOCONF}->{$vo}}) {
    if ($section =~ m{^/[[:alpha:]]}) {
      push @fqans, $section
    }
  }
  return @fqans;
}

=head2 isenabled

Arguments: I<vo>.

Returns 1 if the VO is enabled, 0 otherwise. If the I<enabled> parameter
is not found in the configuration file, the default value is assumed to be
'true'.

Returns undef if the VO is not configured.

=cut

sub isenabled {
  my $self = shift;
  my %args = @_;
  my $vo = $args{vo} // $self->{VO};
  if (! defined $vo) { croak "isenabled: no VO given" };
  $self->_readvo($vo) or return undef;
  my $enabled = $self->get_vo_param(vo => $vo, param => "enabled");
  return (! defined $enabled) || $enabled !~ m/(false|no|disabled|0)/i;
}

=head2 enable, disable

These methods set the I<enabled> parameter in the [DEFAULT] section of the
configuration to 'true' and 'false', respectively.

    $voconfig->enable( vo => "atlas" )

Some care is taken to prevent unnecessary rewrites of the configuration; if the VO is already in
the requested state nothing is done.

The return value is 1 on success, 0 otherwise.

If there is no configuration file, no action is taken and undef is returned.

=cut

sub enable {
  my $self = shift;
  my %args = @_;
  my $vo = $args{vo} // $self->{VO} or croak "enable: no VO given";
  return 1 if $self->isenabled(vo => $vo);
  return $self->set_vo_param(vo => $vo, param => "enabled", value => "true");
}

sub disable {
  my $self = shift;
  my %args = @_;
  my $vo = $args{vo} // $self->{VO} or croak "disable: no VO given";
  return 1 if ! $self->isenabled(vo => $vo);
  return $self->set_vo_param(vo => $vo, param => "enabled", value => "false");
}

# This is a 'private' method

sub _readvo {
  my $self = shift;
  my $vo = shift;
  # read vo configuration only once
  if ( ! defined $self->{VOCONF}->{$vo}) {
    $self->{VOCONF}->{$vo} = $self->{SITECONF}->readconfig("vos/" . $vo . ".conf");
  }
  if ( ! defined $self->{VOCONF}->{$vo}) {
    push @{$self->{ERRMSG}}, $_ foreach $self->{SITECONF}->errmsg();
    push @{$self->{ERRMSG}}, "Cannot read configuration for VO '$vo'.";
    return undef;
  }
  return $self->{VOCONF}->{$vo};
}

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
