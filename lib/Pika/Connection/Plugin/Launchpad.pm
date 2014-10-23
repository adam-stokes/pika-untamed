package Pika::Connection::Plugin::Launchpad;

# ABSTRACT: Launchpad.net Plugin

use Quick::Perl;
use Moose;
use List::AllUtils qw(first);
use IRC::Utils qw(:ALL);
use Net::Launchpad::Client;
use Net::Launchpad::Model;
use namespace::autoclean;
extends 'Pika::Connection::Plugin';

has consumer_key        => (is => 'ro', isa => 'Str');
has access_token        => (is => 'ro', isa => 'Str');
has access_token_secret => (is => 'ro', isa => 'Str');
has lp                  => (
    is      => 'ro',
    isa     => 'Net::Launchpad::Client',
    lazy    => 1,
    builder => '_build_lpc'
);

has model => (
    is      => 'ro',
    isa     => 'Net::Launchpad::Model',
    lazy    => 1,
    builder => '_build_model'
);

method _build_model {
    return Net::Launchpad::Model->new(lpc => $self->lp);
}

method _build_lpc {
    return Net::Launchpad::Client->new(
        consumer_key        => $self->consumer_key,
        access_token        => $self->access_token,
        access_token_secret => $self->access_token_secret
    );
}

method irc_privmsg ($msg) {
    if (my (@bug_id) = $msg->message =~ m/(bug|#|LP|lp)\s*#?(\d{6,})/i) {
        my $bug = $self->model->bug($bug_id[1]);

        $self->do_notice(
            {   channel => $msg->channel,
                message => join(" ",
                    '('
                      . UNDERLINE
                      . BOLD
                      . $bug->result->{information_type}
                      . NORMAL . ')',
                    $bug->result->{title},
                    $bug->result->{web_link})
            }
        );
    }
    return $self->pass;
}

__PACKAGE__->meta->make_immutable;
