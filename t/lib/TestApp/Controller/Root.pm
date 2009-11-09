package TestApp::Controller::Root;

use strict;
use warnings;

use parent qw(Catalyst::Controller);

__PACKAGE__->config->{'namespace'} = '';

sub index :Path :Args(0)
{
  my ($self, $c) = (shift, shift, @_);


}

sub default :Path
{
  my ($self, $c) = (shift, shift, @_);


}

sub language_independent_stuff :Local
{
  my ($self, $c) = (shift, shift, @_);


}

1;
