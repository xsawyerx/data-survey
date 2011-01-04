#!perl

use strict;
use warnings;

use Test::More tests => 8;
use Test::Exception;
use Data::Survey;
use Data::Survey::Renderer;
use File::Temp 'tempfile';

my $renderer;
throws_ok { $renderer = Data::Survey::Renderer->new() }
    qr/^Attribute \(template\) is required/,
    'Cannot create a Renderer without supplying template';

lives_ok { $renderer = Data::Survey::Renderer->new( template => 'eg.tt' ) }
    'Creating a Renderer with template works';

isa_ok( $renderer, 'Data::Survey::Renderer' );
can_ok(
    $renderer,
    qw/template render tt tt_opts process_template template_error
        survey_questions/,
);

throws_ok { $renderer->render } qr/^I have no survey to render/,
    'Cannot render without survey';

my $survey = Data::Survey->new(
    questions => [
        Data::Survey::Question::Open->new( name => 'back'  ),
        Data::Survey::Question::Open->new( name => 'in'    ),
        Data::Survey::Question::Open->new( name => 'black' ),
    ],
);

$renderer->survey($survey);
throws_ok { $renderer->render }
    qr/^Template file does not exist or is unreadable/,
    'Cannot render with inexistent template file';

my ( $fh, $file ) = tempfile();
print {$fh} "[% FOREACH q IN questions %]\n[% q.name %]\n[% END %]\n"
    or die "Can't print to $file in test: $!\n";
close $fh or die "Can't close $file in test: $!\n";

$renderer = Data::Survey::Renderer->new( template => $file, survey => $survey );
my $output = '';
lives_ok { $output = $renderer->render } 'Can render when we have a survey';
is( $output, "backinblack\n", 'Rendered template correctly' );

open $fh, '<', $file or die "Can't open $file: $!\n";
my @content = <$fh>;
close $fh or die "Can't close $file: $!\n";

END { -e $file and unlink $file }
