package Sites::NewsSpider::TerraPOST; 
use Moose;
with qw/Jungle::Spider/;

#TEST for POST requests on site TERRA.com.r

has startpage => (
    is => 'rw',
    isa => 'Str',
    default => 'http://www.terra.com.br/portal/',
);

sub on_start { 
    my ( $self ) = @_; 
    $self->append( 
        search => 'http://buscador.terra.com.br/default.aspx?source=Search', { 
        query_params => [ 
            'ca'=>'s',
            'query'=>'formula 1',
            ] 
        }
    );
}

sub search {
    my ( $self ) = @_; 
    my $results = $self->tree->findnodes( '//ul[@class="list-news"]//h5' );
    foreach my $item ( $results->get_nodelist ) {
        warn $item->as_HTML;
    }
}

sub on_link {
    my ( $self, $url ) = @_;

}



1;
