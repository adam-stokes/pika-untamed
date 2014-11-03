package Pika::DB::Schema;

# ABSTRACT: pika db schema
use Quick::Perl;
use base qw/DBIx::Class::Schema/;

our $VERSION = '1';
$VERSION = eval $VERSION;

__PACKAGE__->load_namespaces();

1;
