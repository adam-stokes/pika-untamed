package Pika::Plugin::LeanKit;

# ABSTRACT: LeanKit.net Plugin

use Quick::Perl;
use Moose;
use IRC::Utils qw(:ALL);
use Net::LeanKit;;
use namespace::autoclean;
extends 'Pika::Plugin';

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
    return $self->pass unless $msg->message =~ /^leankit/;

    # listen regex's
    my ($search)      = $msg->message =~ m/^leankit search\s+(\d+)?\s*(.*)$/i;
    my ($add_default) = $msg->message =~ m/^leankit add default (\d+)/i;
    my @add_card = $msg->message =~ m/^leankit add card\s+(\d+)?\s*(.*)$/i;
    my @rm_card =
      $msg->message =~ m/^leankit rm card\s+(\d+)\s+(\d+)?\s*(srsly)/i;
    my ($rm_default)    = $msg->message =~ m/^leankit rm default/i;
    my ($show_default)  = $msg->message =~ m/^leankit show default/i;
    my ($boards)        = $msg->message =~ m/^leankit boards$/i;
    my ($board_by_name) = $msg->message =~ m/^leankit board (.*)/i;
    my ($help)          = $msg->message =~ m/^leankit help$/i;

    $self->do_notice(
        {   channel => $msg->channel,
            message => 'not implemented yet.'
        }
    );

    return $self->pass;
}

__PACKAGE__->meta->make_immutable;
