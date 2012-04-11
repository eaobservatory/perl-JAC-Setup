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

Add the standard OMP location. Can be over-ridden by setting the
OMP_DIR envrionment variable. The OMP_CFG_DIR environment variable
is also set if not already specified.

=item * oracdr

Add the standard ORAC-DR library location. Can be over-ridden by setting
the ORAC_PERL5LIB environment variable.

=item * sybase

Set the SYBASE environment variable to an appropriate value if not already
set.

=item * drama

Add ITS DRAMA search path

=item * its

Add ITS search paths.

=item * archiving

Adds the JAC archiving tree

=item * jsa

Sets alternative lib path for JSA::* modules.

=item * star-dynlib

Prepends dynamic library paths for /star libraries in LD_LIBRARY_PATH
environment variable.

=item * sybase-dynlib

Appends dynamic library paths for Sybase libraries in LD_LIBRARY_PATH
environment variable.

=back

=cut

use strict;
use warnings;
use warnings::register;
use File::Spec;

our $DEBUG = 0;
our $VERSION = '0.03';

my %DEFAULT_INC_LOCATIONS = (
                             'oracdr' => '/star/bin/oracdr/src/lib/perl5',
                             'omp' => '/jac_sw/omp/msbserver',
                            );

my %INC_LOCATIONS = ( 'omp' => \&override_omp_inc,
                      'oracdr' => \&override_oracdr_inc,
                      'its' => '/jac_sw/itsroot/install/common/lib/site_perl',
                      'drama' => '/jac_sw/drama/CurrentRelease/lib/site_perl',
                      'archiving' => '/jac_sw/archiving/perlmods/JCMT-DataVerify/lib',
                      'jsa' => '/jac_sw/hlsroot/perl-JSA/lib',
                    );

my @DYNLIB_STAR =
  ( '/star/lib',
  );
my @DYNLIB_SYB =
  ( '/local/progs/sybase/lib',
  );

my %ENVIRONMENT = ( 'omp' => { 'OMP_CFG_DIR' => \&override_omp_env },
                    'sybase' => { 'SYBASE' => '/local/progs/sybase' },
                  );

my %ADD_ENVIRONMENT = ( 'star-dynlib'   =>
                          { 'LD_LIBRARY_PATH' =>
                              sub { add_ld_lib_path( \@DYNLIB_STAR ) }
                          },
                        'sybase-dynlib' =>
                          { 'LD_LIBRARY_PATH' =>
                              sub { add_ld_lib_path( undef, @DYNLIB_SYB ) }
                          },
                      );

sub import {
  my $class = shift;
  my @imports = @_;

  foreach my $import ( @imports ) {
    my $found = 0;
    if( exists $INC_LOCATIONS{$import} ) {
      $found = 1;
      # check for environment variable
      my $dir = $INC_LOCATIONS{$import};
      $dir = $dir->() if ref($dir);
      print STDERR "Setting up $import to be: $dir\n" if $DEBUG;
      eval "use lib '$dir';";
    }
    if( exists $ENVIRONMENT{$import} ) {
      $found = 1;
      foreach my $key ( keys %{$ENVIRONMENT{$import}} ) {
        if( ! exists( $ENV{$key} ) ) { # only continue if not set explicitly
          my $dir = $ENVIRONMENT{$import}{$key};
          $dir = $dir->() if ref($dir);
          print STDERR "Setting up $import env var to be: $dir\n" if $DEBUG;
          $ENV{$key} = $dir;
        }
      }
    }

    if( exists $ADD_ENVIRONMENT{$import} ) {
      $found = 1;
      foreach my $key ( keys %{$ADD_ENVIRONMENT{$import}} ) {
        my $dir = $ADD_ENVIRONMENT{$import}{$key};
        $dir = $dir->() if ref($dir);
        print STDERR "Adding $import env var to be: $dir\n" if $DEBUG;
        $ENV{$key} = $dir;
      }
    }

    if (!$found) {
      warnings::warnif( "Unrecognized key '$import' for JAC::Setup" );
    }
  }
}

# Override subroutines for subsystems that can be configured
# based on the environment.

sub override_oracdr_inc {
  if (exists $ENV{ORAC_PERL5LIB}) {
    return $ENV{ORAC_PERL5LIB};
  } elsif (exists $ENV{ORAC_DIR}) {
    return File::Spec->catdir($ENV{ORAC_DIR}, "lib", "perl5");
  } else {
    return $DEFAULT_INC_LOCATIONS{oracdr};
  }
}

sub override_omp_inc {
  if (exists $ENV{OMP_DIR}) {
    return $ENV{OMP_DIR};
  } else {
    return $DEFAULT_INC_LOCATIONS{omp};
  }
}

# Called if the environment variable has not been set
sub override_omp_env {
  my $omp_dir = override_omp_inc();
  return File::Spec->catdir( $omp_dir, "cfg" );
}


# Add dynamic library paths, before and/or after the any of existing ones,
sub add_ld_lib_path {

  my ( $prefix, @suffix ) = @_;

  my @prefix = ( $prefix && ref $prefix ? @{ $prefix } : () );

  my %seen;
  return
    join ':',
      grep !$seen{ $_ }++,
        @prefix,
        split( ':', $ENV{'LD_LIBRARY_PATH'} ),
        @suffix;
}

=head1 AUTHORS

Anubhav Agarwal E<lt>a.agarwal@jach.hawaii.eduE<gt>,
Brad Cavanagh E<lt>b.cavanagh@jach.hawaii.eduE<gt>,
Tim Jenness E<lt>t.jenness@jach.hawaii.eduE<gt>.

=head1 COPYRIGHT

Copyright (C) 2009-2010, 2012 Science and Technology Facilities Council.

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

