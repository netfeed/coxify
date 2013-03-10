package Coxify;
use Mojo::Base 'Mojolicious';

use DateTime;

# This method will run once at server start
sub startup {
  my $self = shift;
  
  my $config = $self->plugin('JSONConfig' => { file => "config/config.json" });

  $self->secret($config->{secret});
  
  $self->plugin(Oembed => [
    {
        scheme => 'http://*.flickr.com/*',
        endpoint => 'http://www.flickr.com/services/oembed/'
    },
    {
      scheme => 'http://*.smugmug.com/*',
      endpoint => 'http://api.smugmug.com/services/oembed/',
    },
  ]);

  $self->helper(canonical_url => sub {
    my ($self, $url) = @_;
    return '' unless $url;
    my @parts =  split(/\?/, $url);
    return $parts[0];
  });

  $self->hook(after_static => sub {
    my $self = shift;
#    $self->cookie(last_seen => '2012-10-11T11:49:26'); # for testing
    $self->cookie(last_seen => DateTime->now()->strftime("%FT%T"));
  });

  # Routes
  my $r = $self->routes;
  $r->namespaces(['Coxify::Controller']);

  $r->route('/')->to("index#index");
  $r->route('/image')->to("image#main");
  $r->route('/random')->to("image#random");
  $r->route('/image/add')->via('POST')->to("image#add");
  $r->route('/image/:year', year => qr/\d{4}/)->to("image#year");
  $r->route('/image/:year/:month', year => qr/\d{4}/, month => qr/\d{2}/)->to("image#month");
  $r->route('/image/:year/:month/:day', year => qr/\d{4}/, month => qr/\d{2}/, day => qr/\d{2}/)->to("image#day");
  $r->route('/image/:year/:month/:day/:id', year => qr/\d{4}/, month => qr/\d{2}/, day => qr/\d{2}/, id => qr/\d*/)->to("image#image");

  $r->route('/oembed/lookup')->to('oembed#lookup');

  $r->route('/thousand')->to("image#thousand");
 
  $r->route("/popular")->to("image#popular");
  $r->route("/popular/linked")->to("image#popular_linked");

  $r->route('/atom')->to('atom#atom');
}

1;
