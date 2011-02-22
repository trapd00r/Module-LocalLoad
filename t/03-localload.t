use strict;
use Test::More;

use Module::LocalLoad;

subtest 'Localload' => sub {
  load('IO::File');
  $ENV{PERL5HACKLIB} = '/tmp/lib';
  ok(
    $INC{'IO/File.pm'} eq '/tmp/lib/IO/File.pm',
    'IO::File loaded | PERL5HACKLIB eq /tmp/lib',
  );
  unlink('/tmp/lib/IO/File.pm');
  delete $ENV{PERL5HACKLIB};
  delete $INC{'IO/File.pm'};

  load('IO::File');
  ok(
    $INC{'IO/File.pm'} eq '/tmp/lib/IO/File.pm',
    'IO::File loaded | PERL5HACKLIB unset',
  );
};

done_testing();
