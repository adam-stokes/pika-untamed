package Pika::Plugin::Leankit;

# ABSTRACT: LeanKit.net Plugin

use Quick::Perl;
use Moose;
use IRC::Utils qw(:ALL);
use Net::LeanKit;
use namespace::autoclean;
extends 'Pika::Plugin';

has email    => (is => 'ro', isa => 'Str');
has password => (is => 'ro', isa => 'Str');
has account  => (is => 'ro', isa => 'Str');

has lk => (
    is      => 'ro',
    isa     => 'Net::LeanKit',
    lazy    => 1,
    builder => '_build_lk'
);

method BUILD {
    my $lk_boards_sql = <<EOF;
CREATE TABLE IF NOT EXISTS leankit_boards (
	id INTEGER PRIMARY KEY ASC,
	board_id INTEGER,
	board_name TEXT
);
EOF
    $self->db->process_plugin_sql($lk_boards_sql);
}


method get_default_board {
    my ($stmt, @bind) = $self->db->sql->select(
        -from  => 'leankit_boards',
        -limit => 1
    );
    return $self->db->_run($stmt, \@bind, return_val => 'value_first');
}

=method set_default_board

Sets default board to add cards against in the database

=cut

method set_default_board ($board_id) {
    my ($stmt, @bind);
    my $board = $self->lk->getBoards->first(func { $_->{Id} == $board_id });
    my $curr_board = $self->get_default_board;
    if (!$curr_board) {
        ($stmt, @bind) = $self->db->sql->insert(
            -into => 'leankit_boards',
            -values =>
              {board_id => $board->{Id}, board_name => $board->{Title}}
        );
        return $self->db->_run($stmt, \@bind, return_val => 'execute');
    }
    if ($curr_board->[1] != $board_id) {
        ($stmt, @bind) = $self->db->sql->update(
            -table => 'leankit_boards',
            -set => {board_id => $board->{Id}, board_name => $board->{Title}},
            -where => {id => $curr_board->{id}}
        );
        return $self->db->_run($stmt, \@bind, return_val => 'execute');
    }
}

method rm_default_board ($board_id) {
    my ($stmt, @bind) = $self->db->sql->delete(
        -from  => 'leankit_boards',
        -where => {board_id => $board_id}
    );
    return $self->db->_run($stmt, \@bind, return_val => 'execute');
}


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
    if ($boards) {
        $self->lk->getBoards->sort->foreach(
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
    if ($board_by_name) {
        my $board_query =
          $self->lk->getBoards->grep(func { $_->{Title} =~ /$board_by_name/i }
          );
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
    if ($show_default) {
        my $res = $self->get_default_board;
        my ($message);
        if ($res) {
            $message = sprintf("Default board (%s) %s", $res->[1], $res->[2]);
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
    if ($rm_default) {
        my $curr_board = $self->get_default_board;
        $self->rm_default_board($curr_board->[1])
          unless !$curr_board;
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
      # TODO: Query for default drop lane
        # my ($add_card_boardid, $add_card_msg) = @add_card;
        # my $res = $self->get_default_board;
        # if (!$add_card_boardid and !$res) {
        #     $self->do_privmsg(
        #         {   channel => $msg->channel,
        #             message => 'No default board set and no board id found ..'
        #         }
        #     );
        #     return $self->pass;
        # }
        # elsif ($add_card_boardid) {
        #     $self->add_card($add_card_boardid, $add_card_msg);
        # }
        # else {
        #     $self->add_card($res->[1], $add_card_msg);
        # }
        # $self->do_privmsg(
        #     {   channel => $msg->channel,
        #         message => sprintf("Added (%s) to board (%s)",
        #             $add_card_msg, $res->[2])
        #     }
        # );

        return $self->pass;
    }
    if (@rm_card) {
        $self->do_privmsg(
            {   channel => $msg->channel,
                message => 'not implemented yet.'
            }
        );
        return $self->pass;
    }

    return $self->pass;
}

__PACKAGE__->meta->make_immutable;
