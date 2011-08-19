package Sites::UOL; #has charset UTF8
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

    $self->data->save;
}

1;
