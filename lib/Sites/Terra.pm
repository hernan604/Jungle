package Sites::Terra; #has charset iso-8859-1
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
        $self->data->author( $author );
        $self->data->content( $content );
        $self->data->title( $page_title );
        $self->data->webpage( $self->current_page );

        $self->data->save;
    }
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

    $self->data->save;
}

1;
