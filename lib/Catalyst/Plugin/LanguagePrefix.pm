package Catalyst::Plugin::LanguagePrefix;

use Moose;
use namespace::autoclean;

use List::Util qw(first);
use Scope::Guard;

=head1 NAME

Catalyst::Plugin::LanguagePrefix - Language prefix in the request path

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

  # in MyApp.pm
  use Catalyst;
  MyApp->setup( qw/LanguagePrefix/ );

  MyApp->config->{LanguagePrefix} => {
    valid_languages => ['en', 'de', 'fr'],
    default_language_prefix => 'en',
    language_independent_paths => qr{
        ^( /votes/ | /captcha/numeric/ )
    }x,
  };

  # now the language is selected based on requests paths:
  #
  # http://www.example.com/en/foo/bar -> sets $c->language to 'en',
  #                                      dispatcher sees /foo/bar
  #
  # http://www.example.com/de/foo/bar -> sets $c->language to 'de',
  #                                      dispatcher sees /foo/bar
  #
  # http://www.example.com/fr/foo/bar -> sets $c->language to 'fr',
  #                                      dispatcher sees /foo/bar
  #
  # http://www.example.com/foo/bar    -> sets $c->language from
  #                                      Accept-Language header,
  #                                      dispatcher sees /foo/bar

  # in a controller
  sub language_switch : Local
  {
    # the template will display the language switch
    $c->stash('language_switch' => $c->language_switch_options);
  }

=head1 DISCLAIMER

This is ALPHA SOFTWARE. Use at your own risk. Features may change.

=head1 DESCRIPTION

This module lets you put the language selector as a prefix to the path part of
the request URI.

Note: HTTP already had a mechanism for letting the user specify the language
(ie. Accept-Language header). Unfortunately users often don't set it properly,
but more importantly Googlebot does not support it (but requires that you
always serve documents of the same language in the same URI). So if you want a
SEO-optimized multi-lingual site, you have to have different (sub)domains for
the different languages, or resort to putting the language selector into the
URL.

Throughout this document 'language code' means ISO 639-1 2-letter language
codes, case insensitively (eg. 'en', 'de', 'it', 'EN').

=cut

=head1 CONFIGURATION

You can use these configuration options under the C<LanguagePrefix> key:

=head2 valid_languages => \@language_codes

The language codes that are accepted as path prefix.

=head2 fallback_language_prefix => $language_code

The fallback language code used if the URL contains no language prefix and
L<Catalyst::Plugin::I18N> cannot auto-detect the preferred language from the
C<Accept-Language> header or none of the detected languages are found in
L</valid_languages>.

=head2 language_independent_paths => $regex

If the URI path is matched by C<$regex>, do not add language prefix and ignore
if there's one (and pretend if the URI did not contain any language prefix, ie.
rewrite C<< $c->req->uri >>, C<< $c->req->base >> and C<< $c->req->path >>).

Use a regex that matches all your paths that return language independent
information.

=cut

=head1 METHODS

=cut


=head2 prepare_path

Overridden from L<Catalyst/prepare_path>.

Calls C<< $c->prepare_language_prefix >> after the original method.

=cut

after prepare_path => sub {
  my ($c) = (shift, @_);

  $c->prepare_language_prefix;
};


=head2 prepare_language_prefix

  $c->prepare_language_prefix()

Returns: N/A

If C<< $c->req->path >> is matched by the L</language_independent_paths>
configuration option then calls C<< $c->set_language_from_language_prefix >>
with the value of the L</fallback_language_prefix> configuration option and
returns.

Otherwise, if C<< $c->req->path >> starts with a language code listed in the
L</valid_languages> configuration option, then splits language prefix from C<<
$c->req->path >> then appends it to C<< $c->req->base >> and calls C<<
$c->set_language_from_language_prefix >> with this language prefix.

Otherwise, it tries to select an appropriate language code:

=over

=item *

It picks the first language code C<< $c->languages >> that is also present in
the L</valid_languages> configuration option.

=item *

If no such language code, uses the value of the L</fallback_language_prefix>
configuration option.

=back

Then appends this language code to C<< $c->req->base >> and the path part of
C<< $c->req->uri >>, finally calls C<< $c->set_language_from_language_prefix >>
with that language code.

=cut

# should be a 'state' var on Perl 5.10+
my %valid_language_codes;

sub prepare_language_prefix
{
  my ($c) = (shift, @_);

  my $config = $c->config->{LanguagePrefix};

  # fill the hash for quick lookups if not done yet
  if (!%valid_language_codes) {
    @valid_language_codes{ @{ $config->{valid_languages} } } = ();
  }

  my $language_code = $config->{fallback_language_prefix};

  if ($c->req->path !~ $config->{language_independent_paths}) {
    my @path_chunks = split m{/}, $c->req->path, 1;

    if (@path_chunks && exists $valid_language_codes{ $path_chunks[0] }) {
      $language_code = shift @path_chunks;

      $c->req->path($path_chunks[1]);
    } else {
      my $detected_language_code =
        first { exists $valid_language_codes{$_} } $c->languages;

      $language_code = $detected_language_code if $detected_language_code;

      $c->req->uri($language_code . '/' . $c->req->path);
    }

    my $req_base = $c->req->base;
    $req_base->path($req_base->path . '/' . $language_code);
  }

  $c->set_language_from_language_prefix($languge_code);
}


