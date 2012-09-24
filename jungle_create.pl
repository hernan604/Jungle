#jungle_create.pl
#Descrição: Cria uma aplicação em branco pronta para utilizar o Jungle
#
# ./scripts
# ./Todo
# ./lib/Tutorial/Perl/Arquivo.pm
# ./README
# ./t/001_load.t
# ./Makefile.PL
# ./LICENSE
# ./Changes
# ./MANIFEST
# ./Makefile.old
package Jungle::App::Generator::Main;
use Moose;
use Template;
use File::Slurp;
use File::Path qw/make_path/;

my $config_tt = {
#   INCLUDE_PATH => './tpl',          # or list ref
    INTERPOLATE  => 0,                # expand "$var" in plain text
    POST_CHOMP   => 1,                # cleanup whitespace
    EVAL_PERL    => 0,                # evaluate Perl code blocks
};

has template => (
  isa => 'Template',
  is => 'rw',
  default => sub {
    return Template->new( $config_tt );
  },
);

has config => (
  isa => 'Any',
  is => 'rw',
);

sub render {
  my ( $self, $config ) = @_;
  $self->config( $config );
  $self->create_dir( $self->config->{ path }->{ destino } );
  $self->create_dir( $self->config->{ path }->{ destino } . '/scripts' );
  $self->create_dir( $self->config->{ path }->{ destino } . '/data' );

  $config->{ app_as_directory } = $config->{ name } ;
  $config->{ app_as_directory } =~ s{::}{/}g;
  $self->config->{ app_directory } =
    $self->config->{ path }->{ destino } . '/lib/' . $config->{ app_as_directory };
  $self->create_dir( $self->config->{ path }->{ destino } . '/lib/' . $config->{ app_as_directory } ); #ex /tmp/MyApp/lib/My/App
  $self->config->{ site_directory } =
    $self->config->{ path }->{ destino } . '/lib/' . $config->{ app_as_directory } . '/Site';
  $self->create_dir( $self->config->{ site_directory } );

  $self->config->{ tests_directory } =
    $self->config->{ path }->{ destino } . '/t' ;
  $self->create_dir( $self->config->{ tests_directory } );

  $self->render_data( );
  $self->render_sites( );
  $self->render_mainapp( );

  $self->render_todo( );
  $self->render_readme( );
  $self->render_makefile( );
  $self->render_license( );
  $self->render_changes( );
  $self->render_manifest( );

  $self->config->{ version_file } = 'lib/'.$self->config->{ app_as_directory } . '.pm';


  $self->render_tests( );
}

sub render_data {
  my ( $self, ) = @_;
  $self->render_template( {
    filename_template => \$self->templates->{ data },
    filename_output => 'lib/'.$self->config->{ app_as_directory } . '/Data.pm',
  } );
}

sub render_mainapp {
  my ( $self, ) = @_;
  $self->render_template( {
    filename_template => \$self->templates->{ app_main },
    filename_output => 'lib/'.$self->config->{ app_as_directory } . '.pm',
  } );
}

sub render_sites {
  my ( $self, ) = @_;
  $self->render_template( {
    filename_template => \$self->templates->{ sites },
    filename_output => 'lib/'.$self->config->{ app_as_directory } . '/Site/SomeSite.pm',
  } );
}

sub render_tests {
  my ( $self, ) = @_;
  $self->render_template( {
    filename_template => \$self->templates->{ test_001 },
    filename_output => 't/001_load.t',
  } );
}

sub render_manifest {
  my ( $self, ) = @_;
  $self->render_template( {
    filename_template => \$self->templates->{ manifest },
    filename_output => 'MANIFEST',
  } );
}

sub render_changes {
  my ( $self, ) = @_;
  $self->render_template( {
    filename_template => \$self->templates->{ changes },
    filename_output => 'Changes',
  } );
}

sub render_license {
  my ( $self, ) = @_;
  $self->render_template( {
    filename_template => \$self->templates->{ license },
    filename_output => 'LICENSE',
  } );
}

sub render_makefile {
  my ( $self, ) = @_;
  $self->render_template( {
    filename_template => \$self->templates->{ makefile },
    filename_output => 'Makefile.PL',
  } );
}

