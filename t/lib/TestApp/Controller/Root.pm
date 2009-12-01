package TestApp::Controller::Root;

use strict;
use warnings;

use parent qw(Catalyst::Controller);

__PACKAGE__->config->{'namespace'} = '';

sub index :Path :Args(0) { }

sub default :Path { }

sub language_independent_stuff :Local { }


1;
