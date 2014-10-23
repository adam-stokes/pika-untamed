package Pika;

# ABSTRACT: my tiny bot

use Quick::Perl;
use Moose;
use AnyEvent;
use AnyEvent::IRC::Client;
use Pika::Connection;
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
method _build_irc { AnyEvent::IRC::Client->new }

method _build_connections {
    my $connections = +[];
    my $plugins     = +[];
    foreach my $conn (@{$self->config->{connection}}) {
        confess "No networks found."
          unless $conn->{network};

        #foreach my $network (keys %{$conn->{network}}) {
        $conn->{network}->each(
            func {
                print Dumper($_);
                say "Loading connection: $_" if $Pika::DEBUG;
                my $server = $self->config->{network}->{$_};

                # handle registered plugins
                $server->{plugins}->foreach(
                    func {
                        push @{$plugins}, $self->config->{plugins}->{$_}
                    }
                );

                my $connection =
                  Pika::Connection->new(
                    {%$server, %$self->config->{plugins}, irc => $self->irc});
                $connections->push($connection);

            }
        );

        #}
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