=head2 $c->set_language_from_language_prefix(

  $c->set_language_from_language_prefix($languge_code)

Returns: N/A

Sets C<< $c->language >> to C<$language_code>.

Called from both L</prepare_language_prefix> and L</switch_language> (ie.
always called when C<< $c->language >> is set by this module).

You can wrap this method (using eg. the L<Moose/after> method modifier) so you
can store the language code into the stash if you like:

  after prepare_language_prefix => sub {
    my $c = shift;

    $c->stash('language' => $c->language);
  };

=cut

sub set_language_from_language_prefix
{
  my ($c, $language_code) = (shift, @_);

  $c->language($language_code);
}


=head2 in_language_uri_for

  $c->in_language_uri_for($language_code => @uri_for_args)

Returns: C<$uri_object>

=cut

sub in_language_uri_for
{
  my ($c, $language_code, @uri_for_args) = (shift, @_);

  my $old_req_uri = $c->req->uri;
  my $old_req_base = $c->req->base;
  my $old_req_path = $c->req->path;

  my $sg = Scope::Guard->new(sub {
    $c->req->uri($old_req_uri);
    $c->req->base($old_req_base);
    $c->req->path($old_req_path);
  });

  my $old_req_uri_

  $c->req->uri($old_req_uri);
  $c->req->base($old_req_base);
  $c->req->path($old_req_path);

  #FIXME implement
}


=head2 current_uri_in_language

  $c->current_uri_in_language($language_code)

Returns: C<$uri_object>

Calculates the URL that correspods to C<< $c->req->path >> in the language
identified by C<$language_code>.

=cut

sub current_uri_in_language
{
  my ($c, $language_code) = (shift, @_);

  return $c->in_language_uri_for($language_code => $c->req->path);
}


=head2 switch_language

  $c->switch_language($language_code)

Returns: N/A

Changes C<< $c->req->base >> to end with C<$language_code> and calls C<<
$c->set_language_from_language_prefix >> with C<$language_code>.

Useful if you want to switch the language later in the request processing (eg.
from a request parameter, from the session or from the user object).

=cut

sub switch_language
{
  my ($c, $language_code) = (shift, @_);

  $c->_set_language_prefix($language_code);

  $c->set_language_from_language_prefix($language_code);
}


=head2 language_switch_options

  $c->language_switch_options()

Returns: C<< { $language_code => { name => $language_name, uri => $uri }, ... } >>

Returns a data structure that contains all the necessary data (language code,
name, URL of the same page) for displaying a language switch widget on the
page.

TODO include example TT2 template for the language switch

=cut

sub language_switch_options
{
  my ($c) = (shift, @_);

  return {
    map {
      $_ => {
        name => $c->loc(I18N::LangTags::List::name($_)),
        uri => $c->current_uri_in_language($_),
      }
    } @{ $c->config->{LanguagePrefix}->{valid_languages} }
  };
}


=begin internal

  $c->_set_language_prefix($language_code)

Sets the language to C<$language_code>: Mangles C<< $c->req->uri >>, C<<
$c->req->base >> and C<< $c->req->path >>.

=cut

sub _set_language_prefix
{
  my ($c, $language_code) = (shift, @_);

  #FIXME implement
}


=begin internal

  my $scope_guard = $c->_set_language_prefix_temporarily($language_code)

Sets the language prefix temporarily (does the same as L</_set_language_prefix>
but returns a L<Scope::Guard> instance that resets the these on destruction).

=cut

sub _set_language_prefix_temporarily
{
  my ($c, $language_code) = (shift, @_);

  my $old_req_uri = $c->req->uri;
  my $old_req_base = $c->req->base;
  my $old_req_path = $c->req->path;

  my $scope_guard = Scope::Guard->new(sub {
    $c->req->uri($old_req_uri);
    $c->req->base($old_req_base);
    $c->req->path($old_req_path);
  });

  $c->_set_language_prefix($language_code);

  return $scope_guard;
}



=head1 AUTHOR

Norbert Buchmüller, C<< <norbi at nix.hu> >>

=head1 TODO

=over

=item support locales instead of language codes

=back

=head1 BUGS

Please report any bugs or feature requests to
C<bug-catalyst-plugin-languageprefix at rt.cpan.org>, or through the web
interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Catalyst-Plugin-LanguagePrefix>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Catalyst::Plugin::LanguagePrefix

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Catalyst-Plugin-LanguagePrefix>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Catalyst-Plugin-LanguagePrefix>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Catalyst-Plugin-LanguagePrefix>

=item * Search CPAN

L<http://search.cpan.org/dist/Catalyst-Plugin-LanguagePrefix/>

=back

=head1 ACKNOWLEDGEMENTS

Thanks for Larry Leszczynski for the idea of appending the language prefix to
$c->req->base after it's split off of $c->req->path
(http://dev.catalystframework.org/wiki/wikicookbook/urlpathprefixing).

=head1 COPYRIGHT & LICENSE

Copyright 2009 Norbert Buchmüller, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Catalyst::Plugin::LanguagePrefix
