#!/usr/bin/perl

use strictures 1;
use Test::More tests => 10;
use Test::Exception;
use File::Temp 'tempfile';
use YAML;

use Survey;

sub dump_to_file {
    my ( $fh, $content ) = @_;
    print {$fh} Dump $content;
    close $fh;
}

sub open_and_dump {
    my ( $file, $content ) = @_;
    open my $fh, '>', $file or die "Can't open $file: $!\n";
    dump_to_file( $fh, $content );
}

my $survey = Survey->new();
isa_ok( $survey, 'Survey'              );
can_ok( $survey, 'questions_from_file' );

throws_ok { $survey->questions_from_file() } qr/^Must provide files/,
    'Required file to read questions from';

my ( $fh, $file ) = tempfile( SUFFIX => '.yaml' );
dump_to_file( $fh, { hello => 'world' } );

throws_ok { $survey->questions_from_file($file) } qr/^No questions/,
    'Must have questions in file';

open_and_dump( $file, { questions => [ { type => '', name => 'Zaba' } ] } );

throws_ok { $survey->questions_from_file($file) } qr/^Question 0 missing type/,
    'Must have existing type for question';

open_and_dump( $file, { questions => [ { type => 'Zaba', name => '' } ] } );

throws_ok { $survey->questions_from_file($file) } qr/^Question 0 missing name/,
    'Must have existing name for question';

open_and_dump( $file, { questions => [ { type => 'Zaba', name => 'Zada' } ] } );

throws_ok { $survey->questions_from_file($file) }
    qr/^Question type 'Zaba' doesn't exist or isn't loaded/,
    'Fails on non-existing type';

open_and_dump(
    $file, {
    questions => [ { type => 'Open', name => 'How old are you?' } ]
} );

lives_ok { $survey->questions_from_file($file) } 'Can read questions from file';
unlink $file;

my $questions = $survey->questions;
cmp_ok( scalar @{$questions}, '==', 1, 'Correct numbers of questions' );
isa_ok( $questions->[0], 'Survey::Question::Open' );

