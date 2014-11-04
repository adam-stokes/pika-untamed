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

column server_network => {
    data_type => 'VARCHAR',
    size      => 255
};

has_many plugins => 'Pika::DB::Schema::Result::Plugin', 'server_id';

1;
