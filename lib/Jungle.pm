package Jungle;
use Moose;

sub work_site {
    my ( $self, $site, $data_class ) = @_; 
    my $module = "$site";
    Class::MOP::load_class($module);
    my $spider = $module->new;
    $spider->do_work( $site, $data_class );
}

our $VERSION = '0.02';

=head1 NAME

  Jungle - Jungle is a web spider framework to speed up crawler developments

=head1 SYNOPSIS

  # Frist: create your spider scripts and add them to: lib/Sites/...
  # and then:
  # Run tests to have an idea and check out t/001_load.t

  use Jungle;
  my $spider = Jungle->new();
  $spider->work_site( 'NewsSpider::Terra', Jungle::Data::News->new ); #Tests TERRA WEB SITE which is ISO-8859-1
  $spider->work_site( 'NewsSpider::UOL' , Jungle::Data::News->new ); #Tests UOL WEB SITE which is UTF8
  $spider->work_site( 'NewsSpider::Estadao', Jungle::Data::News->new ); #Tests Estadao WEB SITE which is UTF8

=head1 SAMPLE1: Spider News for terra.com.br

    package Sites::NewsSpider::Terra; #has charset iso-8859-1
    use Moose;
    with qw/Jungle::Spider/;

    has startpage => (
        is => 'rw',
        isa => 'Str',
        default => 'http://noticias.terra.com.br/ultimasnoticias/0,,EI188,00.html',
    );

    sub on_start { 
        my ( $self ) = @_; 
    }

    sub search {
        my ( $self ) = @_; 
        my $news = $self->tree->findnodes( '//div[@class="list articles"]/ol/li/a' );
        foreach my $item ( $news->get_nodelist ) {
            my $url = $item->attr( 'href' );
            if ( $url =~ m{br\.invertia\.com}ig ) {
                $self->prepend( details_invertia => $url ); 
            } else {
                $self->prepend( details => $url ); 
            }
        }
    }

    sub on_link {
        my ( $self, $url ) = @_;
        if ( $url =~ m{http://noticias.terra.com.br/ultimasnoticias/0,,EI188-PI(1|2|3|4|5|6),00.html}ig ) {
             $self->prepend( search => $url ); #  append url on end of list
        }
    }


    sub details_invertia {
        my ( $self ) = @_; 
        my $page_title = $self->tree->findvalue( '//title' );
        my $author_nodes = $self->tree->findnodes( '//dl/dd' );
        my $author  = '';
        foreach my $node ( $author_nodes->get_nodelist ) {
            $author .= $node->as_text . "\n";
        }
        my $content_nodes = $self->tree->findnodes( '//div[@id="SearchKey_Text1"]' );
        my $content;
        foreach my $node ( $content_nodes->get_nodelist ) {
            $content .= $node->as_HTML;
        }
        $self->data->author( $author );
        $self->data->content( $content );
        $self->data->title( $page_title );
        $self->data->webpage( $self->current_page );
        $self->grab_meta;
        $self->grab_images;

        $self->data->save;
    }

    sub grab_images {
        my ( $self ) = @_; 
        my $images_nodes = $self->tree->findnodes( '//div[contains(@class,"img-article")]/img' );
        my @images = ();
        foreach my $im ( $images_nodes->get_nodelist ) {
            push ( @images, $self->normalize_url( $im->attr( 'src' ) ) );
        }
        $self->data->images( \@images );
    }


    sub details {
        my ( $self ) = @_; 
        my $author_nodes = $self->tree->findnodes( '//dl/dd' );
        my $author  = '';
        foreach my $node ( $author_nodes->get_nodelist ) {
            $author .= $node->as_text . "\n";
        }
        my $content_nodes = $self->tree->findnodes( '//div[@id="SearchKey_Text1"]//p' );
        my $content = '';
        foreach my $node ( $content_nodes->get_nodelist ) {
            $content .= $node->as_text."\n";
        }
        $self->data->author( $author );
        $self->data->content( $content );
        $self->data->title( $self->tree->findvalue( '//title' ) );
        $self->data->webpage( $self->current_page );
        $self->grab_meta;
        $self->grab_images;

        $self->data->save;
    }

    sub grab_meta {
        my ( $self ) = @_; 
        $self->data->meta_keywords( $self->tree->findvalue( '//meta[@name="keywords"]/@content' ) );
        $self->data->meta_description( $self->tree->findvalue( '//meta[@name="description"]/@content' ) );
    }

    1;

=head1 SAMPLE2: Spider News for uol.com.br

    package Sites::NewsSpider::UOL; #has charset UTF8
    use Moose;
    with qw/Jungle::Spider/;

    has startpage => (
        is => 'rw',
        isa => 'Str',
        default => 'http://noticias.uol.com.br/ultimas-noticias/',
    );

    sub on_start {
        my ( $self ) = @_; 
        $self->append( search => $self->startpage , [ #POST EXAMPLE, use [ params => 'something' ] 
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
             if ( $url =~ m{^http://www1.folha.uol.com.br}i ) {
                 $self->prepend( details_folha => $url ); #  append url on end of list
             } else {
                 $self->prepend( details => $url ); #  append url on end of list
             }
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
        my $content_nodes = $self->tree->findnodes( '//div[@id="texto"]/p' );
        my $content = '';
        foreach my $node ( $content_nodes->get_nodelist ) {
            $content .= $node->as_text."\n";
        }
        $self->data->author( $self->tree->findvalue( '//span[@class="autor"]' ) );
        $self->data->webpage( $self->current_page );
        $self->data->content( $content );
        $self->data->title( $self->tree->findvalue( '//div[@id="materia"]//h1' ) );
        $self->grab_meta;

        $self->data->save;
    }

    sub details_folha {
        my ( $self ) = @_; 
        my $content_nodes = $self->tree->findnodes( '//div[@id="articleNew"]/p' );
        my $content = '';
        foreach my $node ( $content_nodes->get_nodelist ) {
            $content .= $node->as_text."\n";
        }
        $self->data->author( $self->tree->findvalue( '//div[@id="articleBy"]/p' ) );
        $self->data->webpage( $self->current_page );
        $self->data->content( $content );
        $self->data->title( $self->tree->findvalue( '//div[@id="articleNew"]/h1' ) );
        $self->grab_meta;

        $self->data->save;
    }

    sub grab_meta {
        my ( $self ) = @_; 
        $self->data->meta_keywords( $self->tree->findvalue( '//meta[@name="keywords"]/@content' ) );
        $self->data->meta_description( $self->tree->findvalue( '//meta[@name="description"]/@content' ) );
    }

    1;

=head1 SAMPLE3: Spider News for estadao.com.br

    package Sites::NewsSpider::Estadao; #is UTF-8 charset
    use Moose;
    with qw(Jungle::Spider);

    has startpage => (
        is => 'rw',
        isa => 'Str',
        default => 'http://www.estadao.com.br/ultimas/',
    );

    sub on_start { 
        my ( $self ) = @_; 
        $self->append( search => $self->startpage );
    }

    sub search {
        my ( $self ) = @_; 
        my $news = $self->tree->findnodes( '//ul/li/h2/a' );
        foreach my $item ( $news->get_nodelist ) {
             my $url = $item->attr( 'href' );
             $self->prepend( detail_noticia => $url ); #  append url on end of list
        }
    }

    sub on_link {
        my ( $self, $url ) = @_;
        if ( $url =~ m{pagina\.php\?i=(1|2)$}ig ) {
             $self->prepend( search => $url ); #  append url on end of list
        }
    }

    sub detail_noticia {
        my ( $self ) = @_; 
        my $content_nodes = $self->tree->findnodes( '//div[@class="texto-noticia"]//div[@class="corpo"]//p' );
        my $content = '';
        foreach my $node ( $content_nodes->get_nodelist ) {
            $content .= $node->as_text. "\n";
        }
        $self->data->author( $self->tree->findvalue( '//div[@class="bb-md-noticia-autor"]' ) );
        $self->data->webpage( $self->current_page );
        $self->data->content( $content );
        $self->data->title( $self->tree->findvalue( '//title' ) );
        $self->data->meta_keywords( $self->tree->findvalue( '//meta[@name="keywords"]/@content' ) );
        $self->data->meta_description( $self->tree->findvalue( '//meta[@name="description"]/@content' ) );
        $self->data->save;
    }

    1;


=head1 RESULTS OF EXTRACTED DATA

    The extracted data should be avaliable under ./data/* as .csv files
    <L|Jungle::Data::News> handles this process for our news websites
    The Data class could write directly on the website db (using DBIx::Class) 
    or it could generate something else than csv. Just modify and pass the
    class to Jungle.

    As of now, the extracted data will be saved under ./data/file-site.csv
    If you wish to change this behaviour, modify lib/Jungle/Data/News.pm or
    create your own classes

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

