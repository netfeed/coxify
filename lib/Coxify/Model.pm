package Coxify::Model;

use strict;

use base qw(Rose::DB::Object);

use Coxify::Db;

my $_config = undef;

sub init_db { Coxify::Db->new }

sub manager { return (ref($_[0]) || $_[0]) . '::Manager' }

sub config {
  my ($self, $key)  = @_;

  unless ($_config) {
    my $bytes = do { local $/; open my $FH, '<', 'config/config.json'; <$FH> };
    $_config = Mojo::JSON->decode($bytes) ;
  }

  return $_config->{$key};
}

1;