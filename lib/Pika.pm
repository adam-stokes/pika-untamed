package Pika;

# ABSTRACT: my tiny bot

use Quick::Perl;
use Moose;
use AnyEvent;
use AnyEvent::IRC::Client;
use Pika::Connection;
extends('Pika::DB');
use namespace::autoclean;

const our $DEBUG => $ENV{PERL_PIKA_DEBUG};

has cv  => (is => 'ro', lazy => 1, builder => '_build_condvar');
has irc => (is => 'ro', lazy => 1, builder => '_build_irc');

has connections => (
    traits  => ['Array'],
    is      => 'ro',
    isa     => 'ArrayRef[Pika::Connection]',
    lazy    => 1,
    builder => '_build_connections',
    handles => {
        all_connections => 'elements',
        push_connection => 'push'
    }
);

has config => (
    is       => 'ro',
    isa      => 'HashRef',
    required => 1
);

method _build_condvar { AnyEvent->condvar }
method _build_irc     { AnyEvent::IRC::Client->new }

method _build_connections {
    my $connections = +[];
    my $plugins     = +{};
    foreach my $conn (@{$self->config->{connection}}) {
        confess "No networks found."
          unless $conn->{network};

        $conn->{network}->each(
            func {
                say "Loading connection: $_[0]" if $Pika::DEBUG;

                # Add server to database
                my $db_conn = $self->schema->resultset('Server')
                  ->find({server_name => $_[0]});
                my $server = $_[1];
                if (!$db_conn) {
                    $self->schema->resultset('Server')->create(
                        {   server_name    => $_[0],
                            server_network => $server->{server}
                        }
                    );
                }

                # handle registered plugins
                $server->{plugins}->each(
                    func {
                        $plugins->{ucfirst $_[0]} =
                          $server->{plugins}->{$_[0]};
                    }
                );
                my $connection =
                  Pika::Connection->new(
                    {%$server, plugins => $plugins, irc => $self->irc});
                $connections->push($connection);

            }
        );
    }
    return $connections;
}


method run {
    my $cv = $self->cv;
    $cv->begin;
    foreach my $conn ($self->all_connections) {
        $conn->run;
    }
    $cv->recv;
}

__PACKAGE__->meta->make_immutable;
