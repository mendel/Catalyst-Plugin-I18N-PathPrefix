package TestApp::Logger;

use Moose;
use namespace::autoclean;

use parent 'Catalyst::Log';

has languageprefix_plugin_log => (
  isa => 'ArrayRef',
  is => 'rw',
  clearer => 'clear_languageprefix_plugin_log',
  lazy_build => 1,
);

sub _build_languageprefix_plugin_log
{
  return [];
}

foreach my $level (qw(debug info warn error fatal)) {
  after $level => sub {
    my ($self, $message) = (shift, @_);

    if ($message =~ /^LanguagePrefix:/) {
      push @{ $self->languageprefix_plugin_log }, ($level => $message);
    }
  };
}

1;
