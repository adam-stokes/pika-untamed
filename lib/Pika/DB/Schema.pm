package Pika::DB::Schema;

# ABSTRACT: pika db schema
use Quick::Perl;
use base qw/DBIx::Class::Schema/;

__PACKAGE__->load_namespaces();