sub render_readme {
  my ( $self, ) = @_;
  $self->render_template( {
    filename_template => \$self->templates->{ readme },
    filename_output => 'README',
  } );
}

sub render_todo {
  my ( $self, ) = @_;
  $self->render_template( {
    filename_template => \$self->templates->{ todo },
    filename_output => 'Todo',
  } );
}

sub create_dir {
  my ( $self, $dir ) = @_;
  if ( ! -e $dir ) {
    make_path( $dir );
  } else {
    warn " Diretório existente:  " . $dir  ;
  }
}

sub save_template {
  my ( $self, $file, $content ) = @_;
  my $file_path_destiny =
    join( "/", $self->config->{ path }->{ destino } , $file );
  if ( ! -e $file_path_destiny ) {
    write_file( $file_path_destiny , $content );
  }
}

sub tpl_render {
  my ( $self, $args ) = @_;
  $self->template->process(
    $args->{ input },
    $args->{ config },
    $args->{ output } )
    || die $self->template->error();
  return $args;
}

sub render_template {
  my ( $self, $args ) = @_;
  my $output;
  $self->tpl_render( {
    input => $args->{ filename_template },
    config => $self->config,
    output => \$output,
  } );
  $self->save_template( $args->{ filename_output }, $output );
}

sub templates {
  my ( $self, ) = @_;
  return {
    sites => <<TPL
package [% name %]::Site::SomeSite;
use Moose;
with qw(Jungle::Spider);

=head2 SYNOPSIS

This example shows how you can create a quick crawler with perl and Jungle

=head2 DESCRIPTION

See how quick and easy you can create a crawler with perl and Jungle.
This example works in conjunction with lib/Example/BBC/Crawler/Data.pm. This Data module is responsible to save your data.
So that means, on this file is the cralwer stuff. And on Data, is the saving layer of your app. So you crawl here and send to ::Data for saving.

=cut

has startpage => (
    is => 'rw',
    isa => 'Str',
    default => 'http://www.bbc.co.uk',
);

has total_links_visited => (
    is => 'rw',
    isa => 'Int',
    default => 0,
);

sub on_start {
    my ( \$self ) = \@_;
    \$self->append( search => \$self->startpage );
}

sub search {
    my ( \$self ) = \@_;
    warn \$self->tree->findvalue( '//h1' );
    my \$news_tag_a = \$self->tree->findnodes( '//div[\@class="detalhes"]/h1/a' );
    foreach my \$item ( \$news_tag_a->get_nodelist ) {
         my \$url = \$item->attr( 'href' );
         \$self->prepend( detail => \$url )
            if ( \$url =~ m{^http://www.bbc.co.uk}g
                and \$self->total_links_visited( \$self->total_links_visited( ) + 1 ) < 20
            ); #  append url on end of list
    }
}

sub on_link {
    my ( \$self, \$url ) = \@_;
    if ( \$url =~ m{^http://www.bbc.co.uk}ig and \$self->total_links_visited( \$self->total_links_visited( ) + 1 ) < 20 ) {
         \$self->prepend( search => \$url ); #  append url on end of list
    }
}

sub detail {
    my ( \$self ) = \@_;
    warn \$self->tree->findvalue( '//h1' );
#   \$self->data->author( \$self->tree->findvalue( '//div[\@class="bb-md-noticia-autor"]' ) );
#   \$self->data->webpage( \$self->current_page );
#   \$self->data->content( \$content );
#   \$self->data->title( \$self->tree->findvalue( '//title' ) );
#   \$self->data->meta_keywords( \$self->tree->findvalue( '//meta[\@name="keywords"]/\@content' ) );
#   \$self->data->meta_description( \$self->tree->findvalue( '//meta[\@name="description"]/\@content' ) );
#   \$self->data->save;
    ##
    ## See Example::BBC::Crawler::Data.pm for more info on $self->data;
    ## Its an object you construct for your crawler... and you pass info to it and save it somehow.
    ## I have given an example using CSV There.. but it can be anything
    ##
}

1;
TPL
,
    data => <<TPL
package [% name %]::Data;
use Moose;
use Text::CSV_XS;
use DateTime;
use Digest::SHA1 qw(sha1_hex);
use HTML::Entities;

has filename_csv => (
    is      => 'rw',
    isa     => 'Str',
    default => sub {
        my (\$self) = \@_;
        my \$today = DateTime->now( time_zone => 'local' );
        #defines a name for our csv.
        my \$filename = \$today->dmy('-').'_' . \$today->hms( '-' ) . '.csv';
        \$self->filename_csv( \$filename );
    },
);

has site_name => (
    is  => 'rw',
    isa => 'Str',
    default => '',
);

after 'site_name' => sub {
    my ( \$self, \$value, \$skip_verify ) = \@_;
    return if ! \$value;
    if ( ! \$skip_verify ) {
        \$value =~ s{::}{-}g;
        \$self->site_name( \$value, 1 );
    }
} ;

has [ qw/title author content webpage meta_keywords meta_description/ ] => (
    is  => 'rw',
    isa => 'Any',
);

has images => (
    is => 'rw',
    isa => 'ArrayRef',
    default => sub { return []; } ,
);
has data => (
    is      => 'rw',
    isa     => '[% name %]::Data',
    default => sub {
        my ( \$self ) = \@_;
        return \$self;
    },
);

has csv => (
    is => 'ro',
    isa => 'Text::CSV_XS',
    default => sub {
        my \$csv = Text::CSV_XS->new()
          or die "Cannot use CSV: " . Text::CSV_XS->error_diag();
        \$csv->eol("\r\n");
        return \$csv;
    },
);

sub save {
    my ( \$self ) = \@_;
    my \@rows = (
        [
            sha1_hex( \$self->webpage ),
            \$self->webpage,
            decode_entities( \$self->data->title ),
            decode_entities( \$self->data->author ),
            decode_entities( \$self->data->content ),
            decode_entities( \$self->data->meta_keywords ),
            decode_entities( \$self->data->meta_description ),
            join( '|' , \@{ \$self->images } ),
        ],
    );
    my \$file = './data/NEWS-' . \$self->site_name. '-' . \$self->filename_csv;

    open my \$fh, ">>:encoding(utf8)", "\$file" or die "\$file: \$!";
    \$self->csv->print( \$fh, \$_ ) for \@rows;
    close \$fh or die "Error on file \$file: \$!";
}

1;


=head1 NAME

    [% name %]::Data - Handles the extracted data and saves it

=head1 DESCRIPTION

    [% name %]::Data handles the collected data.

    In this case lib/Sites/XYZ will populate [% name %] which will
    then handle the saving of this data.

=head1 AUTHOR

    [% author.name %]
    [% author.email %]
    [% author.site %]


=head1 COPYRIGHT

    This program is free software; you can redistribute
    it and/or modify it under the same terms as Perl itself.

    The full text of the license can be found in the
    LICENSE file included with this module.


=head1 SEE ALSO

perl(1).

=cut

TPL
,
    app_main => <<TPL
package [% name%];
use Moose;

our \$VERSION = 0.0001;

use Jungle;
use [% name %]::Data;

has spider => (
  is => 'rw',
  isa => 'Jungle',
  default => sub {
    return Jungle->new();
  },
);

# my \$spider = Jungle->new();
# \$spider->work_site( '[% name %]::Site::SomeSite', [% name %]::Data->new );

=head1 NAME

[% name %] - [% abstract %]


=head1 SYNOPSIS

  use [% name %];
  blah blah blah


=head1 DESCRIPTION

Stub documentation for this module was created by Jungle::App::Generator::Main.
It looks like the author of the extension was negligent enough
to leave the stub unedited.

Blah blah blah.

=head1 AUTHOR

    [% author.name %]

    [% author.email %]

    [% author.site %]


=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.


=head1 SEE ALSO

perl(1).

=cut

1;

TPL
,
    todo => <<TPL
TODO list for Perl module [% name %]

- Nothing yet
TPL
,
    readme => <<TPL
pod2text [% name %] > README

If this is still here it means the programmer was too lazy to create the readme file.

You can create it now by using the command shown above from this directory.

At the very least you should be able to use this set of instructions
to install the module...

perl Makefile.PL
make
make test
make install

If you are on a windows box you should use 'nmake' rather than 'make'.
TPL
,
    makefile => <<TPL
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => '[% name %]',
    VERSION_FROM => '[% version_file %]',
    AUTHOR       => '[% author.name %] ([% author.email %])',
    ABSTRACT     => 'Gere e exporte arquivos com template toolkit em perl',
    PREREQ_PM    => {
                     'Test::Simple' => 0.44,
                     'Moose' => 0,
                    },
);
TPL
,
    test_001 => <<TPL
# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 2;

BEGIN { use_ok( '[% name %]' ); }

my \$object = [% name %]->new();
isa_ok (\$object, '[% name %]');

\$object->spider->work_site( '[% name %]::Site::SomeSite',[% name %]::Data->new ) ;


TPL
,
    changes => <<TPL
Revision history for Perl module [% name %]

0.01 Wed Aug 22 13:49:47 2012
    - original version; created by ExtUtils::ModuleMaker 0.51
TPL
,
    manifest => <<TPL
Changes
lib/Jungle.pm
LICENSE
Makefile.PL
MANIFEST
README
t/001_load.t
Todo
TPL
,
    license => <<TPL
Terms of Perl itself

a) the GNU General Public License as published by the Free
   Software Foundation; either version 1, or (at your option) any
   later version, or
b) the "Artistic License"

---------------------------------------------------------------------------

The General Public License (GPL)
Version 2, June 1991

Copyright (C) 1989, 1991 Free Software Foundation, Inc. 675 Mass Ave,
Cambridge, MA 02139, USA. Everyone is permitted to copy and distribute
verbatim copies of this license document, but changing it is not allowed.

Preamble

The licenses for most software are designed to take away your freedom to share
and change it. By contrast, the GNU General Public License is intended to
guarantee your freedom to share and change free software--to make sure the
software is free for all its users. This General Public License applies to most of
the Free Software Foundation's software and to any other program whose
authors commit to using it. (Some other Free Software Foundation software is
covered by the GNU Library General Public License instead.) You can apply it to
your programs, too.

When we speak of free software, we are referring to freedom, not price. Our
General Public Licenses are designed to make sure that you have the freedom
to distribute copies of free software (and charge for this service if you wish), that
you receive source code or can get it if you want it, that you can change the
software or use pieces of it in new free programs; and that you know you can do
these things.

To protect your rights, we need to make restrictions that forbid anyone to deny
you these rights or to ask you to surrender the rights. These restrictions
translate to certain responsibilities for you if you distribute copies of the
software, or if you modify it.

For example, if you distribute copies of such a program, whether gratis or for a
fee, you must give the recipients all the rights that you have. You must make
sure that they, too, receive or can get the source code. And you must show
them these terms so they know their rights.

We protect your rights with two steps: (1) copyright the software, and (2) offer
you this license which gives you legal permission to copy, distribute and/or
modify the software.

Also, for each author's protection and ours, we want to make certain that
everyone understands that there is no warranty for this free software. If the
software is modified by someone else and passed on, we want its recipients to
know that what they have is not the original, so that any problems introduced by
others will not reflect on the original authors' reputations.

Finally, any free program is threatened constantly by software patents. We wish
to avoid the danger that redistributors of a free program will individually obtain
patent licenses, in effect making the program proprietary. To prevent this, we
have made it clear that any patent must be licensed for everyone's free use or
not licensed at all.

The precise terms and conditions for copying, distribution and modification
follow.

GNU GENERAL PUBLIC LICENSE
TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND
MODIFICATION

0. This License applies to any program or other work which contains a notice
placed by the copyright holder saying it may be distributed under the terms of
this General Public License. The "Program", below, refers to any such program
or work, and a "work based on the Program" means either the Program or any
derivative work under copyright law: that is to say, a work containing the
Program or a portion of it, either verbatim or with modifications and/or translated
into another language. (Hereinafter, translation is included without limitation in
the term "modification".) Each licensee is addressed as "you".

Activities other than copying, distribution and modification are not covered by
this License; they are outside its scope. The act of running the Program is not
restricted, and the output from the Program is covered only if its contents
constitute a work based on the Program (independent of having been made by
running the Program). Whether that is true depends on what the Program does.

1. You may copy and distribute verbatim copies of the Program's source code as
you receive it, in any medium, provided that you conspicuously and appropriately
publish on each copy an appropriate copyright notice and disclaimer of warranty;
keep intact all the notices that refer to this License and to the absence of any
warranty; and give any other recipients of the Program a copy of this License
along with the Program.

You may charge a fee for the physical act of transferring a copy, and you may at
your option offer warranty protection in exchange for a fee.

2. You may modify your copy or copies of the Program or any portion of it, thus
forming a work based on the Program, and copy and distribute such
modifications or work under the terms of Section 1 above, provided that you also
meet all of these conditions:

a) You must cause the modified files to carry prominent notices stating that you
changed the files and the date of any change.

