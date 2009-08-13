package JAC::Setup;

=head1 NAME

JAC::Setup - Set up @INC, environment variables, etc., for use at JAC.

=head1 SYNOPSIS

  use JAC::Setup qw/ omp oracdr /;

=head1 DESCRIPTION

This module configures the Perl include path (@INC global) to include
the standard installation locations of JAC Perl modules. It also sets
environment variables depending on which system is requested.

There are no functions or methods at this time.

Available symbols are:

=over 4

=item * omp

Add the standard OMP location.

=item * oracdr

Add the standard ORAC-DR library location.

=item * sybase

Set the Sybase environment variable to an appropriate value.

=item * drama

Add ITS DRAMA search path

=item * its

Add ITS search paths.

=back

=cut

use strict;
use warnings;

our $VERSION = '0.01';

my %INC_LOCATIONS = ( 'omp' => '/jac_sw/omp/msbserver',
                      'oracdr' => '/star/bin/oracdr/src/lib/perl5',
                      'its' => '/jac_sw/itsroot/install/common/lib/site_perl',
                      'drama' => '/jac_sw/drama/CurrentRelease/lib/site_perl',
                    );
my %ENVIRONMENT = ( 'omp' => { 'OMP_CFG_DIR' => '/jac_sw/omp/msbserver/cfg' },
                    'sybase' => { 'SYBASE' => '/local/progs/sybase' },
                  );

sub import {
  my $class = shift;
  my @imports = @_;

  foreach my $import ( @imports ) {
    if( exists $INC_LOCATIONS{$import} ) {
      eval "use lib '$INC_LOCATIONS{$import}';";
    }
    if( exists $ENVIRONMENT{$import} ) {
      foreach my $key ( keys %{$ENVIRONMENT{$import}} ) {
        if( ! exists( $ENV{$key} ) ) {
          $ENV{$key} = $ENVIRONMENT{$import}{$key};
        }
      }
    }
  }
}

=head1 AUTHORS

Brad Cavanagh E<lt>b.cavanagh@jach.hawaii.eduE<gt>,
Tim Jenness E<lt>t.jenness@jach.hawaii.eduE<gt>.

=head1 COPYRIGHT

Copyright (C) 2009 Science and Technology Facilities Council.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License as
published by the Free Software Foundation; either version 3 of
the License, or (at your option) any later version.

This program is distributed in the hope that it will be
useful, but WITHOUT ANY WARRANTY; without even the implied
warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public
License along with this program; if not, write to the Free
Software Foundation, Inc., 59 Temple Place, Suite 330, Boston,
MA 02111-1307, USA

=cut

1;

