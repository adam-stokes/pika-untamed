package Pika::Connection;

# ABSTRACT: IRC Connection

use Quick::Perl;
use Moose;
use Moose::Util qw(apply_all_roles is_role);
use Module::Runtime qw(is_module_name use_package_optimistically);
use Pika::Message;
extends('Pika::DB');
use namespace::autoclean;

const my $IRC_DEFAULT_PORT => 6667;

has irc      => (is => 'ro', isa => 'AnyEvent::IRC::Client');
has nickname => (is => 'ro', isa => 'Str', required => 1);
has realname => (is => 'ro', isa => 'Str', required => 1);
has password => (is => 'ro', isa => 'Str',);
has ssl      => (is => 'ro', isa => 'Bool');
has port     => (is => 'ro', isa => 'Str', default => $IRC_DEFAULT_PORT);
has server   => (is => 'ro', isa => 'Str', required => 1);
has username =>
  (is => 'ro', isa => 'Str', lazy => 1, builder => '_build_username');
has plugins => (is => 'ro', isa => 'HashRef');
has loaded_plugins => (
    traits  => ['Array'],
    is      => 'ro',
    isa     => 'ArrayRef[Pika::Plugin]',
    lazy    => 1,
    builder => '_build_loaded_plugins',
    handles => {
        all_plugins => 'elements',
        push_plugin => 'push'
    }
);


method _build_username { $self->nickname }

method _build_loaded_plugins {
    my $plugins = +[];
    my ($rev, $class, $plugin);

    # TODO: load this once and just access the method events
    foreach my $plugin_name (keys %{$self->plugins}) {
        $class = "Pika::Plugin::$plugin_name";
        die "Failed to find plugin $plugin_name"
          unless is_module_name($class);
        $plugin =
          use_package_optimistically($class)
          ->new({%{$self->plugins->{$plugin_name}}, irc => $self->irc});
        push @{$plugins}, $plugin;
    }
    return $plugins;
}

method run {
    $self->irc->reg_cb(disconnect => sub { $self->occur_event('on_disconnect'); });
    $self->irc->reg_cb(
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

    $self->irc->reg_cb(
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

    $self->irc->reg_cb(
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

    $self->irc->enable_ssl() if $self->ssl;
    $self->irc->connect(
        $self->server,
        $self->port,
        {   nick     => $self->nickname,
            user     => $self->username,
            password => $self->password,
            real     => $self->realname
        }
    );
}

method occur_event ($event, @args) {
    my ($rev);
    foreach my $plugin ($self->all_plugins) {
        $rev = $plugin->$event(@args) if $plugin->can($event);

        # Don't try next plugin for $event if current plugin returns true
        last if defined $rev and $rev;
    }
}

__PACKAGE__->meta->make_immutable;
1;
