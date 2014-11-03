package Pika::DB::Schema::Result::Server;

# ABSTRACT: irc server tracking

use Quick::Perl;
use DBIx::Class::Candy -autotable => v1;

primary_column server_id => {
    data_type         => 'INT',
    is_auto_increment => 1
};

unique_column server_name => {
    data_type => 'VARCHAR',
    size      => 255
};

has_many channels => 'Pika::DB::Schema::Result::Channel', 'server_id';

1;
