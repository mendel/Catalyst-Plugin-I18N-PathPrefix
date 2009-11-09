package TestApp;

use strict;
use warnings;

use Catalyst::Runtime 5.80;

use parent qw(Catalyst);

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

__PACKAGE__->setup( qw(I18N LanguagePrefix) );

1;
