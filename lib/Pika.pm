package Pika;

# ABSTRACT: my tiny bot

use PikaLove;
use Pika::Connection;

use AnyEvent;
use Const::Fast;
use Types::Standard qw(ArrayRef HashRef);
use App::Cmd::Setup -app;
use Moo;
use namespace::clean;

const our $DEBUG => $ENV{PERL_PIKA_DEBUG};

has condvar => (
    is         => 'ro',
    lazy_build => 1
);

has connections => (
    is         => 'ro',
    isa        => 'ArrayRef[Pika::Connection]',
    lazy_build => 1,
    handles    => {
        all_connections => 'elements',
        push_connection => 'push'
    }
);

has config => (
    is       => 'ro' isa => 'HashRef',
    required => 1
);

method _build_condvar { AnyEvent->condvar }

method _build_connections {
    my @connections;
    while (my ($name, $conn) = each %{$self->{config}{connection}}) {
        confess "No network specified for connection '$name'"
          unless $conn->{network};
        print "Connection Name: $name\n" if $Pika::DEBUG;

        my $network    = $self->{config}{network}->{$conn->{network}};
        my $connection = Pika::Connection->new(
            {   %$network, %$conn,
                plugins => $conn->{loadmodule} ? $conn->{loadmodule} : [],
            }
        );
        push @connections, $connection;
    }

    return \@connections;
}

method run {
    my $cv = $self->condvar;
    $cv->begin;
    foreach my $conn ($self->all_connections) {
        $conn->run;
    }
    $cv->recv;
}
