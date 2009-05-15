use ExtUtils::MakeMaker;

WriteMakefile(
              'NAME'      => 'JAC::Setup',
              'VERSION_FROM'   => 'Setup.pm',
              'dist'      => { COMPRESS => "gzip -9f"},
              ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
               (ABSTRACT_FROM => 'Setup.pm',
                AUTHOR     => 'Brad Cavanagh <b.cavanagh@jach.hawaii.edu>') : ()),
             );
