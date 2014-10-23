package Pika::Connection::Plugin;

# ABSTRACT: Base Package of Plugins

use Quick::Perl;
use Moose;
use namespace::autoclean;

has irc => (
    is     => 'ro',
    isa    => 'AnyEvent::IRC::Client'
);

has pass => (
    is      => 'ro',
    isa     => 'Int',
    default => 0,
);

has done => (
    is      => 'ro',
    isa     => 'Int',
    default => 1,
);

method do_notice ($args) {
    $self->irc->send_srv(NOTICE => $args->{channel} => $args->{message});
}

method do_privmsg ($args) {
    $self->irc->send_srv(PRIVMSG => $args->{channel} => $args->{message});
}

method do_mode ($args) {
    $self->irc->send_srv(MODE => $args->{channel} => $args->{mode}, $args->{who});
}

__PACKAGE__->meta->make_immutable;
