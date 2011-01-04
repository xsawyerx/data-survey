use strictures 1;
package Data::Survey::Question::Open;
# ABSTRACT: An open question

use Moose;
use MooseX::StrictConstructor;
use namespace::autoclean;

with 'Survey::Question';

has '+type' => ( default => 'Open' );

1;

