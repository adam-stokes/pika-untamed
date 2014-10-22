package Pika::Connection::Plugin;

# ABSTRACT: Base Package of Plugins

use Quick::Perl;
use Moose;
use namespace::autoclean;

has connection => (
    is     => 'ro',
    isa    => 'Pika::Connection',
    writer => '_connection'
);

has is_enable => (
    traits  => ['Bool'],
    is      => 'rw',
    isa     => 'Bool',
    default => 1,
    handles => {
        enable     => 'set',
        disable    => 'unset',
        _switch    => 'toggle',
        is_disable => 'not'
    }
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

method init($conn) {
    my $pname = ref $self;
    say $pname, " on - ", $self->is_enable ? 'enable' : 'disable'
      if $Pika::DEBUG;
    $self->_connection($conn);
}

__PACKAGE__->meta->make_immutable;
