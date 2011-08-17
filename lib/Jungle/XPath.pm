package Jungle::XPath;
use Moose::Role;
use HTML::TreeBuilder::XPath;

has tree => (
    is  => 'rw',
    isa => 'Any',
);

sub parse_xpath {
    my ($self) = @_;
    my $tree_xpath = HTML::TreeBuilder::XPath->new;
    $self->tree->delete
      if ( defined $self->tree
        and $self->tree->isa('HTML::TreeBuilder::XPath') );
    $self->tree( $tree_xpath->parse( $self->html_content ) );
}

1;
