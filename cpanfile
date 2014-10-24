requires "AnyEvent" => "0";
requires "AnyEvent::IRC::Client" => "0";
requires "Config::Any" => "0";
requires "DBI" => "0";
requires "IRC::Utils" => "0";
requires "Module::Runtime" => "0";
requires "Moose" => "0";
requires "Moose::Util" => "0";
requires "Moose::Util::TypeConstraints" => "0";
requires "MooseX::App" => "0";
requires "MooseX::App::Command" => "0";
requires "Net::Launchpad::Client" => "0";
requires "Net::Launchpad::Model" => "0";
requires "Net::LeanKit" => "0";
requires "Quick::Perl" => "0";
requires "SQL::Abstract::More" => "0";
requires "namespace::autoclean" => "0";
requires "perl" => "5.008";

on 'test' => sub {
  requires "DBD::SQLite" => "0";
  requires "ExtUtils::MakeMaker" => "0";
  requires "File::Spec" => "0";
  requires "IO::Handle" => "0";
  requires "IPC::Open3" => "0";
  requires "Test::Compile" => "0";
  requires "Test::Kwalitee" => "0";
  requires "Test::Mojo" => "0";
  requires "Test::More" => "0";
  requires "perl" => "5.008";
  requires "strict" => "0";
  requires "warnings" => "0";
};

on 'test' => sub {
  recommends "CPAN::Meta" => "2.120900";
};

on 'configure' => sub {
  requires "ExtUtils::MakeMaker" => "0";
  requires "File::ShareDir::Install" => "0.06";
};

on 'develop' => sub {
  requires "Test::Kwalitee" => "1.21";
};
