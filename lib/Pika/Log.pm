package Pika::Log;

# ABSTRACT: log interface

use Quick::Perl;
use Log::Dispatch;
use Moose::Role;
use namespace::autoclean;

has log => (
    is      => 'ro',
    isa     => 'Log::Dispatch',
    builder => '_build_log'
);

method _build_log {
    return Log::Dispatch->new(
        outputs => [
            [   'Screen',
                min_level => 'debug',
                stderr    => 1,
                newline   => 1
            ]
        ],
    );
}

1;
