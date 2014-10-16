package Pika::Command::irc;

# ABSTRACT: irc gateway

use PikaLove;
use Moo;
use namespace::clean;

method validate_args ($opt, $args) {
    return $self->usage_error("Needs a nickname")
      unless $opt->{nick};
}

method opt_spec {
    return (["nick|n=s", "bot nick"]);
}

method execute ($opts, $args) {
  say "$opts->{nick}, starting up.";
}
