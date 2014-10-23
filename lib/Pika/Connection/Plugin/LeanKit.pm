package Pika::Connection::Plugin::LeanKit;

# ABSTRACT: LeanKit.net Plugin

use Quick::Perl;
use Moose;
use IRC::Utils qw(:ALL);
use Net::LeanKit;;
use namespace::autoclean;
extends 'Pika::Connection::Plugin';

has email    => (is => 'ro', isa => 'Str');
has password => (is => 'ro', isa => 'Str');
has account  => (is => 'ro', isa => 'Str');
has lk       => (
    is      => 'ro',
    isa     => 'Net::LeanKit',
    lazy    => 1,
    builder => '_build_lk'
);

method _build_lk {
    return Net::LeanKit->new(
        email    => $self->email,
        password => $self->password,
        account  => $self->account
    );
}

method irc_privmsg ($msg) {
    $self->do_notice(
        {   channel => $msg->channel,
            message => 'not implemented yet.'
        }
    );
    return $self->pass;
}

__PACKAGE__->meta->make_immutable;
