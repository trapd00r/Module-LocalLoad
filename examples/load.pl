#!/usr/bin/perl
use strict;
use warnings;

use Module::LocalLoad;

my @mod = qw(
  Term::ExtendedColor
  Term::ExtendedColor::Xresources
  Term::ExtendedColor::TTY
  Daemon::Mplayer
  Term::ANSIColor
  Term::ReadKey
  IO::File
  IO::Handle
  IO::Handle
  Module::CoreList
  Module::ScanDeps
);

BEGIN {
  unshift(@INC, 'localload');
  print "$_\n" for @INC;
}

for my $m(@mod) {
  (my $file = $m) =~ s{::}{/}g;
  $file =~ s{$}{.pm};
  load($m) and printf("%25.25s v%s loaded - %s\n", $m, $m->VERSION, $INC{$file});
}
