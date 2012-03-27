package Mojolicious::Plugin::Oembed;
use Mojo::Base 'Mojolicious::Plugin';

use URI::Escape;
use Mojo::UserAgent;

our $VERSION = '0.01';

sub register {
  my ($self, $app, $endpoints) = @_;
  
  $self->{endpoints} = $endpoints;
  
  $app->helper(oembed => sub {
    my ($cls, $url) = @_;
    
    my $endpoint;
    for my $hsh (@{ $self->{endpoints} }) {
      my $scheme = $hsh->{scheme};
      $scheme =~ s/\*/.*?/;
      if ($url =~ /$scheme/) {
        $endpoint = $hsh->{endpoint};
        last;
      }
    }
    
    return undef unless $endpoint;
    
    my $location = "${endpoint}?url=" . uri_escape($url);

    my $ua = Mojo::UserAgent->new;
    my $res = $ua->get($location)->res;

    my @list;
    $res->dom('url')->each(sub { push @list, $_->text; });

    return shift(@list);
  });
}

1;
