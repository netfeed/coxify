package Coxify::Db;

use base qw(Rose::DB);

use Mojo::JSON;

my $_config = undef;

sub config {
  my ($key)  = @_;

  unless ($_config) {
    my $json = Mojo::JSON->new;
    my $bytes = do { local $/; open my $FH, '<', 'config/config.json'; <$FH> };
    $_config = $json->decode($bytes) ;
  }

  return $_config->{$key};
}
 
__PACKAGE__->register_db(
  driver => config('driver'),
  database => config('database'),
  host => config('host'),
  username => config('username'),
  password => config('password'),
);

1;