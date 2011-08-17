package Sites::Terra;
use Moose;
with qw/Jungle::Spider/;
with qw/Jungle::Data::News/;

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
            $self->prepend( details_invertia => $url ); #  append url on end of list
        } else {
            $self->prepend( details => $url ); #  append url on end of list
        }
    }
}

sub on_link {
    my ( $self, $url ) = @_;
#   if ( $url =~ m{http://noticias.uol.com.br/ultimas-noticias/index(1|2).jhtm}ig ) {
#        $self->prepend( search => $url ); #  append url on end of list
#   }
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
    if ( defined $content and defined $author and defined $page_title ) {
        my $news_item = {
            page_title => $page_title,
            author    => $author,
            content   => $content,
        };
        use Data::Dumper;
        warn Dumper $news_item;
        $self->data->author( $author );
        $self->data->content( $content );
        $self->data->title( $page_title );

        $self->data->save;
    }
}


sub details {
    my ( $self ) = @_; 
    my $page_title = $self->tree->findvalue( '//title' );
    my $author_nodes = $self->tree->findnodes( '//dl/dd' );
    my $author  = '';
    foreach my $node ( $author_nodes->get_nodelist ) {
        $author .= $node->as_text . "\n";
    }
    my $content_nodes = $self->tree->findnodes( '//div[@id="SearchKey_Text1"]//p' );
    my $content;
    foreach my $node ( $content_nodes->get_nodelist ) {
        $content .= $node->as_text."\n";
    }
    if ( defined $content and defined $author and defined $page_title ) {
        my $news_item = {
            page_title => $page_title,
            author    => $author,
            content   => $content,
        };
        use Data::Dumper;
        warn Dumper $news_item;
        $self->data->author( $author );
        $self->data->content( $content );
        $self->data->title( $page_title );

        $self->data->save;
    }
}

1;
