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
#   args: An arraryref, the args for C<< $c->uri_in_language_for() >>.
#   expected_uri: String, the expected URI.
my @tests = (
  {
    args => [ en => 'foo/bar' ],
    expected_uri => 'http://localhost/en/foo/bar',
  },
  {
    args => [ EN => 'foo/bar' ],
    expected_uri => 'http://localhost/en/foo/bar',
  },
  {
    args => [ de => 'foo/bar' ],
    expected_uri => 'http://localhost/de/foo/bar',
  },
);

{
  my ($response, $c) = ctx_request(GET '/en');

  ok(
    $response->is_success,
    "The request was successful"
  );

  foreach my $test (@tests) {
    my $test_description =
      Data::Dumper->new([
        +{
          map {
            ( $_ => $test->{$_} )
          } qw(args)
        }
      ])->Terse(1)->Indent(0)->Quotekeys(0)->Dump;

    is(
      $c->uri_in_language_for(@{ $test->{args} }),
      $test->{expected_uri},
      "\$c->uri_in_language_for() returns the expected URI ($test_description)"
    );
  }
}

done_testing;
