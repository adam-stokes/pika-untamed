package Pika::Connection::Plugin::Join;

# ABSTRACT: Auto Join Channel Plugin on Pika


use Moose;
extends 'Pika::Connection::Plugin';
with 'MooseX::Role::Pluggable::Plugin';

has channels => (
    is  => 'ro',
    isa => 'ArrayRef',
);

sub on_connect {
    my ($self) = @_;
    $self->connection->irc->send_srv(JOIN => $_) for @{$self->channels};
    return $self->pass;
}

__PACKAGE__->meta->make_immutable;
