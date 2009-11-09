package TestApp::Controller::Foo;

use strict;
use warnings;

use parent qw(Catalyst::Controller);

sub bar :Local
{
  my ($self, $c) = (shift, shift, @_);


}


1;
