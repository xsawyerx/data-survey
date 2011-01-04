#!/usr/bin/perl

use strictures 1;
use Test::More tests => 5;
use Test::Exception;
use Test::TinyMocker;

use Data::Survey;

my $survey = Data::Survey->new();
isa_ok( $survey, 'Data::Survey' );
can_ok( $survey, qw/generate generate_cli generate_html/ );
is( $survey->interface, 'cli', 'Default generate method is CLI' );
lives_ok { $survey->interface('html') } 'Can run ->interface';
is( $survey->interface, 'html', 'Can change it to HTML' );

my %reached = ();
foreach my $type ( qw/html cli/ ) {
    mock 'Data::Survey'
        => method "generate_$type"
        => should {
            isa_ok( $_[0], 'Data::Survey' );
            $reached{$type}++;
        };
}

$survey->generate;
ok(   $reached{'html'}, 'Reached HTML generation'      );
ok( ! $reached{'cli'},  'Only HTML generation for now' );

$survey->interface('cli');
$survey->generate;
ok( $reached{'cli'}, 'Reached CLI generation' );

