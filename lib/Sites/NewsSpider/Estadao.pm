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
