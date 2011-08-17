package Jungle::Data::News;
use Moose::Role;
use Text::CSV_XS;
use DateTime;
use Digest::SHA1 qw(sha1_hex);
use HTML::Entities;

# this is a Data EXAMPLE to handle News...
# 1. News fields should be listed ie:
#   has title
#   has author
#   has content
#
# 2. This class should allow some sort of saving data to csv or something,
# so we can save/append to csv and free from memory

has filename_csv => (
    is      => 'rw',
    isa     => 'Str',
    default => sub {
        my ($self) = @_;
        my $today = DateTime->now( time_zone => 'local' );

        #defines a name for our csv.
        my $filename =
            $today->year
          . $today->month
          . $today->day
          . $today->hour
          . $today->minute
          . $today->second
          . '.csv';
        $self->filename_csv($filename);
    },
);

has title => (
    is  => 'rw',
    isa => 'Str',
);

has author => (
    is  => 'rw',
    isa => 'Str',
);

has content => (
    is  => 'rw',
    isa => 'Str',
);

has id_hashed => (
    is  => 'rw',
    isa => 'Str',
);

has data => (
    is      => 'rw',
    isa     => 'Jungle::Data::News',
    default => sub {
        my ($self) = @_;
        return $self;
    },
);

has csv => (
    is => 'ro',
    isa => 'Text::CSV_XS',
    default => sub {
        my $csv = Text::CSV_XS->new()
          or die "Cannot use CSV: " . Text::CSV_XS->error_diag();
        $csv->eol("\r\n");
        return $csv;
    },
);

sub save {    #saves the data to csv
    my ($self) = @_;
    my @rows = (
        [
            sha1_hex( $self->current_page ),
            $self->current_page,
            decode_entities( $self->data->title ),
            decode_entities( $self->data->author ),
            decode_entities( $self->data->content ),
        ],
    );
    my $file = './data/NEWS-' . $self->site_name. '-' . $self->filename_csv;

    open my $fh, ">>:encoding(utf8)", "$file" or die "$file: $!";
    $self->csv->print( $fh, $_ ) for @rows;
    close $fh or die "Error on file $file: $!";
}

1;
