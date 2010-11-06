package TestApp::I18N::de;

use strict;
use warnings;

use base 'TestApp::I18N';

our %Lexicon = (
  'English' => 'Englisch',
  'German'  => 'Deutsch',
  'French'  => 'Franzäsisch',
  'Italian' => 'Italienisch',

  'PATH_localize_foo'    => 'quux',
  'PATH_delocalize_quux' => 'foo',

  'PATH_localize_bar'    => 'baz',
  'PATH_delocalize_baz'  => 'bar',
);

1;
