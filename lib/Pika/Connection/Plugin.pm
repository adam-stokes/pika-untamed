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

method BUILD {
  say "loading ". ref $self;
}

__PACKAGE__->meta->make_immutable;
