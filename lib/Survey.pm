use strictures 1;
package Survey;
# ABSTRACT: Survey system

use Carp;
use Try::Tiny;
use Config::Any;
use Module::Loaded;

use Moose;
use MooseX::StrictConstructor;
use MooseX::Types::DateTime 'DateTime';

use namespace::autoclean;

# questions
use Survey::Question::Open;

with qw/
    MooseX::Getopt
    MooseX::SimpleConfig
/;

has 'date' => (
    is     => 'ro',
    isa    => DateTime,
    coerce => 1,
);

has 'questions' => (
    is        => 'rw',
    isa       => 'ArrayRef',
    default   => sub { [] },
    traits    => ['Array'],
    predicate => 'has_questions',
    clearer   => 'clear_questions',
    handles   => {
        add_question  => 'push',
        all_questions => 'elements',
        get_question  => 'get',
    },
);

sub questions_from_file {
    my ( $self, @files ) = @_;

    if ( ! @files ) {
        croak 'Must provide files';
    }

    my $cfg = Config::Any->load_files( {
        files           => \@files,
        use_ext         => 1,
        flatten_to_hash => 1,
    } );

    my @questions = ();

    foreach my $file ( keys %{$cfg} ) {
        my $data = $cfg->{$file};
        ref $data and ref $data eq 'HASH'
            or croak 'Incorrect configuration file';

        if ( my $q = $data->{'questions'} ) {
            push @questions, @{$q};
        }
    }

    @questions or croak 'No questions';

    foreach my $idx ( 0 .. $#questions ) {
        my $q     = $questions[$idx];
        my $type  = $q->{'type'} || croak "Question $idx missing type";
        my $name  = $q->{'name'} || croak "Question $idx missing name";
        my $class = "Survey::Question::$type";

        is_loaded($class)
            or croak "Question type '$type' doesn't exist or isn't loaded";

        my $qobject;
        try   { $qobject = $class->new( name => $name ); }
        catch { croak "Couldn't create new question: $_"; };

        $self->add_question($qobject);
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

=head1 SYNOPSIS

    use Survey;
    use Survey::Question::Open;
    use Survey::Question::YesNo;

    my $survey = Survey->new(
        questions => [
            Survey::Question::Open->new( name => 'What's your name?' ),
            Survey::Question::YesNo->new(
                name    => 'Do you have a dog?',
                default => 'y',
            ),
        ],
    );

    $survey->generate_html();

    $survey->generate_cli();

=head1 DESCRIPTION

Survey is a system to run a survey.

=head1 ATTRIBUTES

=head2 date

Sets the date for the survey. This is currently a single date.

=head2 questions

The survey's questions are all Survey::Question::* objects.

=head1 SUBROUTINES/METHODS

=head2 questions_from_file

Accepts any L<Config::Any> type file and reads it as configuration to create
questions out of.

