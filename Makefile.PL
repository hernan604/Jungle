

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
                    'Moose' => 0,
                    'Data::Dumper' => 0,
                    'Moose::Role' => 0,
                    'Encode::Guess' => 0,
                    'Encode' => 0,
                    'URI' => 0,
                    'WWW::Mechanize' => 0,
                    'LWP::UserAgent' => 0,
                    'HTTP::Request::Common' => 0,
                    'Text::CSV_XS' => 0,
                    'DateTime' => 0,
                    'Digest::SHA1' => 0,
                    'HTML::Entities' => 0,
                    'HTML::TreeBuilder::XPath' => 0,
                    'XML::XPath' => 0,
                    'Mozilla::CA' => 0,
                    'IO::Socket::SSL' => 0,
                    },
);
