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
use Config::IniFiles;

=head1 NAME

Site::Configuration - Access site-local configuration data

=head1 VERSION

Version 0.03

=cut

our $VERSION = "0.03";


sub new {
  my $class = shift;
  my $self = { CONFDIR => "/etc/siteinfo",
	       CONFSET => {},
	       ERRMSG => []
	     };

  if (@_) { $self->{CONFDIR} = shift }
  bless ($self, $class);
  return $self;
}


=head1 SYNOPSIS

    use Site::Configuration;
    my $siteconf = Site::Configuration->new();
    my $ce = $siteconf->readconfig("ce.conf");
    my $node = $ce->{CE};
    my $queues = $ce->{$node}{queues};

=head1 DESCRIPTION

The Site::Configuration module offers an interface into the local
configuration data stored in Ini files. There is currently no
enforcement of the structure of any of the configuration files other
than a few basic formatting rules, so essentially it is now little
more than a thin shell around L<Config::IniFiles>.

The constructor accepts one optional argument, the name of a
configuration directory to use. The default value is
C</etc/site-info/>.

    my $siteconfig = Site::Configuration->new("/etc/alt-site");

The configuration directory may be read and set using the confdir() method:

    my $oldconfdir = $siteconfig->confdir();
    $siteconfig->confdir("/etc/another-site");

Reading a configuration file is triggered by the readconfig() method.

    my $ceconf = $siteconfig->readconfig("ce.conf");

The name that is passed should be the file name relative to the configuration
directory. The returned value is a reference to a tied hash.

Changing the configuration directory only affects reading new
configuration files; it does not cause existing files to be closed or
re-read. Site::Configuration keeps internal links to all the opened files
by their relative name.

=head2 Error handling

If an error occurs, the method readconfig() returns undef and the error
messages are stored in an internal array, which can be retrieved with $obj->errmsg().
Calling this method will clear the error, so be sure to store the values. Calling
readconfig() multiple times without clearing the error messages will cause them
to accumulate.

    if (!defined $ceconf) {
        print STDERR "$_\n" foreach $siteconfig->errmsg();
    }

=cut

# getter/setter
sub confdir {
  my $self = shift;
  if (@_) { $self->{CONFDIR} = shift }
  return $self->{CONFDIR};
}

# return and clear
sub errmsg {
  my $self = shift;
  my @ret = @{$self->{ERRMSG}};
  $self->{ERRMSG} = [];
  return @ret;
}

sub readconfig {
  my $self = shift;
  my $conf = shift;

  return $self->{CONFSET}->{$conf} if defined $self->{CONFSET}->{$conf};

  # 
  my $confdir = $self->{CONFDIR};
  # Sanity: does the configuration file exist?
  -f "$confdir/$conf" or do {
    push @{$self->{ERRMSG}}, sprintf "Missing configuration file %s.\n", "$confdir/$conf";
    return undef };

  tie my %ini, 'Config::IniFiles',
    ( -file => "$confdir/$conf", 
      -fallback => "DEFAULT",
      -handle_trailing_comment => 1,
      -allowcontinue => 1,
      -nocase => 1) or
	do {
	  push $self->{ERRMSG}, "There was an error reading configuration file $confdir/$conf:";
	  push $self->{ERRMSG}, $_ foreach @Config::IniFiles::errors;
	  return undef;
	};
  $self->{CONFSET}->{$conf} = \%ini;
  return \%ini;
};

=head1 SEE ALSO

L<Config::IniFiles>

=head1 AUTHOR

Dennis van Dok <dennisvd at nikhef.nl>

Please report any bugs or feature requests to C<grid-mw-security-support at nikhef.nl>.

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

1; # End of Site::Configuration
