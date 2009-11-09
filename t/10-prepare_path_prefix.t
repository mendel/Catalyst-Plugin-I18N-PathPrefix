#!/usr/bin/env perl

use strict;
use warnings;

use Test::Most;

use FindBin;
use Path::Class;
use lib dir($FindBin::Bin)->subdir('lib')->stringify;

use HTTP::Request::Common;
use Catalyst::Test 'TestApp';
use Data::Dumper;

# * request for a language independent path
#  * language set to fallback_language
#  * $c->req->uri, $c->req->base, $c->req->path are as expected
#  * the right action is chosen
# * request for a valid language
#  * language set to the prefix language code
#  * $c->req->uri, $c->req->base, $c->req->path are as expected
#  * the right action is chosen
# * request for an invalid language
#  * language set to the Accept-Language language
#  * $c->req->uri, $c->req->base, $c->req->path are as expected
#  * the default action is chosen
# * request without a language prefix, with Accept-Language
#  * language set to the Accept-Language language
#  * $c->req->uri, $c->req->base, $c->req->path are as expected
#  * the right action is chosen
# * request without a language prefix, without Accept-Language
#  * language set to fallback_language
#  * $c->req->uri, $c->req->base, $c->req->path are as expected
#  * the right action is chosen
# * request for /, /en, /en/, /en/foo/bar
# * request without Accept-Language with different fallback_language values
# * debug

my @tests = (
  {
    path => '/language_independent_stuff',
    accept_language => ['de'],
    expected => {
      language => 'en',
      req => {
        uri => 'http://localhost/language_independent_stuff',
        base => 'http://localhost/',
        path => 'language_independent_stuff',
      },
      action => 'TestApp::Controller::Root::language_independent_stuff',
    },
  },

  {
    path => '/fr',
    accept_language => ['de'],
    expected => {
      language => 'fr',
      req => {
        uri => 'http://localhost/fr/',
        base => 'http://localhost/fr/',
        path => '',
      },
      action => 'TestApp::Controller::Root::index',
    },
  },
  {
    path => '/fr/',
    accept_language => ['de'],
    expected => {
      language => 'fr',
      req => {
        uri => 'http://localhost/fr/',
        base => 'http://localhost/fr/',
        path => '',
      },
      action => 'TestApp::Controller::Root::index',
    },
  },
  {
    path => '/fr/foo/bar',
    accept_language => ['de'],
    expected => {
      language => 'fr',
      req => {
        uri => 'http://localhost/fr/foo/bar',
        base => 'http://localhost/fr/',
        path => 'foo/bar',
      },
      action => 'TestApp::Controller::Foo::bar',
    },
  },

  {
    path => '/hu/foo/bar',
    accept_language => ['de'],
    expected => {
      language => 'de',
      req => {
        uri => 'http://localhost/de/hu/foo/bar',
        base => 'http://localhost/de/',
        path => 'hu/foo/bar',
      },
      action => 'TestApp::Controller::Root::default',
    },
  },

  {
    path => '/foo/bar',
    accept_language => ['de'],
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
    path => '/foo/bar',
    accept_language => [],
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
);

{
  foreach my $test (@tests) {
    my $test_description =
      Data::Dumper->new([
        +{
          map {
            ( $_ => $test->{$_} )
          } qw(path accept_language)
        }
      ])->Terse(1)->Indent(0)->Quotekeys(0)->Dump;

    my ($response, $c) = ctx_request(
      GET $test->{path},
        'Accept-Language' => $test->{accept_language},
    );

    ok(
      $response->is_success,
      "The request was successful ($test_description)"
    );

    is(
      $c->action->class . '::' . $c->action->name,
      $test->{expected}->{action},
      "Dispatched to the right action ($test_description)"
    );

    is(
      $c->language,
      $test->{expected}->{language},
      "\$c->language is set to the expected value ($test_description)"
    );

    is(
      $c->req->uri,
      $test->{expected}->{req}->{uri},
      "\$c->req->uri is set to the expected value ($test_description)"
    );

    is(
      $c->req->base,
      $test->{expected}->{req}->{base},
      "\$c->req->base is set to the expected value ($test_description)"
    );

    is(
      $c->req->path,
      $test->{expected}->{req}->{path},
      "\$c->req->path is set to the expected value ($test_description)"
    );
  }
}

done_testing;
