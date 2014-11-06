package Pika::Command::Setup;

# ABSTRACT: Pika runner

use Quick::Perl;
use aliased 'DBIx::Class::DeploymentHandler' => 'DH';
use Moose;
use MooseX::App::Command;
extends 'Pika::DB';
use namespace::autoclean;


method run {
    my $dh = DH->new(
        {   schema              => $self->schema,
            databases           => 'SQLite',
            script_directory    => 'lib/Pika/files/sql',
            force_overwrite     => 1,
            sql_translator_args => {add_drop_table => 0}
        }
    );
    my $version = $self->schema->schema_version;
    $dh->prepare_install;
    $dh->install;
}

__PACKAGE__->meta->make_immutable;
1;
