package Pika::Command;

# ABSTRACT: Command Line Interface For Pika etc scripts

use Quick::Perl;
use MooseX::App;

app_base 'pika';

__PACKAGE__->meta->make_immutable;
