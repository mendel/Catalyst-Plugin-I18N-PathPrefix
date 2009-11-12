package TestApp;

use Moose;
use namespace::autoclean;

extends 'Catalyst';

use TestApp::Logger;

our $VERSION = '0.01';

__PACKAGE__->config(
  name => 'TestApp',
  'Plugin::LanguagePrefix' => {
    valid_languages => ['en', 'de', 'fr'],
    fallback_language => 'en',
    language_independent_paths => qr{
      ^ language_independent_stuff
    }x,
    debug => 1,
  },
);

__PACKAGE__->log( TestApp::Logger->new );

__PACKAGE__->setup( qw(I18N LanguagePrefix) );

1;
