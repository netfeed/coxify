package Coxify;
use Mojo::Base 'Mojolicious';

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

  # Routes
  my $r = $self->routes;
  $r->namespace('Coxify::Controller');

  $r->route('/')->to("index#index");
  $r->route('/image')->to("image#main");
  $r->route('/image/add')->via('POST')->to("image#add");
  $r->route('/image/:year', year => qr/\d+/)->to("image#year");
  $r->route('/image/:year/:month')->to("image#month");
  $r->route('/image/:year/:month/:day')->to("image#day");
  $r->route('/image/:year/:month/:day/:id')->to("image#image");

  $r->route('/oembed/lookup')->to('oembed#lookup');

  $r->route('/thousand')->to("image#thousand");

  $r->route('/atom')->to('atom#atom');
}

1;
