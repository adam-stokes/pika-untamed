requires "App::Cmd::Setup" => "0";
requires "Import::Into" => "0";
requires "Method::Signatures" => "0";
requires "Moo" => "0";
requires "autobox" => "0";
requires "autobox::Core" => "0";
requires "boolean" => "0";
requires "feature" => "0";
requires "namespace::clean" => "0";
requires "strict" => "0";
requires "true" => "0";
requires "utf8::all" => "0";
requires "warnings" => "0";

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
};

on 'test' => sub {
  recommends "CPAN::Meta" => "2.120900";
};

on 'configure' => sub {
  requires "ExtUtils::MakeMaker" => "0";
};

on 'develop' => sub {
  requires "Test::Kwalitee" => "1.21";
  requires "Test::More" => "0";
  requires "Test::NoTabs" => "0";
};
