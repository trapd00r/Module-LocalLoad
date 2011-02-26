use strict;
use Test::More;

use Module::LocalLoad;


subtest 'Localload' => sub {
  load('IO::File');
  my $base = $ENV{PERL5HACKLIB};
  if(!defined($base)) {
    $base = './local_lib';
  }
  print "BASE IS $base\n", "AND   " . $INC{'IO/File.pm'}, "\n\n";
  ok(
    $INC{'IO/File.pm'} eq "$base/IO/File.pm",
    "IO::File loaded | PERL5HACKLIB eq $base",
  );
  unlink("$base/IO/File.pm");
  delete $ENV{PERL5HACKLIB};
  delete $INC{'IO/File.pm'};


  #load('IO::File');
  #ok(
  #  $INC{'IO/File.pm'} eq '/tmp/lib/IO/File.pm',
  #  'IO::File loaded | PERL5HACKLIB unset',
  #);
};

done_testing();
