# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

#use Test::More tests => 2;
use Test::More;

BEGIN { use_ok('Jungle'); }
use Jungle;
use Jungle::Data::News;
my $spider = Jungle->new();
isa_ok( $spider, 'Jungle' );
$spider->work_site( 'Sites::NewsSpider::TerraPOST', Jungle::Data::News->new )
  ;    #Test for POST
$spider->work_site( 'Sites::NewsSpider::Terra', Jungle::Data::News->new )
  ;    #Tests TERRA WEB SITE which is ISO-8859-1
$spider->work_site( 'Sites::NewsSpider::UOL', Jungle::Data::News->new )
  ;    #Tests UOL WEB SITE which is UTF8
$spider->work_site( 'Sites::NewsSpider::Estadao', Jungle::Data::News->new )
  ;    #Tests Estadao WEB SITE which is UTF8


my @files = glob './data/NEWS-*';
ok( scalar @files >= 3, 'After running the spider, 3 csv files should have been created ' );

done_testing();
