#!/usr/bin/env perl

use strict;
use warnings;

use Test::Most;

use FindBin;
use Path::Class;
use lib dir($FindBin::Bin)->subdir('lib')->stringify;

BEGIN {
  my $I18N_Request_version = 0.0;
  eval "use Catalyst::Plugin::I18N::Request $I18N_Request_version";
  plan skip_all =>
    "Test needs Catalyst::Plugin::I18N::Request $I18N_Request_version" if $@;
}

use TestUtils qw(run_prepare_path_prefix_tests);

run_prepare_path_prefix_tests(
  {
    request => {
      path => '/en/foo/bar',
      accept_language => ['de'],
    },
    expected => {
      language => 'en',
      req => {
        uri => 'http://localhost/en/foo/bar',
        base => 'http://localhost/en/',
        path => 'foo/bar',
      },
      action => 'TestApp::Controller::Foo::bar',
    },
  },
  {
    request => {
      path => '/foo/bar',
      accept_language => ['en'],
    },
    expected => {
      language => 'en',
      req => {
        uri => 'http://localhost/en/foo/bar',
        base => 'http://localhost/en/',
        path => 'foo/bar',
      },
      action => 'TestApp::Controller::Foo::bar',
    },
  },
  {
    request => {
      path => '/en/quux/baz',
      accept_language => ['de'],
    },
    expected => {
      language => 'en',
      req => {
        uri => 'http://localhost/en/quux/baz',
        base => 'http://localhost/en/',
        path => 'quux/baz',
      },
      action => 'TestApp::Controller::Root::default',
    },
  },
  {
    request => {
      path => '/quux/baz',
      accept_language => ['en'],
    },
    expected => {
      language => 'en',
      req => {
        uri => 'http://localhost/en/quux/baz',
        base => 'http://localhost/en/',
        path => 'quux/baz',
      },
      action => 'TestApp::Controller::Root::default',
    },
  },

  {
    request => {
      path => '/quux/baz',
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
    },
  },
  {
    request => {
      path => '/de/quux/baz',
      accept_language => ['en'],
    },
    expected => {
      language => 'de',
      req => {
        uri => 'http://localhost/de/foo/bar',
        base => 'http://localhost/de/',
        path => 'foo/bar',
      },
      action => 'TestApp::Controller::Foo::bar',
    },
  },
);

done_testing;
