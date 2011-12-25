package Coxify::Controller::Atom;

use strict;

use Coxify::Model::Image;

use base 'Mojolicious::Controller';

sub atom {
  my ($self) = @_;

  my $images = Coxify::Model::Image::Manager->get_images(
    where => [
      active => 1,
    ],
    limit => 24,
    sort_by => 'id DESC',
  );

  $self->stash(images => $images);

  $self->respond_to(
    xml => { template => 'atom.xml.ep' }
  );
}

1;