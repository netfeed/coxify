package Coxify::Controller::Oembed;

use strict;

use base 'Mojolicious::Controller';

use URI::Escape;

sub lookup {
  my ($self) = @_;

  my $result;
  if ($self->param('url')) {
    $result = $self->oembed(uri_unescape($self->param('url')));
  }

  if ($result) {
    $self->render(json => { "success" => "true", "url" => $result });
  } else {
    $self->render(json => { "success" => "false" });
  }
}

1;