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
    while (my ($name, $conn) = each %{$self->config->{connection}}) {
        confess "No network specified for connection '$name'"
          unless $conn->{network};
        say "Loading connection: $name" if $Pika::DEBUG;
        my $network = $self->config->{network}->{$conn->{network}};
        my $connection =
          Pika::Connection->new({%$network, %$conn, irc => $self->irc});
        push @{$connections}, $connection;
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
