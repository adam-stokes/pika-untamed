package Pika::DB;

# ABSTRACT: db interface for plugins

use Quick::Perl;
use Moose;
use DBI;
use SQL::Abstract::More;
use namespace::autoclean;

has dbh => (is => 'ro', isa => 'DBI::db', lazy => 1, builder => '_init_db');

has sql => (
    is      => 'ro',
    isa     => 'SQL::Abstract',
    lazy    => 1,
    builder => '_init_sql_abstract'
);

method _init_db {
    my $dbn = path('~/.pika.db');
    return DBI->connect("dbi:SQLite:dbname=$dbn", "", "",
        {sqlite_use_immediate_transaction => 1});
}

method _init_sql_abstract {
    return SQL::Abstract::More->new;
}

method _run ($stmt, $bind, :$return_val = undef) {
    my ($sth, $ret, $row, @result);

    unless ($sth = $self->dbh->prepare($stmt)) {
        die "Failed to prepare $stmt: $DBI::errstr\n";
    }
    unless ($ret = $sth->execute(@$bind)) {
        die "Failed to execute $stmt: $DBI::errstr\n";
    }
    return $ret if ($return_val eq 'execute');
    if ($return_val eq 'array_first') {
        return map { $_->[0] } @{$sth->fetchall_arrayref()};
    }
    if ($return_val eq 'value_first') {
        if ($row = $sth->fetchall_arrayref()) {
            return $row->[0];
        }
        return;
    }

    # return all results if no return val
    while ($row = $sth->fetchrow_hashref()) {
        push @result, $row;
    }
    return \@result;
}



=method process_plugin_sql

Loads sql table and any initial data for executing plugins

=cut
method process_plugin_sql ($sql) {
    if ($self->dbh()->do($sql)) {
        say "Processed plugin db setup";
    }
    else {
        say "Error: " . $self->dbh()->errstr;
    }
}

method DEMOLISH {
    $self->dbh()->disconnect();
}


__PACKAGE__->meta->make_immutable;
