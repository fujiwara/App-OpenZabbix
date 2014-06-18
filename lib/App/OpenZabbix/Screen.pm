package App::OpenZabbix::Screen;
use strict;
use warnings;
use Encode;

sub run {
    my $class = shift;
    my %args  = @_;
    App::OpenZabbix->_run(
        command => $args{command},
        api_method => "screen.get",
        api_args   => {
            output => "extend",
        },
        printer => sub {
            my $r = shift;
            $r->{screenid} . " " . encode_utf8($r->{name}) . "\n";
        },
        parser => sub {
            my $selected = shift;
            split / /, $selected, 2;
        },
        url_generator => sub {
            my ($screen_id) = @_;
            "screens.php?elementid=${screen_id}";
        },
    );
}

1;