b) You must cause any work that you distribute or publish, that in whole or in
part contains or is derived from the Program or any part thereof, to be licensed
as a whole at no charge to all third parties under the terms of this License.

c) If the modified program normally reads commands interactively when run, you
must cause it, when started running for such interactive use in the most ordinary
way, to print or display an announcement including an appropriate copyright
notice and a notice that there is no warranty (or else, saying that you provide a
warranty) and that users may redistribute the program under these conditions,
and telling the user how to view a copy of this License. (Exception: if the
Program itself is interactive but does not normally print such an announcement,
your work based on the Program is not required to print an announcement.)

These requirements apply to the modified work as a whole. If identifiable
sections of that work are not derived from the Program, and can be reasonably
considered independent and separate works in themselves, then this License,
and its terms, do not apply to those sections when you distribute them as
separate works. But when you distribute the same sections as part of a whole
which is a work based on the Program, the distribution of the whole must be on
the terms of this License, whose permissions for other licensees extend to the
entire whole, and thus to each and every part regardless of who wrote it.

Thus, it is not the intent of this section to claim rights or contest your rights to
work written entirely by you; rather, the intent is to exercise the right to control
the distribution of derivative or collective works based on the Program.

In addition, mere aggregation of another work not based on the Program with the
Program (or with a work based on the Program) on a volume of a storage or
distribution medium does not bring the other work under the scope of this
License.

