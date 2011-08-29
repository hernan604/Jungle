package Jungle::Spider;
use Moose::Role;
with qw/Jungle::Browser/;

requires 'on_start';
requires 'on_link';
requires 'search';

after 'on_start' => sub {
    my ($self) = @_;
};

has site_name => (
    is => 'rw',
    isa => 'Str',
);

has data => (
    is => 'rw',
    isa => 'Any',
);

sub do_work {
    my ($self , $site_name, $data_class ) = @_;
    $self->data( $data_class ); #this class will treat the extracted website info
    $self->site_name( $site_name );
    $self->data->site_name( $site_name );
    warn " STARTING TO CRAWL SITE " . $self->site_name;
    $self->on_start();

# inserts our startpage into url list if there is none inserted from $self->on_start
    $self->append( search => $self->startpage )
      if ( scalar @{ $self->url_list } == 0 );
 
    while ( my $item = shift( @{ $self->url_list } ) ) {
        $self->work_on_page($item);
    }
}

sub work_on_page {
    my ( $self, $item ) = @_;
    $self->visit($item);
    $self->search_page_urls;
}

sub search_page_urls {
    my ($self) = @_;
    my $results = $self->tree->findnodes('//a');
    foreach my $item ( $results->get_nodelist ) {
        my $url = $item->attr('href');
        if ( defined $url and $url ne '' ) {
            my $url = $self->normalize_url( $url );
            $self->on_link($url)
              ;    #calls on_link and lets the user append or not to methods
        }
    }
}


=head1 NAME
    
    Jungle::Spider - Spider base

=head1 DESCRIPTION

    This is the base of the spider

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
