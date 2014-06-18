package App::OpenZabbix;
use 5.008005;
use strict;
use warnings;

use App::OpenZabbix::ZabbixAPI;
use App::OpenZabbix::Screen;
use App::OpenZabbix::Host;
use App::OpenZabbix::Maintenance;
use IPC::Open2;
use IO::Handle;
use Encode;
use Config::Pit;
use Log::Minimal;
use Cache::FastMmap;
use File::Spec;
use Carp;
our $VERSION = "0.02";
our $EXPIRES = 3600;
our $Cache;

sub run {
    my $class = shift;
    my %args  = @_;
    my $command       = defined $args{command} ? $args{command} : "percol";

    my $api_method    = $args{api_method} or croak("api_method is required");
    my $api_args      = $args{api_args} or croak("api_args is required");
    my $printer       = $args{printer} or croak("printer sub is required");
    my $parser        = $args{parser} or croak("parser sub is required");
    my $url_generator = $args{url_generator} or croak("url_generator sub is required");

    my $config = pit_get(
        "zabbix", require => {
            "url"      => "zabbix url endpoint (e.g. http://example.com/zabbix/)",
            "user"     => "zabbix username",
            "password" => "zabbix password",
        }
    );

    my $url = delete $config->{url};
    my $api = App::OpenZabbix::ZabbixAPI->new( url => $url );
    if (my $auth = $config->{auth}) {
        $api->auth($auth);
    }
    else {
        debugf("login zabbix api...");
        $api->login(%$config);
        pit_set("zabbix", data => {
            %$config,
            url  => $url,
            auth => $api->auth,
        })
    }
    my $cache = Cache::FastMmap->new(
        share_file => File::Spec->tmpdir . "/open_zabbix",
    );
    my $cache_key = ddf([ $api_method, $api_args ]);
    my $results;
    if ( $results = $cache->get($cache_key) ) {
        debugf "hit cache $cache_key";
    }
    else {
        debugf "miss cache $cache_key";
        $results = $api->call($api_method, $api_args);
        $cache->set( $cache_key => $results, $EXPIRES );
    }

    # select by external command
    my $pid = open2(my $out, my $in, $command) or die "Can't open $command: $!";
    for my $r (@$results) {
        $in->print( $printer->($r) );
    }
    $in->close;
    my $selected = <$out>;
    exit 1 unless defined $selected;

    my @parsed = $parser->($selected);

    exec "open", "${url}" . $url_generator->(@parsed);

    die;     # will not be reached here
}

1;
__END__

=encoding utf-8

=head1 NAME

App::OpenZabbix - Quick opener for Zabbix screen using percol or peco.

=head1 SYNOPSIS

    $ open_zabbix_screen [--command peco/percol/or etc.]
      (at first, Config::Pit opens $EDITOR. Enter your Zabbix URL, user, password.)

=head1 DESCRIPTION

App::OpenZabbix is a quick opener for Zabbix screen.

=head1 REQUIREMENTS

percol L<https://github.com/mooz/percol>

peco L<https://github.com/lestrrat/peco>

=head1 LICENSE

Copyright (C) FUJIWARA Shunichiro.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

FUJIWARA Shunichiro E<lt>fujiwara.shunichiro@gmail.comE<gt>

=cut

