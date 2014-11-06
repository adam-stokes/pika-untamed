package Pika::Plugin::Join;

# ABSTRACT: Auto Join Channel Plugin on Pika

use Quick::Perl;
use Moose;
use namespace::autoclean;
extends 'Pika::Plugin';

has channels => (is => 'ro', isa => 'ArrayRef');

method on_connect {
    $self->irc->send_srv("JOIN", $_) for @{$self->channels};
    return $self->pass;
}

__PACKAGE__->meta->make_immutable;
1;
