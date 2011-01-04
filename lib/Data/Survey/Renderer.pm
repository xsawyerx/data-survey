use strictures 1;
package Data::Survey::Renderer;
# ABSTRACT: Renderer for survey system

use Carp;
use Template;
use Try::Tiny;
use File::ShareDir 'dist_dir';

use Moose;
use MooseX::StrictConstructor;
use MooseX::Types::Path::Class 'File';

use namespace::autoclean;

has 'template' => (
    is       => 'ro',
    isa      => File,
    coerce   => 1,
    required => 1,
);

has 'tt' => (
    is         => 'ro',
    isa        => 'Template',
    lazy_build => 1,
    handles    => {
        process_template => 'process',
        template_error   => 'error',
    },
);

has 'tt_opts' => (
    is      => 'ro',
    isa     => 'HashRef',
    default => sub { {
        PRE_CHOMP    => 1,
        ABSOLUTE     => 1,
    } },
);

has 'tt_extra_opts' => (
    is      => 'ro',
    isa     => 'HashRef',
    default => sub { {} },
);

has 'survey' => (
    is        => 'rw',
    isa       => 'Survey',
    predicate => 'has_survey',
    handles   => {
        survey_questions => 'questions',
    },
);

has 'tt_out' => (
    is        => 'ro',
    isa       => File,
    coerce    => 1,
    predicate => 'has_tt_out',
);

sub _build_tt {
    my $self = shift;
    my %opts = ( %{ $self->tt_opts }, %{ $self->tt_extra_opts } );
    return Template->new(\%opts);
}

sub BUILD {
    my $self = shift;
    my $share;
    try { $share = dist_dir(__PACKAGE__) };
    $share and $self->tt_opts->{'INCLUDE_PATH'} = $share;
}

sub render {
    my $self = shift;
    my $file = $self->template->stringify;

    if ( ! $self->has_survey ) {
        croak 'I have no survey to render';
    }

    if ( ! -r $file ) {
        croak 'Template file does not exist or is unreadable';
    }

    my $output = '';
    $self->process_template(
        $file,
        { questions => $self->survey_questions },
        \$output,
    ) or croak $self->template_error;

    $self->has_tt_out and write_file( $self->tt_out, $output );

    return $output;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

__END__

=head1 SYNOPSIS

    use Survey::Renderer;

    my $renderer = Survey::Renderer->new( template => 'eg.tt' );
    $renderer->render;

=head1 DESCRIPTION

Rendering object for Survey. It renders a template using question objects.

=head1 ATTRIBUTES

=head2 template

The template file to render.

=head1 SUBROUTINES/METHODS

=head2 render

Run the actual rendering.

