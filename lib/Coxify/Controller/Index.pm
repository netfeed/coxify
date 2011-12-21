package Coxify::Controller::Index;

use strict;

use base 'Mojolicious::Controller';

use Coxify::Image;
use Coxify::Model::Image;

sub index {
  my ($self) = @_;

  my $images = Coxify::Model::Image::Manager->get_images(
    query => [
      active => 1,
    ],
    sort_by => 'id DESC',
    limit => '24'
  );

  my $year_list = Coxify::Image::year_list($self->stash('year'));

  my %years = ();
  for my $month (@{ $year_list }) {
    $years{$month->{month}->year} = [] unless $years{$month->{month}->year};
    push @{ $years{$month->{month}->year} }, $month;
  }

  $self->stash(years => \%years);

  $self->stash(images => $images);
  $self->stash(breadcrumbs => [ { path => '/', title => 'Home' }]);

  $self->render;
}

1;