package Coxify::Controller::Image;

use strict;

use Rose::DB::Object::QueryBuilder qw(build_select);

use DateTime;
use Mojo::JSON;
use Coxify::Db;
use Coxify::Image;
use Coxify::Model::Channel;
use Coxify::Model::Image;
use Coxify::Model::Network;

use base 'Mojolicious::Controller';

sub main {
  my ($self) = @_;

  return $self->redirect_to('/');
}

sub year {
  my ($self) = @_;

  my $from_date = new DateTime(year => $self->stash('year'), month => '01', day => '01');
  my $to_date = DateTime->last_day_of_month(year => $self->stash('year'), month => '12');

  my $images = Coxify::Model::Image::Manager->get_images(
    query => [
      active => 1,
      created_date => { ge_le => [ $from_date, $to_date ] }
    ],
    limit => 24,
    sort_by => "id DESC",
  );

  $self->stash(images => $images);
  $self->stash(facebook => { image => $images->[0], title => "Year " . $from_date->year });

  my $years = Coxify::Image::year_list();
  $self->stash(years => $years);

  $self->stash(breadcrumbs => [ 
    { path => '/', title => 'Home' },
    { path => '/image/' . $self->stash('year'), title => $self->stash('year') },
  ]);

  $self->render
}

sub month {
  my ($self) = @_;

  my $from_date = new DateTime(year => $self->stash('year'), month => $self->stash('month'), day => '01');
  my $to_date = DateTime->last_day_of_month(year => $self->stash('year'), month => $self->stash('month'));

  my $dates = Coxify::Image::date_list(from => $from_date, to => $to_date);

  $self->stash(dates => $dates);

  my $images = Coxify::Model::Image::Manager->get_images(
    query => [
      active => 1,
      created_date => { ge_le => [ $from_date, $to_date ] }
    ],
    limit => 24,
    sort_by => "id DESC",
  );

  $self->stash(images => $images);
  $self->stash(facebook => { image => $images->[0], title => join(" ", $from_date->month_name, $from_date->year) });

  my $years = Coxify::Image::year_list();
  $self->stash(years => $years);

  $self->stash(breadcrumbs => [ 
    { path => '/', title => 'Home' },
    { path => '/image/' . $from_date->year, title => $from_date->year },
    { path => join('/', '/image', $from_date->year, sprintf("%02d", $from_date->month)), title => $from_date->month_name },
  ]);

  $self->render
}

sub day {
  my ($self) = @_;

  my $from_date = new DateTime(year => $self->stash('year'), month => $self->stash('month'), day => '01');
  my $to_date = DateTime->last_day_of_month(year => $self->stash('year'), month => $self->stash('month'));

  my $date = new DateTime(
    year => $self->stash('year'),
    month => $self->stash('month'),
    day => $self->stash('day')
  );

  my $images = Coxify::Model::Image::Manager->get_images(
    query => [
      active => 1,
      created_date => $date,
    ],
    sort_by => 'id DESC',
  );

  my $dates = Coxify::Image::date_list(from => $from_date, to => $to_date, today => $date);
  $self->stash(dates => $dates);  

  my $years = Coxify::Image::year_list();
  $self->stash(years => $years);

  $self->stash(breadcrumbs => [ 
    { path => '/', title => 'Home' },
    { path => '/image/' . $date->year, title => $date->year },
    { path => join('/', '/image', $date->year, sprintf("%02d", $date->month)), title => $date->month_name },
    { path => join('/', '/image', $date->ymd('/')), title => $date->day },
  ]);

  $self->stash(images => $images); 

  my $fb_date = $images->[0]->created_date;
  $self->stash(facebook => { image => $images->[0], title => join(" ", $fb_date->day, $fb_date->month_name, $fb_date->year) });

  $self->render
}

sub image {
  my ($self) = @_;

  my $date = new DateTime(
    year => $self->stash('year'),
    month => $self->stash('month'),
    day => $self->stash('day')
  );

  my $image = new Coxify::Model::Image(id => $self->stash('id'));
  $image->load();

  my $lesser = Coxify::Model::Image::Manager->get_images(
    query => [
      active => 1,
      id => { lt => $self->stash('id') },
    ],
    sort_by => 'id DESC',
    limit => '1'
  );

  my $greater = Coxify::Model::Image::Manager->get_images(
    query => [
      active => 1,
      id => { gt => $self->stash('id') },
    ],
    sort_by => 'id ASC',
    limit => '1',
  );

  $self->stash(image => $image);
  $self->stash(facebook => { image => $image, title => "#" . $image->id });
  $self->stash(breadcrumbs => [ 
    { path => '/', title => 'Home' },
    { path => '/image/' . $date->year, title => $date->year },
    { path => join('/', '/image', $date->year, sprintf("%02d", $date->month)), title => $date->month_name },
    { path => join('/', '/image', $date->ymd('/')), title => $date->day },
    { title => "Image #" . $image->id }
  ]);

  my $previous = $greater ? $greater->[0] : undef;
  my $next = $lesser ? $lesser->[0] : undef;

  $self->stash(previous => $previous);
  $self->stash(next => $next);

  $self->render
}

sub add {
  my ($self) = @_;
  
  my $param = $self->param('json');
  return $self->render(json => { error => 'missing parameter json'}, status => 400) unless $param;

  my $json = Mojo::JSON->new;;
  my $in = $json->decode($param);

#  if ($in->{handshake} != 'bapp') {
#    return $self->render(json => { error => 'handshake failed' }, status => 400);
#  }

  my $network = Coxify::Model::Network->new(name => $in->{server});
  $network->load();
  return $self->render(json => { error => 'no such network'}, status => 400) unless $network;

  my $channels = Coxify::Model::Channel::Manager->get_channels(
    where => [
      network_id => $network->id,
      name => $in->{channel},
    ]
  );
  
  my $channel = shift @{ $channels } ;
  unless ($channel) {
    $channel = Coxify::Model::Channel->new(network_id => $network->id, name => $in->{channel});
    $channel->save();
  }

  my $images = Coxify::Model::Image::Manager->get_images(
    where => [
      md5 => $in->{md5},
      created_date => DateTime->now,
    ]
  );

  my $image = Coxify::Model::Image->new(
    md5 => $in->{md5},
    size => $in->{size},
    width => $in->{width},
    height => $in->{height},
    original_url => $in->{url},
    user => $in->{user},
    channel_id => $channel->id,
    created_date => DateTime->now->ymd,
    created_time => DateTime->now->hms,
    updated => DateTime->now,
    active => scalar(@{ $images }) ? 0 : 1,
  );

  $image->save();

  $self->render(json => {
    thumb => $image->thumb(domain => 0),
    medium => $image->medium(domain => 0),
    image => $image->image(domain => 0),
  });
}

1;