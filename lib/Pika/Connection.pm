package Pika::Connection;

# ABSTRACT: IRC Connection

use Quick::Perl;
use Moose;
use Pika::Message;
use AnyEvent::IRC::Client;
use namespace::autoclean;

with 'MooseX::Role::Pluggable';

const my $IRC_DEFAULT_PORT => 6667;

has irc => (
    is      => 'rw',
    isa     => 'AnyEvent::IRC::Client',
    handles => {send_srv => 'send_srv'}
);


has nickname => (
    is       => 'ro',
    isa      => 'Str',
    required => 1
);

has realname => (
    is       => 'ro',
    isa      => 'Str',
    required => 1
);

has password => (
    is  => 'ro',
    isa => 'Str',
);

has ssl => (
    is  => 'ro',
    isa => 'Bool'
);

has port => (
    is      => 'ro',
    isa     => 'Str',
    default => $IRC_DEFAULT_PORT,
);

has server => (
    is       => 'ro',
    isa      => 'Str',
    required => 1
);

has username => (
    is         => 'ro',
    isa        => 'Str',
    lazy_build => 1
);

has channels => (
    is  => 'ro',
    isa => 'ArrayRef[Str]',
);

# plugin's preference from configfle,
# Pika::Connection::Plugin using it when all the plugins are initialize.
has 'plugin' => (
    traits  => ['Hash'],
    is      => 'ro',
    isa     => 'HashRef',
    handles => {get_args => 'get'},
);

method _build_username { $self->nickname }

method run {
    foreach my $plugin (@{$self->plugin_list})
    { # WARNING: DO NOT CHANGE: plugin_list is lazy_build. it means initialize all the plugins at here.
        $plugin->init($self);
    }

    my $irc = AnyEvent::IRC::Client->new();
    $self->irc($irc);

    $irc->reg_cb(disconnect => sub { $self->occur_event('on_disconnect'); });
    $irc->reg_cb(
        connect => sub {
            my ($con, $err) = @_;
            if (defined $err) {
                warn "connect error: $err\n";
                return;
            }

            say "connected to: " . $self->server . ":" . $self->port
              if $Pika::DEBUG;
            $self->occur_event('on_connect');
        }
    );

    $irc->reg_cb(
        irc_privmsg => sub {
            my ($con, $raw) = @_;
            my $message = Pika::Message->new(
                channel => $raw->{params}->[0],
                message => $raw->{params}->[1],
                from    => $raw->{prefix}
            );

            $self->occur_event('irc_privmsg', $message)
              if $message->from->nickname ne $self->nickname;    # loop guard
        }
    );

    $irc->reg_cb(
        privatemsg => sub {
            my ($con, $nick, $raw) = @_;
            my $message = Pika::Message->new(
                channel => '',
                message => $raw->{params}->[1],
                from    => defined $raw->{prefix} ? $raw->{prefix} : '',
            );
            $self->occur_event('on_privatemsg', $nick, $message);
        }
    );

    $irc->enable_ssl() if $self->ssl;
    $irc->connect(
        $self->server,
        $self->port,
        {   nick     => $self->nickname,
            user     => $self->username,
            password => $self->password,
            real => $self->realname
        }
    );
}

method irc_notice ($args) {
    $self->send_srv(NOTICE => $args->{channel} => $args->{message});
}

method irc_privmsg ($args) {
    $self->send_srv(PRIVMSG => $args->{channel} => $args->{message});
}

method irc_mode ($args) {
    $self->send_srv(MODE => $args->{channel} => $args->{mode}, $args->{who});
}

method occur_event($event, @args) {
    my $plugins = $self->plugin_hash;
    my ($rev);
    foreach my $plugin_name (@{$self->plugins}) {
        my $plugin = $plugins->{$plugin_name};
        $rev = $plugin->$event(@args) if $plugin->can($event);

        # Don't try next plugin for $event if current plugin returns true
        last if defined $rev and $rev;
    }
}

__PACKAGE__->meta->make_immutable;
