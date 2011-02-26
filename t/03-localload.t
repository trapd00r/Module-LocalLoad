use strict;
use Test::More;

use Module::LocalLoad;


subtest 'Localload' => sub {
  plan skip_all => 'load() tested on dev box' if !exists($ENV{RELEASE});
  $ENV{PERL5HACKLIB} = '/tmp/';
  load('Term::ANSIColor');
  my $base = $ENV{PERL5HACKLIB};
  ok(
    $INC{'Term/ANSIColor.pm'} eq "$base/Term/ANSIColor.pm",
    "Term::ANSIColor loaded | PERL5HACKLIB eq $base",
  );
  #unlink("$base/Term/ANSIColor.pm");
  #delete $ENV{PERL5HACKLIB};
  #delete $INC{'Term::ANSIColor'};


  #load('IO::File');
  #ok(
  #  $INC{'IO/File.pm'} eq '/tmp/lib/IO/File.pm',
  #  'IO::File loaded | PERL5HACKLIB unset',
  #);
};

done_testing();

