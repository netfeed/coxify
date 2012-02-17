package Mojolicious::Plugin::Oembed;
use Mojo::Base 'Mojolicious::Plugin';

use URI::Escape;
use Mojo::UserAgent;

our $VERSION = '0.01';

sub register {
  my ($self, $app, $endpoints) = @_;
  
  $self->{endpoints} = $endpoints;
  
  $app->helper(oembed => sub {
    my ($app, $url) = @_;
    
    my $endpoint;
    for my $hsh (@{ $self->{endpoints} }) {
      my $scheme = $hsh->{scheme};
      $scheme =~ s/\*/.*?/;
      $endpoint = $hsh->{endpoint};
      last;
    }
    
    return undef unless $endpoint;
    
    my $location = "${endpoint}?url=" . uri_escape($url);

    my $ret;
    my $ua = Mojo::UserAgent->new;
    $ua->get($location)->res->dom('url')->each(sub { $ret = $_->text; });

    return $ret;
  });
}

1;
