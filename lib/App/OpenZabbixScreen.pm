package App::OpenZabbixScreen;
use 5.008005;
use strict;
use warnings;

use App::OpenZabbixScreen::ZabbixAPI;
use IPC::Open2;
use IO::Handle;
use Encode;
use Config::Pit;
use Log::Minimal;
use Cache::FastMmap;
use File::Spec;
our $VERSION = "0.01";

sub run {
    my $config = pit_get(
        "zabbix", require => {
            "url"      => "zabbix url endpoint (e.g. http://example.com/zabbix/)",
            "user"     => "zabbix username",
            "password" => "zabbix password",
        }
    );

    my $url = delete $config->{url};
    my $api = App::OpenZabbixScreen::ZabbixAPI->new( url => $url );
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
        share_file => File::Spec->tmpdir . "/zabbix_screen",
    );
    my $screens;
    if ( $screens = $cache->get("screens") ) {
        debugf "hit screens cache";
    }
    else {
        debugf "miss screens cache";
        $screens = $api->call("screen.get", { output => "extend" });
        $cache->set( screens => $screens, 300 );
    }

    # select by percol
    my $pid = open2(my $out, my $in, 'percol') or die "Can't open percol: $!";
    for my $s (@$screens) {
        $in->print($s->{screenid}, " ", encode_utf8($s->{name}), "\n");
    }
    $in->close;
    my $selected = <$out>;
    my ($screenid) = split / /, $selected, 2;

    exec "open", "${url}screens.php?elementid=$screenid";

    die;     # will not be reached here
}

1;
__END__

=encoding utf-8

=head1 NAME

App::OpenZabbixScreen - Quick opener for Zabbix screen using percol.

=head1 SYNOPSIS

    $ open_zabbix_screen
      (at first, Config::Pit opens $EDITOR. Enter your Zabbix URL, user, password.)

=head1 DESCRIPTION

App::OpenZabbixScreen is a quick opener for Zabbix screen.

=head1 REQUIREMENTS

percol L<https://github.com/mooz/percol>

=head1 LICENSE

Copyright (C) FUJIWARA Shunichiro.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

FUJIWARA Shunichiro E<lt>fujiwara.shunichiro@gmail.comE<gt>

=cut
