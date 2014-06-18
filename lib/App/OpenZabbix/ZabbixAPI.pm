package App::OpenZabbixScreen::ZabbixAPI;

use strict;
use warnings;
use Mouse;
use Try::Tiny;
use JSON;
use HTTP::Request::Common;
use LWP::UserAgent;
use Log::Minimal;

has ua => (
    is      => "rw",
    default => sub {
        LWP::UserAgent->new(
            ssl_opts => {
                verify_hostname => 0,
                SSL_verify_mode => "SSL_VERIFY_NONE",
            },
            timeout  => 180,
        );
    }
);
has auth   => ( is => "rw", isa => "Str", );
has id     => ( is => "rw", isa => "Int", default => 1 );
has url    => ( is => "rw", isa => "Str", );
has cookie => ( is => "rw", isa => "Str", );

sub login {
    my $self = shift;
    my %params = @_;
    my $r = {
        method => "user.login",
        params => \%params,
        auth   => undef,
    };
    $self->auth( $self->_request($r) );
    debugf "auth: %s", $self->auth;

    $self->auth;
}

sub call {
    my ($self, $method, $params) = @_;
    my $r = {
        method  => $method,
        params  => $params,
        auth    => $self->auth,
    };
    $self->_request($r);
}

sub _request {
    my $self = shift;
    my $r    = shift;
    $r->{id} = $self->{id}++;
    $r->{jsonrpc} = "2.0";
    my $json = encode_json $r;
    my $req = POST $self->url . "api_jsonrpc.php",
        "Content-Type"   => "application/json-rpc",
        "Content-Length" => length($json),
        "Content"        => $json,
    ;
    my $res = $self->ua->request($req);
    my $result;
    try {
        $result = decode_json($res->content)->{result};
    }
    catch {
        my $e = $_;
        critf("decode json failed. %s\nreq: %s", $e, ddf $req);
    };
    die "request failed" unless $result;
    return $result;
}

sub get {
    my $self = shift;
    my $url  = shift;
    $url = $self->url . $url
        unless $url =~ m{^https?://};
    my $req  = GET $url;
    debugf $req->as_string;
    $self->ua->request($req);
}

1;
