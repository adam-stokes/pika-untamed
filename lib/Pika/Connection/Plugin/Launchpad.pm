package Pika::Connection::Plugin::Launchpad;

# ABSTRACT: Launchpad.net Plugin

use Quick::Perl;
use Moose;
use namespace::autoclean;
extends 'Pika::Connection::Plugin';

has opts => (is => 'ro', isa => 'HashRef');

method irc_privmsg ($msg) {
    if ($msg->message =~ /pikapika/) {
        $self->irc->send_srv(
            PRIVMSG => $msg->channel => "HAHA NO SOUP FOR YOU");
    }
    return $self->pass;
}

__PACKAGE__->meta->make_immutable;
