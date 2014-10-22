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

sub init {
    my ($self, $conn) = @_;
    my $pname = ref $self;
    print $pname, " on - ", $self->is_enable ? 'enable' : 'disable', "\n"
      if $Pika::DEBUG;
    $self->_connection($conn);
}

around BUILDARGS => sub {
    my ($orig, $class, @args) = @_;
    my $self         = $class->$orig(@args);
    my @reserve_keys = qw/parent name/;
    while (my ($key, $value) = each %{$self->{parent}{plugin}{$self->{name}}})
    {
        confess 'keys [' . join(', ', @reserve_keys) . "] are reserved\n"
          if grep { $key eq $_ } @reserve_keys;
        $self->{$key} = $value;
    }

    return $self;
};

__PACKAGE__->meta->make_immutable;
