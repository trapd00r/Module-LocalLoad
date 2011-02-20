#!/usr/bin/perl
use strict;
use warnings;

use Module::LocalLoad;

my @mod = qw(
  Data::Dumper
  IO::File
);

for my $m(@mod) {
  my $f = $m;
  $f =~ s|::|/|g;
  $f .= '.pm';
  load($m) and printf("%25.25s v%s loaded - %s\n", $m, $m->VERSION, $INC{$f});
}
