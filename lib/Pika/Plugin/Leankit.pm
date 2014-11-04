package Pika::Plugin::Leankit;

# ABSTRACT: LeanKit.net Plugin

use Quick::Perl;
use Moose;
use IRC::Utils qw(:ALL);
use Net::LeanKit;
use namespace::autoclean;
extends 'Pika::Plugin';

has store =>
  (is => 'ro', isa => 'Object', lazy => 1, builder => '_build_store');
has email          => (is => 'ro', isa => 'Str');
has password       => (is => 'ro', isa => 'Str');
has account        => (is => 'ro', isa => 'Str');
has def_board_id   => (is => 'rw', isa => 'Int', default => 0);
has def_board_name => (is => 'rw', isa => 'Str');

has lk => (
    is      => 'ro',
    isa     => 'Net::LeanKit',
    lazy    => 1,
    builder => '_build_lk'
);

method _build_store {
  my $session = $self->schema->resultset('Leankit');
  print Dumper($session);
}

method _build_lk {
    return Net::LeanKit->new(
        email    => $self->email,
        password => $self->password,
        account  => $self->account
    );
}

method get_default_board ($channel) {
    my ($stmt, @bind) = $self->db->sql->select(
        -from  => 'leankit_boards',
        -limit => 1
    );
    my $res = $self->db->_run($stmt, \@bind, return_val => 'value_first');
    if ($res) {
        $self->def_board_id($res->[1]);
        $self->def_board_name($res->[2]);
    }
}

=method set_default_board

Sets default board to add cards against in the database

=cut

method set_default_board ($board_id) {
    my ($stmt, @bind);

    my $board =
      $self->lk->getBoards->{content}->first(func { $_->{Id} == $board_id });

    # Check if default board id is set
    if (!$self->def_board_id) {
        ($stmt, @bind) = $self->db->sql->insert(
            -into   => 'leankit_boards',
            -values => {
                board_id   => $board->{Id},
                board_name => $board->{Title}
            }
        );
    }

    # Update if new board id
    if ($self->def_board_id != $board_id) {
        ($stmt, @bind) = $self->db->sql->update(
            -table => 'leankit_boards',
            -set   => {
                board_id   => $board->{Id},
                board_name => $board->{Title}
            },
            -where => {board_id => $self->def_board_id}
        );
    }
    $self->def_board_id($board->{Id});
    $self->def_board_name($board->{Title});
    return $self->db->_run($stmt, \@bind, return_val => 'execute');

}

method rm_default_board ($board_id) {
    my ($stmt, @bind) = $self->db->sql->delete(
        -from  => 'leankit_boards',
        -where => {board_id => $board_id}
    );
    $self->def_board_id(0);
    $self->def_board_name('');

    return $self->db->_run($stmt, \@bind, return_val => 'execute');
}


