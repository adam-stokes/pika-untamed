package Pika::CLI;

# ABSTRACT: Command Line Interface For Pika etc scripts

use Quick::Perl;
use Moose;
use namespace::autoclean;
extends 'MooseX::App::Cmd';

__PACKAGE__->meta->make_immutable;
