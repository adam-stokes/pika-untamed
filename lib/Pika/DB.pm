package Pika::DB;

# ABSTRACT: db interface for plugins

use Quick::Perl;
use Moose;
use Pika::DB::Schema;
use namespace::autoclean;

has schema => (is => 'ro', isa => 'Pika::DB::Schema', lazy => 1, builder => '_init_db');

method _init_db {
    my $dbn = path('~/.pika.db');
    return Pika::DB::Schema->connect("dbi:SQLite:dbname=$dbn", "", "",
        { sqlite_unicode => 1});
}

__PACKAGE__->meta->make_immutable;
