package Sites::UOL; #has charset UTF8
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
