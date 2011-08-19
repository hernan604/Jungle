package Jungle::Browser;
use URI;
use Moose::Role;
use WWW::Mechanize;
use LWP::UserAgent;
use HTTP::Request::Common;
with qw/Jungle::XPath/;
with qw/Jungle::Encoding/;

has browser => (
    is      => 'ro',
    isa     => 'LWP::UserAgent',
    default => sub {
        my $ua = LWP::UserAgent->new;
        $ua->agent('Windows IE 6');
        return $ua;
    },
);

has url_list => (
    is      => 'rw',
    isa     => 'ArrayRef',
    default => sub { return []; },
);

has url_list_hash => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub { return {}; },
);

has url_visited => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub { {} },
);

has html_content => (
    is  => 'rw',
    isa => 'Str',
);

has current_page => (
    is  => 'rw',
    isa => 'Any',
);

sub browse {
    my (
        $self,
        $url,             #REQUIRED
        $query_params,    #OPTIONAL when defined, its a POST else its GET
    ) = @_;
    my $res;
    if ( defined $query_params ) {    #its a POST
#       warn "POSTING ";

        #       $req = HTTP::Request->new( POST => $url );
        #       $req->content_type('application/x-www-form-urlencoded');
        #       $req->content( $query_params );
        $res = $self->browser->request( POST $url , $query_params );
    }
    else {
#       warn "GETTING ";

        #        $req = HTTP::Request->new( GET => $url );
        $res = $self->browser->request( GET $url );
    }

    #   my $res = $self->browser->request($req);
    if ( $res->is_success ) {
        $self->html_content( $self->safe_utf8( $res->content ) );
        $self->parse_xpath;
    }
    else {    #something went wrong... 404 ??
        warn "An error occurred. Response: " . $res->status_line;
        $self->html_content('');
        $self->parse_xpath;
    }

}

sub append {
    my ( $self, $method, $url, $query_params ) = @_;
    my $url_normalized = $self->normalize_url($url);
    if (    !exists $self->url_visited->{$url_normalized}
        and !exists $self->url_list_hash->{$url_normalized} )
    {
        push(
            @{ $self->url_list },
            {
                method       => $method,
                url          => $url_normalized,
                query_params => $query_params,
            }
        );
        $self->url_list_hash->{$url_normalized} = 1;
    }
    warn "APPENDED '$method' : '$url' ";
}

sub prepend {
    my ( $self, $method, $url, $query_params ) = @_;
    my $url_normalized = $self->normalize_url($url);
    if (    !exists $self->url_visited->{$url_normalized}
        and !exists $self->url_list_hash->{$url_normalized} )
    {
        unshift(
            @{ $self->url_list },
            {
                method       => $method,
                url          => $url_normalized,
                query_params => $query_params,
            }
        );
        $self->url_list_hash->{$url_normalized} = 1;
    }
    warn "PREPENDED '$method' : '$url' ";
}

sub normalize_url {
    my ( $self, $url ) = @_;
    return $url if !$self->current_page or $url =~ m{^http://};
    return $self->current_page if !$url and defined $self->current_page;
    my $uri_current = URI->new($self->current_page);
    my $uri_next    = URI->new($url);

    if ( !$uri_next->can('host') ) {
        if ( $url =~ m{^/(.+)} ) {
            $uri_next = URI->new( $uri_current->host . $url );
        }
        else {
            return $uri_current->as_string if ( $url =~ m/(javascript:|^#)/i );

            my @path_segments = $uri_current->path_segments;
            pop @path_segments;
            $uri_next = URI->new( $uri_current->host . join( '/', @path_segments ) . '/' . $url );
        }
    }
    return ( $uri_next->as_string =~ m{^http}i )
      ? ( $uri_next->as_string )
      : ( 'http://' . $uri_next->as_string );
}

#visit the url and load into xpath and redirects to the method
sub visit {
    my ( $self, $item ) = @_;
    warn 'TOTAL URLS IN LIST: ' . scalar @{ $self->url_list } and sleep 0;
    return
      if exists $self->url_visited->{ $item->{url} };    #return if not visited
    $self->url_visited->{ $item->{url} } = 1;            #set as visited

    warn "VISITING $item->{ method } : $item->{ url }";
    $self->current_page( $item->{url} );    #sets the page we are visiting
    $self->browse( $item->{url}, $item->{query_params} || undef )
      ;    #access page content and loads to $self->content
    my $method = $item->{method};
    $self->$method;    #redirects back to method
}


=head1 NAME
    
    Jungle::Browser - Interfaces the websites using LWP

=head1 DESCRIPTION

    Jungle::Browser Uses LWP to interface with the internet

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
