# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

#use Test::More tests => 2;
use Test::More;

BEGIN { use_ok('Jungle'); }
use Jungle;
{

    package Test::Spider;
    use Moose;
    with qw(Jungle::Spider);
    sub on_link      { }
    sub on_start     { }
    sub search       { }
    sub append_test  { }
    sub prepend_test { }
}
my $spider = Test::Spider->new();
ok( 'Any' eq $spider->meta()->get_attribute('current_page')->{isa},
    'validates attr current_page' );
ok( 'HashRef' eq $spider->meta()->get_attribute('passed_key_values')->{isa},
    'validates attr passed_key_values' );
ok( 'LWP::UserAgent' eq $spider->meta()->get_attribute('browser')->{isa},
    'validates attr browser' );
ok( 'ArrayRef' eq $spider->meta()->get_attribute('url_list')->{isa},
    'validates attr url_list' );
ok( 'HashRef' eq $spider->meta()->get_attribute('url_list_hash')->{isa},
    'validates attr url_list_hash' );
ok( 'HashRef' eq $spider->meta()->get_attribute('url_visited')->{isa},
    'validates attr url_visited' );
ok( 'Str' eq $spider->meta()->get_attribute('html_content')->{isa},
    'validates attr html_content' );

#test for append a new url...
$spider->append(
    'append_test',
    'http://www.google.com',
    {
        query_params =>
          [ field_1 => 'some values', field_2 => 'other values', ],
        passed_key_values => { foo => 'bar' },
    }
);

my $item = pop @{ $spider->url_list };
ok( scalar @{ $spider->url_list } == 0,
    'should return 0 total items in url_list after after we just poped' );
ok(
    ref $item->{query_params} eq 'ARRAY',
    'verify our query params is an array'
);
ok( 'field_1'      eq @{ $item->{query_params} }[0], ' value ok 1' );
ok( 'some values'  eq @{ $item->{query_params} }[1], ' value ok 2' );
ok( 'field_2'      eq @{ $item->{query_params} }[2], ' value ok 3' );
ok( 'other values' eq @{ $item->{query_params} }[3], ' value ok 4' );
ok(
    'HASH' eq ref $item->{passed_key_values},
    'passed key values should be a hash'
);
ok( $item->{url}    =~ m/.+/, 'should be an url' );
ok( $item->{method} =~ m/.+/, 'should be a method name ' );

# same verification for prepend
$spider->prepend(
    'prepend_test',
    'http://www.google.com/new_url',
    {
        query_params =>
          [ field_1 => 'some values', field_2 => 'other values', ],
        passed_key_values => { foo => 'bar' },
    }
);
$item = pop @{ $spider->url_list };
ok( scalar @{ $spider->url_list } == 0,
    'should return 0 total items in url_list after after we just poped' );
ok(
    ref $item->{query_params} eq 'ARRAY',
    'verify our query params is an array'
);
ok( 'field_1'      eq @{ $item->{query_params} }[0], ' value ok 1' );
ok( 'some values'  eq @{ $item->{query_params} }[1], ' value ok 2' );
ok( 'field_2'      eq @{ $item->{query_params} }[2], ' value ok 3' );
ok( 'other values' eq @{ $item->{query_params} }[3], ' value ok 4' );
ok(
    'HASH' eq ref $item->{passed_key_values},
    'passed key values should be a hash'
);
ok( $item->{url}    =~ m/.+/, 'should be an url' );
ok( $item->{method} =~ m/.+/, 'should be a method name ' );

# now, lets try to append and prepend an 'already visited' url..
# should not be included in our url_list because it has been already visited
$spider->append( 'prepend_test', 'http://www.google.com/new_url' );
ok( 0 == scalar @{ $spider->url_list },
    'should return 0 because we already visited this url 1' );
$spider->prepend( 'prepend_test', 'http://www.google.com' );
ok( 0 == scalar @{ $spider->url_list },
    'should return 0 because we already visited this url 2' );

# now lets append an url and make the spider visit the url
# the content of the visited url should be loaded into ->html_content
$spider->prepend( 'prepend_test', 'http://www.estantevirtual.com.br/' );
ok( 1 == scalar @{ $spider->url_list },
    'sould return 1 because i just added a new url for visit' );
$item = pop @{ $spider->url_list };
$spider->visit($item);
ok( $spider->html_content =~ m/.+/,
    'page has been loaded into html_content with success' );
ok(
    $spider->html_content =~ m/estante virtual/ig,
    'has the loaded content as expected'
);
ok( $spider->current_page eq 'http://www.estantevirtual.com.br/',
    'makes sure we are visiting the page' );
ok( UNIVERSAL::isa( $spider->tree, 'HTML::TreeBuilder::XPath' ),
    ' its an HTML::TreeBuilder::XPath' );
ok( !UNIVERSAL::isa( $spider->xml, 'XML::XPath' ), ' its not an XML::XPath' );

#now lets visit an xml page and see if it parses correctly
$spider->prepend( 'prepend_test',
    'http://news.google.com/news?ned=us&topic=h&output=rss' );
ok( 1 == scalar @{ $spider->url_list },
    'sould return 1 because i just added a new url' );
$item = pop @{ $spider->url_list };
$spider->visit($item);
ok( UNIVERSAL::isa( $spider->tree, 'HTML::TreeBuilder::XPath' ),
    ' must be HTML::TreeBuilder::XPath 2' );
ok( UNIVERSAL::isa( $spider->xml, 'XML::XPath' ), ' its an XML::XPath 2' );

done_testing();
