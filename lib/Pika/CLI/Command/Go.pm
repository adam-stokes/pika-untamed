package Pika::CLI::Command::Go;

# ABSTRACT: Pika runner

use Quick::Perl;
use Config::Any;
use Pika;

use Moose;
use MooseX::App::Command;
use namespace::autoclean;

parameter 'conf' => (
    is            => 'ro',
    required      => 1,
    documentation => 'configuration file'
);

has configuration => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_conf'
);

method _build_conf {
    return Config::Any->load_files({files => [$self->conf], use_ext => 1});
}

method run {
    my $pika = Pika->new(config => $self->config);
    $pika->run;
}

__PACKAGE__->meta->make_immutable;