3. You may copy and distribute the Program (or a work based on it, under
Section 2) in object code or executable form under the terms of Sections 1 and 2
above provided that you also do one of the following:

a) Accompany it with the complete corresponding machine-readable source
code, which must be distributed under the terms of Sections 1 and 2 above on a
medium customarily used for software interchange; or,

b) Accompany it with a written offer, valid for at least three years, to give any
third party, for a charge no more than your cost of physically performing source
distribution, a complete machine-readable copy of the corresponding source
code, to be distributed under the terms of Sections 1 and 2 above on a medium
customarily used for software interchange; or,

c) Accompany it with the information you received as to the offer to distribute
corresponding source code. (This alternative is allowed only for noncommercial
distribution and only if you received the program in object code or executable
form with such an offer, in accord with Subsection b above.)

The source code for a work means the preferred form of the work for making
modifications to it. For an executable work, complete source code means all the
source code for all modules it contains, plus any associated interface definition
files, plus the scripts used to control compilation and installation of the
executable. However, as a special exception, the source code distributed need
not include anything that is normally distributed (in either source or binary form)
with the major components (compiler, kernel, and so on) of the operating system
on which the executable runs, unless that component itself accompanies the
executable.

If distribution of executable or object code is made by offering access to copy
from a designated place, then offering equivalent access to copy the source
code from the same place counts as distribution of the source code, even though
third parties are not compelled to copy the source along with the object code.

