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

Site::Configuration::VO - Access site-local VO configuration data

=head1 VERSION

Version 0.02

=cut

our $VERSION = '0.02';

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Site::Configuration::VO;

    my $foo = Site::Configuration::VO->new();
    ...

=head1 SUBROUTINES/METHODS

=head2 new

Constructor for a new object.

=cut

sub new {
  my $class = shift;
  my $self = { SITECONFIG => Site::Configuration->new("/etc/vo-support"),
	       VOCONF => {}
	     };
  bless ($self, $class);
  return $self;
}

=head2 confdir

=cut

sub confdir {
  my $self = shift;
  return $self->{SITECONFIG}->confdir(@_); # transparent?
}

=head2 get_vo_param

$voconf->get_vo_param("VO", "param", [ "fqan" ])

=cut

sub get_vo_param {
  my $self = shift;
  my ($vo, $param, $fqan) = @_;
  # check if we already have the VO
  if ( defined $self->{VOCONF}->{$vo}) { }
  else {
    # use the siteconfig to read the VO if not
  }
  # look up the parameter
  my $val = $self->{VOCONF}->{$vo}->{$fqan}{$param};
  return $val;
}

=head1 AUTHOR

Dennis van Dok, C<< <dennisvd at nikhef.nl> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-site-configuration at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Site-Configuration>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Site::Configuration::VO


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Site-Configuration>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Site-Configuration>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Site-Configuration>

=item * Search CPAN

L<http://search.cpan.org/dist/Site-Configuration/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2012 Dennis van Dok.

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
