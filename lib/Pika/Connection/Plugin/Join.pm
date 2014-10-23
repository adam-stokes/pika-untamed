package Pika::Connection::Plugin::Join;

# ABSTRACT: Auto Join Channel Plugin on Pika

use Quick::Perl;
use Moose;
use namespace::autoclean;
extends 'Pika::Connection::Plugin';
with 'MooseX::Role::Pluggable::Plugin';

has channels => (
    is  => 'ro',
    isa => 'ArrayRef',
);

method on_connect {
  print Dumper($self->channels);
    $self->connection->irc->send_srv("JOIN", '#pika-test');
    return $self->pass;
}

__PACKAGE__->meta->make_immutable;