4. You may not copy, modify, sublicense, or distribute the Program except as
expressly provided under this License. Any attempt otherwise to copy, modify,
sublicense or distribute the Program is void, and will automatically terminate
your rights under this License. However, parties who have received copies, or
rights, from you under this License will not have their licenses terminated so long
as such parties remain in full compliance.

5. You are not required to accept this License, since you have not signed it.
However, nothing else grants you permission to modify or distribute the Program
or its derivative works. These actions are prohibited by law if you do not accept
this License. Therefore, by modifying or distributing the Program (or any work
based on the Program), you indicate your acceptance of this License to do so,
and all its terms and conditions for copying, distributing or modifying the
Program or works based on it.

6. Each time you redistribute the Program (or any work based on the Program),
the recipient automatically receives a license from the original licensor to copy,
distribute or modify the Program subject to these terms and conditions. You
may not impose any further restrictions on the recipients' exercise of the rights
granted herein. You are not responsible for enforcing compliance by third parties
to this License.

7. If, as a consequence of a court judgment or allegation of patent infringement
or for any other reason (not limited to patent issues), conditions are imposed on
you (whether by court order, agreement or otherwise) that contradict the
conditions of this License, they do not excuse you from the conditions of this
License. If you cannot distribute so as to satisfy simultaneously your obligations
under this License and any other pertinent obligations, then as a consequence
you may not distribute the Program at all. For example, if a patent license would
not permit royalty-free redistribution of the Program by all those who receive
copies directly or indirectly through you, then the only way you could satisfy
both it and this License would be to refrain entirely from distribution of the
Program.

