package Jungle::Browser;
use URI;
use Moose::Role;
use WWW::Mechanize;
use LWP::UserAgent;
use HTTP::Request::Common;
with qw/Jungle::Parser::XPath/;
with qw/Jungle::Parser::XML/;
with qw/Jungle::Encoding/;

has browser => (
    is      => 'ro',
    isa     => 'LWP::UserAgent',
    default => sub {
        my $ua = LWP::UserAgent->new;
        $ua->agent('Windows IE 6');
        $ua->cookie_jar( {} );
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

has passed_key_values => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub { {} },
);

has current_page => (
    is  => 'rw',
    isa => 'Any',
);

sub browse {
    my (
        $self,
        $url,                 #REQUIRED
        $query_params,        #OPTIONAL when defined, its a POST else its GET
        $passed_key_values,   #OPTIONAL holds some key=>values from referer page
    ) = @_;
    my $res;
    if ( defined $query_params ) {
        $res = $self->browser->request( POST $url , $query_params );
    }
    else {
        $res = $self->browser->request( GET $url );
    }
    if ( $res->is_success ) {
        $self->html_content( $self->safe_utf8( $res->content ) );
        if ( defined $passed_key_values ) {
            $self->passed_key_values($passed_key_values);
        }
        else {
            $self->passed_key_values( {} );
        }
#       $self->tree(undef);    #clean up
        $self->parse_xpath if $res->content_type =~ m/html/i;
        $self->xml(undef);    #clean up
        $self->parse_xml if $res->content_type =~ m/xml/i;
    }
    else {                    #something went wrong... 404 ??
        warn "An error occurred. Response: " . $res->status_line;
        $self->html_content('');
        $self->parse_xpath;
    }

}

####
### $method is the perl function that will handle this request
### $url is the next url to be accessed and handled by $method
### $query_params is an ARRAYREF, used for POST.
###     ie: [ 'formfield1_name' =>'Joe', 'formfield2_age' => 50, ]
### $rerefer_key_val is an HASHREF used to pass values from one page to the next page
###     ie: { stuff_on_page1 =>
###         'Something from page one that should be used on another page' }
sub append {
    my ( $self, $method, $url, $args ) = @_;
    my $query_params = $args->{query_params}
      if ( exists $args->{query_params} );
    my $passed_key_values = $args->{passed_key_values}
      if ( exists $args->{passed_key_values} );
    my $url_normalized = $self->normalize_url($url);
    if (    !exists $self->url_visited->{$url_normalized}
        and !exists $self->url_list_hash->{$url_normalized} )
    {

        #inserts stuff into @{ $self->url_list } which is handled by 'visit'
        push(
            @{ $self->url_list },
            {
                method            => $method,
                url               => $url_normalized,
                query_params      => $query_params,
                passed_key_values => $passed_key_values,
            }
        );
        $self->url_list_hash->{$url_normalized} = 1;
    }
    warn "APPENDED '$method' : '$url' ";
}

####
### $method is the perl function that will handle this request
### $url is the next url to be accessed and handled by $method
### $query_params is an ARRAYREF, used for POST.
###     ie: [ 'formfield1_name' =>'Joe', 'formfield2_age' => 50, ]
### $rerefer_key_val is an HASHREF used to pass values from one page to the next page
###     ie: { stuff_on_page1 =>
###         'Something from page one that should be used on another page' }
sub prepend {
    my ( $self, $method, $url, $args ) = @_;
    my $query_params = $args->{query_params}
      if ( exists $args->{query_params} );
    my $passed_key_values = $args->{passed_key_values}
      if ( exists $args->{passed_key_values} );
    my $url_normalized = $self->normalize_url($url);
    if (    !exists $self->url_visited->{$url_normalized}
        and !exists $self->url_list_hash->{$url_normalized} )
    {

        #inserts stuff into @{ $self->url_list } which is handled by 'visit'
        unshift(
            @{ $self->url_list },
            {
                method            => $method,
                url               => $url_normalized,
                query_params      => $query_params,
                passed_key_values => $passed_key_values,
            }
        );
        $self->url_list_hash->{$url_normalized} = 1;
    }
    warn "PREPENDED '$method' : '$url' ";
}

sub normalize_url {
    my ( $self, $url ) = @_;
    return $url if !$self->current_page;
    return $self->current_page if !$url and defined $self->current_page;
    my $uri_current = URI->new( $self->current_page );
    my $uri_next    = URI->new($url);

    return $uri_next->as_string if defined $uri_next->scheme;

    if ( !$uri_next->can('host') ) {
        if ( $url =~ m{^/(.+)} ) {
            $uri_next = URI->new( $uri_current->host . $url );
        }
        else {
            return $uri_current->as_string if ( $url =~ m/(javascript:|^#)/i );

            my @path_segments = $uri_current->path_segments;
            pop @path_segments;
            $uri_next = URI->new(
                $uri_current->host . join( '/', @path_segments ) . '/' . $url );
        }
    }
    return $uri_current->scheme . '://' . $uri_next->as_string;
}

#visit the url and load into xpath and redirects to the method
sub visit {
    my ( $self, $item ) = @_;
    $self->html_content( '' );
    warn 'TOTAL URLS IN LIST: ' . scalar @{ $self->url_list } and sleep 0;
    return
      if exists $self->url_visited->{ $item->{url} };    #return if not visited
    $self->url_visited->{ $item->{url} } = 1;            #set as visited

    warn "VISITING $item->{ method } : $item->{ url }";
    $self->current_page( $item->{url} );    #sets the page we are visiting
    $self->browse(
        $item->{url},
        $item->{query_params} || undef,
        $item->{passed_key_values} || undef
    );    #access page content and loads to $self->content
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
