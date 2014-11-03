package Pika::DB::Schema::Result::Channel;

# ABSTRACT: irc channel tracking

use Quick::Perl;
use DBIx::Class::Candy -autotable => v1;

primary_column channel_id => {
    data_type         => 'INT',
    is_auto_increment => 1
};

column server_id => {data_type => 'INT'};

unique_column channel_name => {
    data_type => 'VARCHAR',
    size      => 255
};

belongs_to server => 'Pika::DB::Schema::Result::Server', 'server_id';
has_many plugins  => 'Pika::DB::Schema::Result::Plugin', 'channel_id';

1;
