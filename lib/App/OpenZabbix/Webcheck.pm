package App::OpenZabbix::Webcheck;
use strict;
use warnings;
use Encode;

sub run {
    my $class = shift;
    my %args  = @_;
    App::OpenZabbix->_run(
        command => $args{command},
        api_method => "webcheck.get",
        api_args   => {
            output => "extend",
        },
        printer => sub {
            my $r = shift;
            $r->{httptestid} . " " . encode_utf8($r->{name}) . "\n";
        },
        parser => sub {
            my $selected = shift;
            split / /, $selected, 2;
        },
        url_generator => sub {
            my ($webcheck_id) = @_;
            "httpdetails.php?httptestid=${webcheck_id}";
        },
    );
}

1;
