package Coxify::Controller::Index;

use strict;

use base 'Mojolicious::Controller';

use DateTime;
use Coxify::Image;
use Coxify::Model::Image;

sub index {
  my ($self) = @_;

  my ($sql, $binds) = Coxify::Model::Image::Manager->get_objects_sql(
    select => 'created_date',
    where => [
      active => 1,
    ],
    sort_by => 'created_date DESC',
    group_by => 'created_date',
    limit => 1
  );

  my $db = new Coxify::Db();
  my $dbh = $db->dbh;
  my $query = $dbh->selectall_arrayref($sql, {}, @{ $binds });

  my $iso_date = $query->[0]->[0];
  my ($y, $m, $d) = split(/-/, $iso_date);
  my $to_date = DateTime->new(year => $y, month => $m, day => $d);
  my $from_date = $to_date->clone->subtract(days => 7);

  my $days = Coxify::Image::date_list(from => $from_date, to => $to_date, limit => 7);
  $self->stash(dates => $days);

  my $images = Coxify::Model::Image::Manager->get_images(
    query => [
      active => 1,
    ],
    limit => 25,
    sort_by => 'id DESC',
  );

  my $years = Coxify::Image::year_list();
  $self->stash(years => $years);

  $self->stash(images => $images);
  $self->stash(meta_data => { image => $images->[0] });
  $self->stash(breadcrumbs => [ { path => '/', title => 'Home' }]);

  if ($self->req->headers->header('X-PJAX')) {
    $self->render_partial;
  } else {
    $self->render;
  }
}

1;