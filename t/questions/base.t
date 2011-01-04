#!/usr/bin/perl

{
    package EG;
    use Moose;
    with 'Data::Survey::Question';
}

use strictures 1;
use Test::More tests => 9;
use Test::Exception;

throws_ok { EG->new } qr/^Attribute \(name\) is required/,
    'Requiring question name';

my $q = EG->new( name => 'Ack?' );
isa_ok( $q, 'EG' );
can_ok( $q, qw/id name answer/ );

is( $q->name, 'Ack?', 'Correct question name' );
ok( $q->id, 'Created ID automatically' );

dies_ok  { $q->name('Quack?') } 'Name is readonly';
dies_ok  { $q->id('22')       } 'ID is readonly';
lives_ok { $q->answer('yah')  } 'Answer is readwrite';

is( $q->answer, 'yah', 'Can change answer' );
