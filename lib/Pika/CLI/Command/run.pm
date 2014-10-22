package Pika::CLI::Command::run;

# ABSTRACT: Pika runner

use Quick::Perl;
use Moose;
use Pika;
use namespace::autoclean;
extends 'MooseX::App::Cmd::Command';
with qw/MooseX::SimpleConfig/;

has '+configfile' => (default => '/etc/pika.conf');

has config => (
    traits => ['NoGetopt'],
    is     => 'ro',
    isa    => 'HashRef',
);

around _usage_format => sub {
    return "usage: %c %o (run 'perldoc " . __PACKAGE__ . "' for more info)";
};

func config_any_args {
    return {driver_args => {General => {-LowerCaseNames => 1,}}};
}

method execute($opt, $args) {
    my $pika = Pika->new(config => $self->config);
    $pika->run;
}

__PACKAGE__->meta->make_immutable;
