
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
    sub on_link  { }
    sub on_start { }
    sub search   { }
}
my $spider = Test::Spider->new();

#isa_ok ($spider, 'Jungle::Spider');
my $url;
$spider->current_page(
    'https://www.somesite.com.br');
ok(
    "https://www.somesite.com.br/page1" eq
      $spider->normalize_url('/page1'),
    'https test 1 '
);

$spider->current_page(
    'ftp://www.somesite.com.br');
ok(
    "ftp://www.somesite.com.br/page1" eq
      $spider->normalize_url('/page1'),
    'ftp test 1 '
);

$spider->current_page(
    'ftp://www.somesite.com.br/some/dir');
ok(
    "ftp://www.somesite.com.br/some/page2" eq
      $spider->normalize_url('page2'),
    'ftp test 2 '
);

$spider->current_page(
    'ftp://www.somesite.com.br');
ok(
    "http://www.google.com" eq
      $spider->normalize_url('http://www.google.com'),
    'link to another site '
);

$spider->current_page(
    'http://www.teste.com.br/site1/site2/site3/site4/pagina.html');
ok(
    "http://www.teste.com.br/site1/site2/site3/site4/pagina2.html" eq
      $spider->normalize_url('pagina2.html'),
    'url ok 1'
);
$spider->current_page('http://www.teste.com.br/site/pagina.html');
ok(
    "http://www.teste.com.br/site/pagina2.html" eq
      $spider->normalize_url('pagina2.html'),
    'url ok 2'
);
ok(
    "http://www.teste.com.br/site/pagina5/" eq
      $spider->normalize_url('pagina5/'),
    'url ok 3'
);
ok(
    "http://www.teste.com.br/pagina2.html" eq
      $spider->normalize_url('/pagina2.html'),
    'url ok 4'
);
ok(
    "http://www.teste.com.br/teste/pagina2.html" eq
      $spider->normalize_url('/teste/pagina2.html'),
    'url ok 5'
);
ok(
    "http://www.teste.com.br/site/teste/pagina2.html" eq
      $spider->normalize_url('teste/pagina2.html'),
    'url ok 6'
);
ok(
    "http://www.teste.com.br" eq
      $spider->normalize_url('http://www.teste.com.br'),
    'url ok 7'
);
$spider->current_page('http://www.teste.com.br/');
ok(
    "http://www.teste.com.br/pagina2.html" eq
      $spider->normalize_url('pagina2.html'),
    'url ok 8'
);
ok(
    "http://www.teste.com.br/pages/pagina2.html" eq
      $spider->normalize_url('pages/pagina2.html'),
    'url ok 9'
);
ok(
    "http://www.teste.com.br/pages/pagina2.html" eq
      $spider->normalize_url('/pages/pagina2.html'),
    'url ok 10'
);
ok(
    "http://www.teste.com.br" eq
      $spider->normalize_url('http://www.teste.com.br'),
    'url ok 11'
);
$spider->current_page('http://www.teste.com.br/web/pages/deep');
ok(
    "http://www.teste.com.br/pages/pagina2.html" eq
      $spider->normalize_url('/pages/pagina2.html'),
    'url ok 12'
);
ok(
    "http://www.teste.com.br/web/pages/pages/pagina2.html" eq
      $spider->normalize_url('pages/pagina2.html'),
    'url ok 13'
);
ok(
    "http://www.teste.com.br/web/pages/pagina2.html" eq
      $spider->normalize_url('pagina2.html'),
    'url ok 14'
);
ok(
    "http://www.teste.com.br" eq
      $spider->normalize_url('http://www.teste.com.br'),
    'url ok 15'
);
$spider->current_page('http://www.teste.com.br/web/pages/deep///');
ok(
    "http://www.teste.com.br/pages/pagina2.html" eq
      $spider->normalize_url('/pages/pagina2.html'),
    'url ok 16'
);
ok(
    "http://www.teste.com.br/web/pages/deep///pagina2.html" eq
      $spider->normalize_url('pagina2.html'),
    'url ok 17'
);
ok(
    "http://www.google.com" eq $spider->normalize_url('http://www.google.com'),
    'url ok 18'
);

done_testing();