If any portion of this section is held invalid or unenforceable under any particular
circumstance, the balance of the section is intended to apply and the section as
a whole is intended to apply in other circumstances.

It is not the purpose of this section to induce you to infringe any patents or other
property right claims or to contest validity of any such claims; this section has
the sole purpose of protecting the integrity of the free software distribution
system, which is implemented by public license practices. Many people have
made generous contributions to the wide range of software distributed through
that system in reliance on consistent application of that system; it is up to the
author/donor to decide if he or she is willing to distribute software through any
other system and a licensee cannot impose that choice.

This section is intended to make thoroughly clear what is believed to be a
consequence of the rest of this License.

8. If the distribution and/or use of the Program is restricted in certain countries
either by patents or by copyrighted interfaces, the original copyright holder who
places the Program under this License may add an explicit geographical
distribution limitation excluding those countries, so that distribution is permitted
only in or among countries not thus excluded. In such case, this License
incorporates the limitation as if written in the body of this License.

9. The Free Software Foundation may publish revised and/or new versions of the
General Public License from time to time. Such new versions will be similar in
spirit to the present version, but may differ in detail to address new problems or
concerns.

Each version is given a distinguishing version number. If the Program specifies a
version number of this License which applies to it and "any later version", you
have the option of following the terms and conditions either of that version or of
any later version published by the Free Software Foundation. If the Program does
not specify a version number of this License, you may choose any version ever
published by the Free Software Foundation.

10. If you wish to incorporate parts of the Program into other free programs
whose distribution conditions are different, write to the author to ask for
permission. For software which is copyrighted by the Free Software Foundation,
write to the Free Software Foundation; we sometimes make exceptions for this.
Our decision will be guided by the two goals of preserving the free status of all
derivatives of our free software and of promoting the sharing and reuse of
software generally.

NO WARRANTY

11. BECAUSE THE PROGRAM IS LICENSED FREE OF CHARGE, THERE IS
NO WARRANTY FOR THE PROGRAM, TO THE EXTENT PERMITTED BY
APPLICABLE LAW. EXCEPT WHEN OTHERWISE STATED IN WRITING THE
COPYRIGHT HOLDERS AND/OR OTHER PARTIES PROVIDE THE PROGRAM
"AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR
IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE
PROGRAM IS WITH YOU. SHOULD THE PROGRAM PROVE DEFECTIVE,
YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR OR
CORRECTION.

12. IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED
TO IN WRITING WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY
WHO MAY MODIFY AND/OR REDISTRIBUTE THE PROGRAM AS
PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES, INCLUDING ANY
GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES
ARISING OUT OF THE USE OR INABILITY TO USE THE PROGRAM
(INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD
PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY
OTHER PROGRAMS), EVEN IF SUCH HOLDER OR OTHER PARTY HAS
BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.

END OF TERMS AND CONDITIONS


---------------------------------------------------------------------------

The Artistic License

Preamble

The intent of this document is to state the conditions under which a Package
may be copied, such that the Copyright Holder maintains some semblance of
artistic control over the development of the package, while giving the users of the
package the right to use and distribute the Package in a more-or-less customary
fashion, plus the right to make reasonable modifications.

