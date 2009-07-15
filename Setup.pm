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

=item omp

=item oracdr

=item sybase

=back

=cut

use strict;
use warnings;

my %INC_LOCATIONS = ( 'omp' => '/jac_sw/omp/msbserver',
                      'oracdr' => '/star/bin/oracdr/src/lib/perl5',
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

1;

