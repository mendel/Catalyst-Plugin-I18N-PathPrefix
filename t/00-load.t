#!/usr/bin/env perl -T

use strict;
use warnings;

use Test::Most tests => 1;

BEGIN {
	use_ok( 'Catalyst::Plugin::LanguagePrefix' );
}

diag( "Testing Catalyst::Plugin::LanguagePrefix $Catalyst::Plugin::LanguagePrefix::VERSION, Perl $], $^X" );
