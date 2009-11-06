#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Catalyst::Plugin::LanguagePrefix' );
}

diag( "Testing Catalyst::Plugin::LanguagePrefix $Catalyst::Plugin::LanguagePrefix::VERSION, Perl $], $^X" );
