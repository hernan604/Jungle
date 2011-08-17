# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

#use Test::More tests => 2;
use Test::More;

BEGIN { use_ok( 'Jungle' ); }
use Jungle;
my $spider = Jungle->new();
isa_ok ($spider, 'Jungle');
#$spider->work_site( 'UOL' ); #Tests UOL WEB SITE which is UTF8
$spider->work_site( 'Terra' ); #Tests UOL WEB SITE which is UTF8
done_testing();
