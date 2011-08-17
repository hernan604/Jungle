package Jungle;
use Moose;

sub work_site {
    my ( $self, $site ) = @_;
    warn "WORKING SITE , $site";
    my $module = "Sites::$site";
    Class::MOP::load_class($module);
    my $spider = $module->new;
    $spider->site_name( $site );
    $spider->do_work;
}

our $VERSION = '0.01';

=head1 NAME

  Jungle - Jungle is a web spider framework to speed up crawler developments

=head1 SYNOPSIS

  use Jungle;
  my $spider = Jungle->new();
  $spider->work_site( 'UOL' ); ### Starts crawling UOL SITE

=head1 WEBSITE SCRIPT SAMPLE

  vim lib/Sites/UOL.pm #will read all the news from this site.

  package Sites::UOL;
  use Moose;
  with qw/Jungle::Spider/;
  with qw/Jungle::Data::News/;

  has startpage => (
      is => 'rw',
      isa => 'Str',
      default => 'http://noticias.uol.com.br/ultimas-noticias/',
  );

  sub on_start { 
      my ( $self ) = @_; 
      $self->append( search => $self->startpage , [
          some => 'params',
          test => 'POST',
      ] );
      #$self->append( search => $self->startpage );
  }

  sub search {
      my ( $self ) = @_; 
      my $news = $self->tree->findnodes( '//ul[@id="ultnot-list-noticias"]/li/h3/a' );
      foreach my $item ( $news->get_nodelist ) {
           my $url = $item->attr( 'href' );
           $self->prepend( details => $url ); #  append url on end of list
      }
  }

  sub on_link {
      my ( $self, $url ) = @_;
      if ( $url =~ m{http://noticias.uol.com.br/ultimas-noticias/index(1|2).jhtm}ig ) {
           $self->prepend( search => $url ); #  append url on end of list
      }
  }

  sub details {
      my ( $self ) = @_; 
      my $page_title = $self->tree->findvalue( '//div[@id="materia"]//h1' );
      my $author = $self->tree->findvalue( '//span[@class="autor"]' );
      my $content_nodes = $self->tree->findnodes( '//div[@id="materia"]/div[@id="texto"]' );
      my $content;
      foreach my $node ( $content_nodes->get_nodelist ) {
          $content = $node;
      }
      if ( defined $content and defined $author and defined $page_title ) {
          my $news_item = {
              page_title => $page_title,
              author    => $author,
              content   => $content->as_HTML,
          };
          $self->data->author( $author );
          $self->data->content( $content->as_HTML );
          $self->data->title( $page_title );

          $self->data->save;
      }
  }

  1;


=head1 DESCRIPTION

    Take this as a webspider framework example.

=head1 AUTHOR

    Hernan Lopes
    CPAN ID: HERNAN
    Hernan
    hernanlopes@gmail.com
    http://github.com/hernan

=head1 COPYRIGHT

    This program is free software; you can redistribute
    it and/or modify it under the same terms as Perl itself.

    The full text of the license can be found in the
    LICENSE file included with this module.


=head1 SEE ALSO

perl(1).

=cut

1;

# The preceding line will help the module return a true value