Definitions:

-    "Package" refers to the collection of files distributed by the Copyright
     Holder, and derivatives of that collection of files created through textual
     modification.
-    "Standard Version" refers to such a Package if it has not been modified,
     or has been modified in accordance with the wishes of the Copyright
     Holder.
-    "Copyright Holder" is whoever is named in the copyright or copyrights for
     the package.
-    "You" is you, if you're thinking about copying or distributing this Package.
-    "Reasonable copying fee" is whatever you can justify on the basis of
     media cost, duplication charges, time of people involved, and so on. (You
     will not be required to justify it to the Copyright Holder, but only to the
     computing community at large as a market that must bear the fee.)
-    "Freely Available" means that no fee is charged for the item itself, though
     there may be fees involved in handling the item. It also means that
     recipients of the item may redistribute it under the same conditions they
     received it.

1. You may make and give away verbatim copies of the source form of the
Standard Version of this Package without restriction, provided that you duplicate
all of the original copyright notices and associated disclaimers.

2. You may apply bug fixes, portability fixes and other modifications derived from
the Public Domain or from the Copyright Holder. A Package modified in such a
way shall still be considered the Standard Version.

3. You may otherwise modify your copy of this Package in any way, provided
that you insert a prominent notice in each changed file stating how and when
you changed that file, and provided that you do at least ONE of the following:

     a) place your modifications in the Public Domain or otherwise
     make them Freely Available, such as by posting said modifications
     to Usenet or an equivalent medium, or placing the modifications on
     a major archive site such as ftp.uu.net, or by allowing the
     Copyright Holder to include your modifications in the Standard
     Version of the Package.

     b) use the modified Package only within your corporation or
     organization.

     c) rename any non-standard executables so the names do not
     conflict with standard executables, which must also be provided,
     and provide a separate manual page for each non-standard
     executable that clearly documents how it differs from the Standard
     Version.

     d) make other distribution arrangements with the Copyright Holder.

4. You may distribute the programs of this Package in object code or executable
form, provided that you do at least ONE of the following:

     a) distribute a Standard Version of the executables and library
     files, together with instructions (in the manual page or equivalent)
     on where to get the Standard Version.

     b) accompany the distribution with the machine-readable source of
     the Package with your modifications.

     c) accompany any non-standard executables with their
     corresponding Standard Version executables, giving the
     non-standard executables non-standard names, and clearly
     documenting the differences in manual pages (or equivalent),
     together with instructions on where to get the Standard Version.

     d) make other distribution arrangements with the Copyright Holder.

5. You may charge a reasonable copying fee for any distribution of this Package.
You may charge any fee you choose for support of this Package. You may not
charge a fee for this Package itself. However, you may distribute this Package in
aggregate with other (possibly commercial) programs as part of a larger
(possibly commercial) software distribution provided that you do not advertise
this Package as a product of your own.

6. The scripts and library files supplied as input to or produced as output from
the programs of this Package do not automatically fall under the copyright of this
Package, but belong to whomever generated them, and may be sold
commercially, and may be aggregated with this Package.

7. C or perl subroutines supplied by you and linked into this Package shall not
be considered part of this Package.

8. Aggregation of this Package with a commercial distribution is always permitted
provided that the use of this Package is embedded; that is, when no overt attempt
is made to make this Package's interfaces visible to the end user of the
commercial distribution. Such use shall not be construed as a distribution of
this Package.

9. The name of the Copyright Holder may not be used to endorse or promote
products derived from this software without specific prior written permission.

10. THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR
PURPOSE.

The End


TPL
,
  };
}

1;

package Jungle::App::Generator;
use Moose;
extends qw/Jungle::App::Generator::Main/;

my $config_app = {
  path => {
    destino => '/tmp/tpl',
  },
  name => 'Example::BBC::Crawler',
  abstract => 'Create quick crawlers with perl',
  description => 'Use this module and create quick skeleton of web site spider with perl.',
  author => {
    name => 'Hernan Lopes',
    email => 'hernanlopes@gmail.com',
    site => 'http://github.com/hernan604',
  },
};

my $campeonato = Jungle::App::Generator->new();
$campeonato->render( $config_app );

1;
