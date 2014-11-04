package Pika::DB::Schema::Result::Leankit;

# ABSTRACT: leankit database

use Quick::Perl;
use DBIx::Class::Candy -autotable => v1;

primary_column leankit_id => {
    data_type         => 'INT',
    is_auto_increment => 1
};

column server_id => {data_type => 'INT',};

column channel_name => {
    data_type => 'VARCHAR',
    size      => 255
};

column default_board_id => {data_type => 'INT'};

column default_board_name => {
    data_type => 'VARCHAR',
    size      => 255
};

belongs_to server => 'Pika::DB::Schema::Result::Server', 'server_id';

1;
