use strictures 1;
package Survey::Question;
# ABSTRACT: A base-class question for Survey

use Moose::Role;
use MooseX::Types::UUID 'UUID';
use namespace::autoclean;

use Data::UUID;

has 'id' => (
    is         => 'ro',
    isa        => UUID,
    lazy_build => 1,
);

has 'name' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has 'answer' => (
    is  => 'rw',
    isa => 'Str',
);

has 'type' => (
    is      => 'ro',
    isa     => 'Str',
    default => '',
);

sub _build_id {
    my $u = Data::UUID->new;
    return $u->to_string( $u->create );
}

1;

