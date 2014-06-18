package App::OpenZabbix::Host;
use strict;
use warnings;
use Encode;

sub run {
    my $class = shift;
    my %args  = @_;
    App::OpenZabbix->_run(
        command => $args{command},
        api_method => "host.get",
        api_args   => {
            output => "extend",
        },
        printer => sub {
            my $r = shift;
            $r->{hostid} . " " . encode_utf8($r->{name}) . "\n";
        },
        parser => sub {
            my $selected = shift;
            split / /, $selected, 2;
        },
        url_generator => sub {
            my ($host_id) = @_;
            "hosts.php?form=update&hostid=${host_id}";
        },
    );
}

1;
