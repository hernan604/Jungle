package Jungle::Spider;
use Moose::Role;
with qw/Jungle::Browser/;

requires 'on_start';
requires 'on_link';
requires 'search';


after 'on_start'  => sub {
    my ( $self ) = @_; 

};

sub do_work {
    my ( $self) = @_; 
    warn " STARTING TO CRAWL SITE " . $self->startpage;
    $self->on_start();

    # inserts our startpage into url list if there is none inserted from $self->on_start
    $self->append( search => $self->startpage )
      if ( scalar @{$self->url_list } == 0 ) ;

    while ( my $item = pop( @{ $self->url_list } ) ) {
        $self->work_on_page( $item );
    }
}

sub work_on_page {
    my ( $self, $item ) = @_; 
    $self->visit( $item );
    $self->search_page_urls; 
}

sub search_page_urls {
    my ( $self ) = @_; 
    my $results = $self->tree->findnodes( '//a' );
    foreach my $item ( $results->get_nodelist ) {
        my $url = $self->normalize_url ( $item->attr( 'href' ) );
        $self->on_link( $url ); #calls on_link and lets the user append or not to methods
    }
}

1;
