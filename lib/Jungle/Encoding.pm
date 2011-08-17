package Jungle::Encoding;
use Encode::Guess;
use Moose::Role;
use utf8;

sub safe_utf8 {
    my ( $self, $content ) = @_; 
    Encode::Guess->add_suspects(qw/iso-8859-1 utf8/);
    my $decoder = Encode::Guess->guess($content);
    return $content unless ref($decoder);
    my $content_utf8 = $decoder->decode($content);
    return $content_utf8;
}

1;
