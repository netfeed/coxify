package Coxify::Db;

use base qw(Rose::DB);

__PACKAGE__->register_db(
  driver => 'pg',
  database => 'coxify',
  host => 'localhost',
  username => 'netfeed',
  password => '',
);

1;