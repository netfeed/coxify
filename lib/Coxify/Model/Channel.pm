package Coxify::Model::Channel;

use strict;

use base 'Coxify::Model';

__PACKAGE__->meta->setup(
  table   => 'channels',

  columns => [
    id         => { type => 'serial', not_null => 1 },
    name       => { type => 'text', not_null => 1 },
    active     => { type => 'boolean', default => 'true', not_null => 1 },
    network_id => { type => 'integer', not_null => 1 },
  ],

  primary_key_columns => [ 'id' ],
);

__PACKAGE__->meta->make_manager_class('channels');

1;