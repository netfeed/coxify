package Coxify::Controller::Index;

use strict;

use base 'Mojolicious::Controller';

use DateTime;
use DateTime::Format::Strptime;
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
    limit => 35,
    sort_by => 'id DESC',
  );

  my $years = Coxify::Image::year_list();
  $self->stash(years => $years);

  my $last_seen_cookie = $self->cookie('last_seen');
  my $strp = DateTime::Format::Strptime->new(pattern => "%FT%T");
  my $last_seen = $last_seen_cookie ? $strp->parse_datetime($last_seen_cookie) : undef;

  $self->stash(last_seen => $last_seen);
  $self->stash(images => $images);
  $self->stash(meta_data => { image => $images->[0] });
  $self->stash(breadcrumbs => [ { path => '/', title => 'Home' }]);
  

  $self->render;
}

1;
