package PikaLove;

# ABSTRACT: my pika loves you

use strict;
use warnings;
use utf8::all;
use boolean;
use feature ();
use autobox;
use autobox::Core;
use Method::Signatures;
use true;
use Carp;
use Import::Into;

sub import {
    my $target = caller;
    my $class  = shift;

    'strict'->import::into($target);
    'warnings'->import::into($target);
    'utf8::all'->import::into($target);
    'autodie'->import::into($target, ':all');
    'feature'->import::into($target, ':5.14');
    'boolean'->import::into($target, ':all');
    'autobox'->import::into($target);
    'autobox::Core'->import::into($target);
    'true'->import::into($target);
    'Carp'->import::into($target, qw(confess croak));
    Method::Signatures->import::into($target);
}

1;
