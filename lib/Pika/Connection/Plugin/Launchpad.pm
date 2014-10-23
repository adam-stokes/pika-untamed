package Pika::Connection::Plugin::Launchpad;

# ABSTRACT: Launchpad.net Plugin

use Quick::Perl;
use Moose;
use namespace::autoclean;
extends 'Pika::Connection::Plugin';

has opts => (is => 'ro', isa => 'HashRef');

method irc_privmsg ($message) {
    if ($message =~ /pikapika/) {
        $self->irc->irc_privmsg(
            {   channel => $message->channel,
                message => "HAHA NO SOUP FOR YOU"
            }
        );
    }
    return $self->pass;
}

__PACKAGE__->meta->make_immutable;