method irc_privmsg ($msg) {
    return $self->pass unless $msg->message =~ /^leankit/;

    # listen regex's
    my ($search)      = $msg->message =~ m/^leankit search\s+(\d+)?\s*(.*)$/i;
    my ($add_default) = $msg->message =~ m/^leankit add default (\d+)/i;
    my @add_card = $msg->message =~ m/^leankit add card\s+(\d+)?\s*(.*)$/i;
    my @rm_card =
      $msg->message =~ m/^leankit rm card\s+(\d+)\s+(\d+)\s*(srsly)?/i;
    my ($rm_default)    = $msg->message =~ m/^leankit rm default/i;
    my ($show_default)  = $msg->message =~ m/^leankit show default/i;
    my ($boards)        = $msg->message =~ m/^leankit boards$/i;
    my ($board_by_name) = $msg->message =~ m/^leankit board (.*)/i;
    my ($help)          = $msg->message =~ m/^leankit help$/i;

    # Get help
    if ($help) {
        $self->do_notice(
            {   channel => $msg->channel,
                message =>
                  "Usage leankit [add card|rm card|add default|rm default"
                  . "|show default|boards|board]"
            }
        );
        return $self->pass;
    }

    # All boards action
    if ($boards) {
        $self->lk->getBoards->{content}->sort->foreach(
            func {
                $self->do_privmsg(
                    {   channel => $msg->channel,
                        message =>
                          sprintf("(%s) %s", $_[0]->{Id}, $_[0]->{Title})
                    }
                );
            }
        );
        return $self->pass;
    }

    # Fuzzy search boards action
    if ($board_by_name) {
        my $board_query =
          $self->lk->getBoards->{content}
          ->grep(func { $_->{Title} =~ /$board_by_name/i });
        $self->do_privmsg(
            {   channel => $msg->channel,
                message => "Fuzzy searching $board_by_name ..."
            }
        );

        $board_query->foreach(
            func {
                $self->do_privmsg(
                    {   channel => $msg->channel,
                        message =>
                          sprintf("(%s) %s", $_[0]->{Id}, $_[0]->{Title})
                    }
                );
            }
        );
        return $self->pass;
    }

    # Show default board action
    if ($show_default) {
        my ($message);
        if ($self->def_board_id) {
            $message = sprintf("Default board (%s) %s",
                $self->def_board_id, $self->def_board_name);
        }
        else {
            $message = "No default board found, please set one ..";
        }
        $self->do_privmsg(
            {   channel => $msg->channel,
                message => $message
            }
        );
        return $self->pass;
    }

    # Remove default board action
    if ($rm_default) {
        if (!$self->def_board_id) {
            $self->do_privmsg(
                {   channel => $msg->channel,
                    message => 'No default board set ..'
                }
            );
            return $self->pass;

        }
        $self->rm_default_board($self->def_board_id);
        $self->do_privmsg(
            {   channel => $msg->channel,
                message => 'Default board unset ..'
            }
        );
        return $self->pass;
    }
    if ($add_default) {
        $self->set_default_board($add_default);
        $self->do_privmsg(
            {   channel => $msg->channel,
                message => 'Set default board id ' . $add_default
            }
        );
        return $self->pass;
    }
    if (@add_card) {
        my ($add_card_boardid, $add_card_msg) = @add_card;
        my ($res, $message);
        if (!$add_card_boardid && $self->def_board_id) {
            $add_card_boardid = $self->def_board_id;
        }

        if (!$add_card_boardid) {
            $self->do_privmsg(
                {   channel => $msg->channel,
                    message => 'No default board set and no board id found ..'
                }
            );
            return $self->pass;
        }

        # Retrieve card type and drop lane
        my $board = $self->lk->getBoard($add_card_boardid);
        my $cardType =
          $board->{content}->{CardTypes}->first(func { $_->{IsDefault} });
        my $lane =
          $board->{content}->{Lanes}->first(func { $_->{IsDefaultDropLane} });
        if (!$lane) {
            $lane = $board->{content}->{Backlog};
        }

        my $card_attributes = {
            'TypeId'         => $cardType->{Id},
            'Title'          => $add_card_msg,
            'ExternalCardId' => time,
            'Priority'       => 1
        };

        $res = $self->lk->addCard($board->{content}->{Id},
            $lane->{Id}, 0, $card_attributes);

        if ($res->{code} == 201) {
            $message = sprintf(
                "Added (%s) to board (%s) lane (%s) type (%s) card_id (%s)",
                BOLD . $add_card_msg . NORMAL,
                UNDERLINE . BOLD . $board->{content}->{Title} . NORMAL,
                BOLD . $lane->{Title} . NORMAL,
                BOLD . $cardType->{Name} . BOLD,
                BOLD . $res->{content}->{CardId} . BOLD
            );
        }
        else {
            $message = sprintf("Problem adding card (%s)", $res->{status});
        }
        $self->do_privmsg(
            {   channel => $msg->channel,
                message => $message
            }
        );
        return $self->pass;

    }
    if (@rm_card) {
        my ($board_id, $card_id, $serious) = @rm_card;
        my ($res);
        if (!$serious) {
            $self->do_privmsg(
                {   channel => $msg->channel,
                    message =>
                      "I dont trust you, add 'srsly' to the end if you really wanted this."
                }
            );
            return $self->pass;
        }
        $res = $self->lk->deleteCard($board_id, $card_id);
        if ($res->{code} == 203) {
            $self->do_privmsg(
                {   channel => $msg->channel,
                    message => "I have purged $card_id, you may rest e-z."
                }
            );
        }
        else {
            $self->do_privmsg(
                {   channel => $msg->channel,
                    message => "Couldn't destroy $card_id: " . $res->{status}
                }
            );
        }
        return $self->pass;
    }

    return $self->pass;
}

__PACKAGE__->meta->make_immutable;
