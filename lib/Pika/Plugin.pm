package Pika::Plugin;

# ABSTRACT: Base Package of Plugins

use Quick::Perl;
use Moose;
use Pika::Plugin::DB;
use Log::Dispatch;
use namespace::autoclean;

has irc => (
    is  => 'ro',
    isa => 'AnyEvent::IRC::Client'
);

has log => (
    is      => 'ro',
    isa     => 'Log::Dispatch',
    builder => '_build_log'
);


has db => (
    is      => 'ro',
    isa     => 'Pika::Plugin::DB',
    builder => '_build_db'
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

method _build_db {
    return Pika::Plugin::DB->new;
}

method _build_log {
    return Log::Dispatch->new(
        outputs => [
            [   'Screen',
                min_level => 'debug',
                stderr    => 1,
                newline   => 1
            ]
        ],
    );
}

method do_notice ($args) {
    $self->irc->send_srv(NOTICE => $args->{channel} => $args->{message});
}

method do_privmsg ($args) {
    $self->irc->send_srv(PRIVMSG => $args->{channel} => $args->{message});
}

method do_mode ($args) {
    $self->irc->send_srv(
        MODE => $args->{channel} => $args->{mode},
        $args->{who}
    );
}

__PACKAGE__->meta->make_immutable;
