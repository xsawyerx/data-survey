#!perl

use strictures 1;
use Test::More tests => 7;
use Test::Exception;

use Survey::Question::Open;

throws_ok { my $q = Survey::Question::Open->new(); }
    qr/^Attribute \(name\) is required/, 'Must get name to create';

my $q = Survey::Question::Open->new( name => 'you here?' );
isa_ok( $q, 'Survey::Question::Open' );

# checking attributes
can_ok( $q, 'id', 'type', 'name', 'answer' );

ok( $q->id, 'ID was generated' );
is( $q->type, 'Open',      'Correct type' );
is( $q->name, 'you here?', 'Correct name' );

$q->answer('yes');
is( $q->answer, 'yes', 'Correct answer' );

