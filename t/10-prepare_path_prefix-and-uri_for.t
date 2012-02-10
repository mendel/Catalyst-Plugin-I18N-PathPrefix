#!/usr/bin/env perl

use strict;
use warnings;

use Test::Most;

use FindBin;
use Path::Class;
use lib dir($FindBin::Bin)->subdir('lib')->stringify;

use TestUtils qw(run_prepare_path_prefix_and_uri_for_tests);

run_prepare_path_prefix_and_uri_for_tests(
  {
    request => {
      path => '/language_independent_stuff',
      accept_language => ['de'],
    },
    expected => {
      language => 'en',
      req => {
        uri => 'http://localhost/language_independent_stuff',
        base => 'http://localhost/',
        path => 'language_independent_stuff',
      },
      action => 'TestApp::Controller::Root::language_independent_stuff',
      log => [
        debug =>
          'path \'language_independent_stuff\' '
            . 'is language independent',
      ],
      uri_for => {
        '/language_independent_stuff' =>
          'http://localhost/language_independent_stuff',
        '/static/language_independent_things' =>
          'http://localhost/static/language_independent_things',
        '/static/quux'                => 'http://localhost/de/static/quux',
        '/foo/bar'                    => 'http://localhost/de/foo/bar',
        '/'                           => 'http://localhost/de/',
      },
    },
  },
  {
    request => {
      path => '/it/language_independent_stuff',
    },
    expected => {
      language => 'en',
      req => {
        uri => 'http://localhost/language_independent_stuff',
        base => 'http://localhost/',
        path => 'language_independent_stuff',
      },
      action => 'TestApp::Controller::Root::language_independent_stuff',
      log => [
        debug =>
          'found language prefix \'it\' in path '
            . '\'it/language_independent_stuff\'',
        debug =>
          'path \'language_independent_stuff\' '
            . 'is language independent',
      ],
      uri_for => {
        '/language_independent_stuff' =>
          'http://localhost/language_independent_stuff',
        '/static/language_independent_things' =>
          'http://localhost/static/language_independent_things',
        '/static/quux'                => 'http://localhost/en/static/quux',
        '/foo/bar'                    => 'http://localhost/en/foo/bar',
        '/'                           => 'http://localhost/en/',
      },
    },
  },
  {
    config => {
      fallback_language => 'FR',
    },
    request => {
      path => '/language_independent_stuff',
      accept_language => ['de'],
    },
    expected => {
      language => 'fr',
      req => {
        uri => 'http://localhost/language_independent_stuff',
        base => 'http://localhost/',
        path => 'language_independent_stuff',
      },
      action => 'TestApp::Controller::Root::language_independent_stuff',
      log => [
        debug =>
          'path \'language_independent_stuff\' '
            . 'is language independent',
      ],
      uri_for => {
        '/language_independent_stuff' =>
          'http://localhost/language_independent_stuff',
        '/static/language_independent_things' =>
          'http://localhost/static/language_independent_things',
        '/static/quux'                => 'http://localhost/de/static/quux',
        '/foo/bar'                    => 'http://localhost/de/foo/bar',
        '/'                           => 'http://localhost/de/',
      },
    },
  },

  {
    config  => {
      language_independent_paths => undef,
    },
    request => {
      path => '/language_independent_stuff',
      accept_language => ['de'],
    },
    expected => {
      language => 'de',
      req => {
        uri => 'http://localhost/de/language_independent_stuff',
        base => 'http://localhost/de/',
        path => 'language_independent_stuff',
      },
      action => 'TestApp::Controller::Root::language_independent_stuff',
      log => [
        debug => 'detected language: \'de\'',
        debug => 'set language prefix to \'de\'',
      ],
      uri_for => {
        '/language_independent_stuff' =>
          'http://localhost/de/language_independent_stuff',
        '/static/language_independent_things' =>
          'http://localhost/de/static/language_independent_things',
        '/static/quux'                => 'http://localhost/de/static/quux',
        '/foo/bar'                    => 'http://localhost/de/foo/bar',
        '/'                           => 'http://localhost/de/',
      },
    },
  },

  {
    request => {
      path => '/fr',
      accept_language => ['de'],
    },
    expected => {
      language => 'fr',
      req => {
        uri => 'http://localhost/fr/',
        base => 'http://localhost/fr/',
        path => '',
      },
      action => 'TestApp::Controller::Root::index',
      log => [
        debug => 'found language prefix \'fr\' in path \'fr\'',
      ],
      uri_for => {
        '/language_independent_stuff' =>
          'http://localhost/language_independent_stuff',
        '/static/language_independent_things' =>
          'http://localhost/static/language_independent_things',
        '/static/quux'                => 'http://localhost/fr/static/quux',
        '/foo/bar'                    => 'http://localhost/fr/foo/bar',
        '/'                           => 'http://localhost/fr/',
      },
    },
  },
  {
    request => {
      path => '/fr/',
      accept_language => ['de'],
    },
    expected => {
      language => 'fr',
      req => {
        uri => 'http://localhost/fr/',
        base => 'http://localhost/fr/',
        path => '',
      },
      action => 'TestApp::Controller::Root::index',
      log => [
        debug => 'found language prefix \'fr\' in path \'fr/\'',
      ],
      uri_for => {
        '/language_independent_stuff' =>
          'http://localhost/language_independent_stuff',
        '/static/language_independent_things' =>
          'http://localhost/static/language_independent_things',
        '/static/quux'                => 'http://localhost/fr/static/quux',
        '/foo/bar'                    => 'http://localhost/fr/foo/bar',
        '/'                           => 'http://localhost/fr/',
      },
    },
  },
  {
    request => {
      path => '/fr/foo/bar',
      accept_language => ['de'],
    },
    expected => {
      language => 'fr',
      req => {
        uri => 'http://localhost/fr/foo/bar',
        base => 'http://localhost/fr/',
        path => 'foo/bar',
      },
      action => 'TestApp::Controller::Foo::bar',
      log => [
        debug => 'found language prefix \'fr\' in path \'fr/foo/bar\'',
      ],
      uri_for => {
        '/language_independent_stuff' =>
          'http://localhost/language_independent_stuff',
        '/static/language_independent_things' =>
          'http://localhost/static/language_independent_things',
        '/static/quux'                => 'http://localhost/fr/static/quux',
        '/foo/bar'                    => 'http://localhost/fr/foo/bar',
        '/'                           => 'http://localhost/fr/',
      },
    },
  },
  {
    request => {
      path => '/FR/foo/bar',
      accept_language => ['de'],
    },
    expected => {
      language => 'fr',
      req => {
        uri => 'http://localhost/fr/foo/bar',
        base => 'http://localhost/fr/',
        path => 'foo/bar',
      },
      action => 'TestApp::Controller::Foo::bar',
      log => [
        debug => 'found language prefix \'fr\' in path \'FR/foo/bar\'',
      ],
      uri_for => {
        '/language_independent_stuff' =>
          'http://localhost/language_independent_stuff',
        '/static/language_independent_things' =>
          'http://localhost/static/language_independent_things',
        '/static/quux'                => 'http://localhost/fr/static/quux',
        '/foo/bar'                    => 'http://localhost/fr/foo/bar',
        '/'                           => 'http://localhost/fr/',
      },
    },
  },
  {
    request => {
      path => '/it/foo/bar',
      accept_language => ['de'],
    },
    expected => {
      language => 'it',
      req => {
        uri => 'http://localhost/it/foo/bar',
        base => 'http://localhost/it/',
        path => 'foo/bar',
      },
      action => 'TestApp::Controller::Foo::bar',
      log => [
        debug => 'found language prefix \'it\' in path \'it/foo/bar\'',
      ],
      uri_for => {
        '/language_independent_stuff' =>
          'http://localhost/language_independent_stuff',
        '/static/language_independent_things' =>
          'http://localhost/static/language_independent_things',
        '/static/quux'                => 'http://localhost/it/static/quux',
        '/foo/bar'                    => 'http://localhost/it/foo/bar',
        '/'                           => 'http://localhost/it/',
      },
    },
  },

  {
    request => {
      path => '/hu/foo/bar',
      accept_language => ['de'],
    },
    expected => {
      language => 'de',
      req => {
        uri => 'http://localhost/de/hu/foo/bar',
        base => 'http://localhost/de/',
        path => 'hu/foo/bar',
      },
      action => 'TestApp::Controller::Root::default',
      log => [
        debug => 'detected language: \'de\'',
        debug => 'set language prefix to \'de\'',
      ],
      uri_for => {
        '/language_independent_stuff' =>
          'http://localhost/language_independent_stuff',
        '/static/language_independent_things' =>
          'http://localhost/static/language_independent_things',
        '/static/quux'                => 'http://localhost/de/static/quux',
        '/foo/bar'                    => 'http://localhost/de/foo/bar',
        '/'                           => 'http://localhost/de/',
      },
    },
  },

  {
    request => {
      path => '/foo/bar',
      accept_language => ['de'],
    },
    expected => {
      language => 'de',
      req => {
        uri => 'http://localhost/de/foo/bar',
        base => 'http://localhost/de/',
        path => 'foo/bar',
      },
      action => 'TestApp::Controller::Foo::bar',
      log => [
        debug => 'detected language: \'de\'',
        debug => 'set language prefix to \'de\'',
      ],
      uri_for => {
        '/language_independent_stuff' =>
          'http://localhost/language_independent_stuff',
        '/static/language_independent_things' =>
          'http://localhost/static/language_independent_things',
        '/static/quux'                => 'http://localhost/de/static/quux',
        '/foo/bar'                    => 'http://localhost/de/foo/bar',
        '/'                           => 'http://localhost/de/',
      },
    },
  },
  {
    request => {
      path => '/foo/bar',
      accept_language => [],
    },
    expected => {
      language => 'en',
      req => {
        uri => 'http://localhost/en/foo/bar',
        base => 'http://localhost/en/',
        path => 'foo/bar',
      },
      action => 'TestApp::Controller::Foo::bar',
      log => [
        debug => 'detected language: N/A',
        debug => 'set language prefix to \'en\'',
      ],
      uri_for => {
        '/language_independent_stuff' =>
          'http://localhost/language_independent_stuff',
        '/static/language_independent_things' =>
          'http://localhost/static/language_independent_things',
        '/static/quux'                => 'http://localhost/en/static/quux',
        '/foo/bar'                    => 'http://localhost/en/foo/bar',
        '/'                           => 'http://localhost/en/',
      },
    },
  },
  {
    request => {
      path => '/',
      accept_language => ['de'],
    },
    expected => {
      language => 'de',
      req => {
        uri => 'http://localhost/de/',
        base => 'http://localhost/de/',
        path => '',
      },
      action => 'TestApp::Controller::Root::index',
      log => [
        debug => 'detected language: \'de\'',
        debug => 'set language prefix to \'de\'',
      ],
      uri_for => {
        '/language_independent_stuff' =>
          'http://localhost/language_independent_stuff',
        '/static/language_independent_things' =>
          'http://localhost/static/language_independent_things',
        '/static/quux'                => 'http://localhost/de/static/quux',
        '/foo/bar'                    => 'http://localhost/de/foo/bar',
        '/'                           => 'http://localhost/de/',
      },
    },
  },

  {
    config => {
      fallback_language => 'fr',
    },
    request => {
      path => '/language_independent_stuff',
      accept_language => ['de'],
    },
    expected => {
      language => 'fr',
      req => {
        uri => 'http://localhost/language_independent_stuff',
        base => 'http://localhost/',
        path => 'language_independent_stuff',
      },
      action => 'TestApp::Controller::Root::language_independent_stuff',
      log => [
        debug =>
          'path \'language_independent_stuff\' '
            . 'is language independent',
      ],
      uri_for => {
        '/language_independent_stuff' =>
          'http://localhost/language_independent_stuff',
        '/static/language_independent_things' =>
          'http://localhost/static/language_independent_things',
        '/static/quux'                => 'http://localhost/fr/static/quux',
        '/foo/bar'                    => 'http://localhost/fr/foo/bar',
        '/'                           => 'http://localhost/fr/',
      },
    },
  },

  {
    config => {
      fallback_language => 'fr',
    },
    request => {
      path => '/foo/bar',
      accept_language => [],
    },
    expected => {
      language => 'fr',
      req => {
        uri => 'http://localhost/fr/foo/bar',
        base => 'http://localhost/fr/',
        path => 'foo/bar',
      },
      action => 'TestApp::Controller::Foo::bar',
      log => [
        debug => 'detected language: N/A',
        debug => 'set language prefix to \'fr\'',
      ],
      uri_for => {
        '/language_independent_stuff' =>
          'http://localhost/language_independent_stuff',
        '/static/language_independent_things' =>
          'http://localhost/static/language_independent_things',
        '/static/quux'                => 'http://localhost/fr/static/quux',
        '/foo/bar'                    => 'http://localhost/fr/foo/bar',
        '/'                           => 'http://localhost/fr/',
      },
    },
  },
);

done_testing;
