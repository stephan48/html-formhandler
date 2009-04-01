use strict;
use warnings;
use Test::More;
use lib 't/lib';

BEGIN {
   eval "use DBIx::Class";
   plan skip_all => 'DBIX::Class required' if $@;
   plan tests => 5;
}

use_ok( 'HTML::FormHandler::Generator::DBIC' );

use_ok( 'BookDB::Schema::DB');

my $schema = BookDB::Schema::DB->connect('dbi:SQLite:t/db/book.db');
ok($schema, 'get db schema');

my $generator = HTML::FormHandler::Generator::DBIC->new( schema => $schema, rs_name => 'Book' );
ok( $generator, 'Generator created' );

my $form_code = $generator->generate_form();

ok( $form_code, 'form code generated' );
