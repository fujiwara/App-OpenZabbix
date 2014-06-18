package App::OpenZabbix::Maintenance;
use strict;
use warnings;
use Encode;

sub run {
    my $class = shift;
    my %args  = @_;
    App::OpenZabbix->run(
        command => $args{command},
        api_method => "maintenance.get",
        api_args   => {
            output => "extend",
        },
        printer => sub {
            my $r = shift;
            $r->{maintenanceid} . " " . encode_utf8($r->{name}) . "\n";
        },
        parser => sub {
            my $selected = shift;
            split / /, $selected, 2;
        },
        url_generator => sub {
            my ($maintenance_id) = @_;
            "maintenance.php?form=update&maintenanceid=${maintenance_id}";
        },
    );
}

1;
