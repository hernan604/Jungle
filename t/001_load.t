# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

#use Test::More tests => 2;
use Test::More;

BEGIN { use_ok( 'Jungle' ); }
use Jungle;
use Jungle::Data::News;
my $spider = Jungle->new();
isa_ok ($spider, 'Jungle');
$spider->work_site( 'NewsSpider::UOL' , Jungle::Data::News->new ); #Tests UOL WEB SITE which is UTF8
$spider->work_site( 'NewsSpider::Terra', Jungle::Data::News->new ); #Tests TERRA WEB SITE which is ISO-8859-1
$spider->work_site( 'NewsSpider::Estadao', Jungle::Data::News->new ); #Tests Estadao WEB SITE which is UTF8
done_testing();
