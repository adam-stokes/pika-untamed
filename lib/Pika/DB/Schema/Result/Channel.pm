package Pika::DB::Schema::Result::Channel;

# ABSTRACT: irc channel tracking

use Quick::Perl;
use DBIx::Class::Candy -autotable => v1;

primary_column channel_id => {
    data_type         => 'INT',
    is_auto_increment => 1
};

unique_column channel_name => {
    data_type => 'VARCHAR',
    size      => 255
};

has_many plugins => 'Pika::DB::Schema::Result::Plugin', 'channel_id';
