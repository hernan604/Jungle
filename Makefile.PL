

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'Jungle',
    VERSION_FROM => 'lib/Jungle.pm', # finds \$VERSION
    AUTHOR       => 'Hernan Lopes (hernanlopes@gmail.com)',
    ABSTRACT     => 'Jungle is a web spider framework to speed up crawler developments',
    PREREQ_PM    => {
                     'Test::Simple' => 0.44,
                    },
);
