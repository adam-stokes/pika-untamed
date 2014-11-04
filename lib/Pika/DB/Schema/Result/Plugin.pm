package Pika::DB::Schema::Result::Plugin;

# ABSTRACT: plugin tracker

use Quick::Perl;
use DBIx::Class::Candy -autotable => v1;

primary_column plugin_id => {
    data_type         => 'INT',
    is_auto_increment => 1
};

column server_id => {data_type => 'INT',};

unique_column plugin_name => {
    data_type => 'VARCHAR',
    size      => 255
};

belongs_to server => 'Pika::DB::Schema::Result::Server', 'server_id';

1;
