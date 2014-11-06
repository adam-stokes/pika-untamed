package Pika::Command::Go;

# ABSTRACT: Pika runner

use Quick::Perl;
use Config::Any;
use Pika;

use Moose;
use MooseX::App::Command;
use namespace::autoclean;

option 'conf' => (
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
    my $files = Config::Any->load_files({files => [$self->conf], use_ext => 1});
    $files = shift @{$files} || {};
    return $files->{$self->conf};
}

method run {
    my $pika = Pika->new(config => $self->configuration);
    $pika->run;
}

__PACKAGE__->meta->make_immutable;
1;
