package Pika::DB::Schema::Result::Plugin;

# ABSTRACT: plugin tracker

use Quick::Perl;
use DBIx::Class::Candy -autotable => v1;

primary_column plugin_id => {
    data_type         => 'INT',
    is_auto_increment => 1
};

column channel_id => {data_type => 'INT',};

unique_column plugin_name => {
    data_type => 'VARCHAR',
    size      => 255
};

belongs_to channel => 'Pika::DB::Schema::Result::Channel', 'channel_id';

1;
