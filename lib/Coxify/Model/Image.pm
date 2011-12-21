package Coxify::Model::Image;

use strict;

use File::Basename;
use DateTime;

use Coxify::Db;
use Coxify::Model::Channel;

use base qw(Rose::DB::Object);

__PACKAGE__->meta->setup (
  table   => 'images',

  columns => [
    id           => { type => 'serial', not_null => 1 },
    md5          => { type => 'varchar', length => 32, not_null => 1 },
    size         => { type => 'integer', not_null => 1 },
    width        => { type => 'integer', not_null => 1 },
    height       => { type => 'integer', not_null => 1 },
    original_url => { type => 'text' },
    pretty_url   => { type => 'text' },
    created_date => { type => 'date', not_null => 1, default => DateTime->now },
    created_time => { type => 'time', not_null => 1, precision => 6, scale => '0', default => DateTime->now->hms },
    updated      => { type => 'timestamp', not_null => 1, default => DateTime->now },
    user         => { type => 'text' },
    active       => { type => 'boolean', default => 'true', not_null => 1 },
    channel_id   => { type => 'integer', not_null => 1 },
  ],

  primary_key_columns => [ 'id' ],

  foreign_keys => [
    channel => {
      class       => 'Coxify::Model::Channel',
      key_columns => { channel_id => 'id' },
    },
  ],
);

__PACKAGE__->meta->make_manager_class('images');

sub init_db { Coxify::Db->new }

sub thumb {
  my $self = shift;
  my %p = @_;

  $p{type} = 't';
  return $self->image(%p);
}

sub medium {
  my $self = shift;
  my %p = @_;

  $p{type} => $self->width <= 700 ? '' : 'm';
  return $self->image(%p);
}

sub image {
  my $self = shift;
  my %p = @_;

  my $type = $p{type} || '';
  my $domain = defined($p{domain}) ? $p{domain} : 1;

  my ($ftype) = ($self->original_url =~ /.*\.(.*)$/);

  return join('/', 
    $domain ? 'http://images.coxify.com' : '', 
    $self->channel->network_id, 
    $self->channel_id, 
    $self->created_date->ymd('/'), 
    $self->id . "$type." . lc($ftype)
  );
}

sub url {
  my ($self) = @_;

  return join('/', "/image", $self->created_date->ymd('/'), $self->id);
}

1;