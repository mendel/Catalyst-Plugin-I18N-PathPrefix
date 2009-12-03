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

# Each element is a hashref, with the following key-value pairs:
#   config: An arrayref that describes the configuration of the module. The
#     corresponding key-value pairs of $c->config->{'Plugin::I18N::PathPrefix'}
#     are set to these values before the request.
#   request: An arrayref that describes the request. It can contain the
#     following key-value pairs:
#       path: The path part of the URI to request.
#       accept_language: An arrayref, contains language codes to set the
#         Accept-Language request header to before the request.
#   expected: A hashref that contains the expected values after the request.
#     It contains following key-value pairs:
#       language: The expected value of $c->language.
#       req: The expected value of some $c->req methods. A hashref with the
#         following key-value pairs:
#           uri: The expected value of $c->req->uri.
#           base: The expected value of $c->req->base.
#           path: The expected value of $c->req->path.
#       action: The fully qualified name of the action the dispatcher is
#         expected to dispatch the request.
#       log: The expected messages logged by the plugin. An arrayref that
#         contains pairs of values, where the first value is the log level
#         string (see L<Catalyst::Log> for the valid log levels) and the second
#         value is the message.
my @tests = (
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
    },
  },
);

{
  my %original_config = %{ TestApp->config->{'Plugin::I18N::PathPrefix'} };

  foreach my $test (@tests) {
    my $test_description =
      Data::Dumper->new([
        +{
          map {
            ( $_ => $test->{$_} )
          } qw(config request)
        }
      ])->Terse(1)->Indent(0)->Quotekeys(0)->Dump;

    TestApp->config->{'Plugin::I18N::PathPrefix'} = { %original_config };
    while (my ($config_key, $config_value) = each %{ $test->{config} }) {
      TestApp->config->{'Plugin::I18N::PathPrefix'}->{$config_key}
        = $config_value;
    }

    my ($response, $c) = ctx_request(
      GET $test->{request}->{path},
        'Accept-Language' => $test->{request}->{accept_language},
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

    isa_ok($c->req->uri, 'URI', "\$c->req->uri ($test_description)");

    is(
      $c->req->base,
      $test->{expected}->{req}->{base},
      "\$c->req->base is set to the expected value ($test_description)"
    );

    isa_ok($c->req->base, 'URI', "\$c->req->base ($test_description)");

    is(
      $c->req->path,
      $test->{expected}->{req}->{path},
      "\$c->req->path is set to the expected value ($test_description)"
    );

    eq_or_diff(
      $c->language_prefix_debug_messages,
      $test->{expected}->{log},
      "The plugin logged only the expected messages during the request "
        . "($test_description)"
    );
  }
}

done_testing;
