requires "AnyEvent" => "0";
requires "AnyEvent::IRC::Client" => "0";
requires "Moose" => "0";
requires "Moose::Util::TypeConstraints" => "0";
requires "MooseX::App::Cmd" => "0";
requires "MooseX::App::Cmd::Command" => "0";
requires "MooseX::Role::Pluggable" => "0";
requires "MooseX::Role::Pluggable::Plugin" => "0";
requires "MooseX::SimpleConfig" => "0";
requires "Quick::Perl" => "0";
requires "namespace::autoclean" => "0";

on 'test' => sub {
  requires "ExtUtils::MakeMaker" => "0";
  requires "File::Spec" => "0";
  requires "IO::Handle" => "0";
  requires "IPC::Open3" => "0";
  requires "Test::Compile" => "0";
  requires "Test::Kwalitee" => "0";
  requires "Test::Mojo" => "0";
  requires "Test::More" => "0";
  requires "Test::NoTabs" => "0";
  requires "perl" => "5.006";
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
  requires "Test::More" => "0";
  requires "Test::NoTabs" => "0";
};
