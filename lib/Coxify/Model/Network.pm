package Coxify::Model::Network;

use strict;

use base 'Coxify::Model';

__PACKAGE__->meta->setup(
  table   => 'networks',

  columns => [
    id      => { type => 'serial', not_null => 1 },
    name    => { type => 'text', not_null => 1 },
    slug    => { type => 'text', not_null => 1 },
    address => { type => 'text' },
    port    => { type => 'integer', default => 6667 },
    active  => { type => 'boolean', default => 'true', not_null => 1 },
  ],

  primary_key_columns => [ 'id' ],

  unique_key => [ 'name' ],
);

__PACKAGE__->meta->make_manager_class('networks');

1;