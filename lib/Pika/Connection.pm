package Pika::Connection;

# ABSTRACT: IRC Connection

use PikaLove;
use AnyEvent::IRC::Client;
use Const::Fast;
use Type::Utils qw(class_type);
use Types::Standard qw(Str ClassName HashRef ArrayRef);
use Moo;
use namespace::clean;

const my $IRC_DEFAULT_PORT => 6667;

has irc => (
    is  => 'rw',
    isa => class_type('AnyEvent::IRC::Client')
);

has nickname => (
    is       => 'ro',
    isa      => Str,
    required => 1
);

has password => (
    is  => 'ro',
    isa => 'Str',
);

has port => (
    is      => 'ro',
    isa     => Str,
    default => $IRC_DEFAULT_PORT,
);

has server => (
    is       => 'ro',
    isa      => Str,
    required => 1
);

has username => (
    is         => 'ro',
    isa        => Str,
    lazy_build => 1
);

has channels => (
    is  => 'ro',
    isa => ArrayRef[Str],
);

# plugin's preference from configfle,
# Pika::Connection::Plugin using it when all the plugins are initialize.
has 'plugin' => (
    traits  => ['Hash'],
    is      => 'ro',
    isa     => 'HashRef',
    handles => {get_args => 'get',},
);

sub _build_username { $_[0]->nickname }

sub run {
	my $self = shift;
	foreach my $plugin (@{ $self->plugin_list }) { # WARNING: DO NOT CHANGE: plugin_list is lazy_build. it means initialize all the plugins at here.
		$plugin->init($self);
	}

	my $irc = AnyEvent::IRC::Client->new();
	$self->irc($irc);

	$irc->reg_cb(disconnect => sub { $self->occur_event('on_disconnect'); });
	$irc->reg_cb(connect => sub {
		my ($con, $err) = @_;
		if (defined $err) {
			warn "connect error: $err\n";
			return;
		}

		warn "connected to: " . $self->server . ":" . $self->port if $Pika::DEBUG;
		$self->occur_event('on_connect');
	});

	$irc->reg_cb(irc_privmsg => sub {
		my ($con, $raw) = @_;
		my $message = Horris::Message->new(
			channel => $raw->{params}->[0], 
			message => $raw->{params}->[1], 
			from	=> $raw->{prefix}
		);

		$self->occur_event('irc_privmsg', $message) if $message->from->nickname ne $self->nickname; # loop guard
	});

	$irc->reg_cb(privatemsg => sub {
		my ($con, $nick, $raw) = @_;
		my $message = Horris::Message->new(
			channel => '', 
			message => $raw->{params}->[1], 
			from    => defined $raw->{prefix} ? $raw->{prefix} : '', 
		);
		$self->occur_event('on_privatemsg', $nick, $message);
	});

	$irc->connect($self->server, $self->port, {
		nick => $self->nickname,
		user => $self->username,
		password => $self->password,
		timeout => 1,
	});
}

sub irc_notice {
    my ($self, $args) = @_;
    $self->send_srv(NOTICE => $args->{channel} => $args->{message});
}

sub irc_privmsg {
    my ($self, $args) = @_;
    $self->send_srv(PRIVMSG => $args->{channel} => $args->{message});
}

sub irc_mode {
    my ($self, $args) = @_;
    $self->send_srv(MODE => $args->{channel} => $args->{mode}, $args->{who});
}

sub occur_event {
	my ($self, $event, @args) = @_;
	my $plugins = $self->plugin_hash;
	foreach my $plugin_name (@{ $self->plugins }) {
		my $plugin = $plugins->{$plugin_name};
		my $rev = $plugin->$event(@args) if $plugin->can($event);

		# Don't try next plugin for $event if current plugin returns true 
		last if defined $rev and $rev;
	}
}
