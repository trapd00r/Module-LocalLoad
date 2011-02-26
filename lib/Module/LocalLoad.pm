package Module::LocalLoad;
use strict;
use vars qw($VERSION);
$VERSION = '0.150';

use Carp();
use File::Copy();
use File::Path();


my $PERL5HACKLIB;

sub import {
  my $who = (caller(1))[0];

  {
    no strict 'refs';
    *{"${who}::load"} = *load;
  }
}

sub load {
  my $module = shift or return;

  my $who = (caller(1))[0];
  $PERL5HACKLIB = $ENV{PERL5HACKLIB};

  if(!defined($PERL5HACKLIB)) {
    Carp::croak("Environment variable \$PERL5HACKLIB not set! Aborting.\n");
  }

  my $slashed_module = _colon_to_slash( $module );

  if(! -d "$PERL5HACKLIB/$slashed_module") {
    File::Path::make_path("$PERL5HACKLIB/$slashed_module")
      or Carp::croak("Cant mkdir $PERL5HACKLIB/$slashed_module: $!\n");
  }

  my $found_pm;
  for my $dir_in_inc(@INC) {
    if($dir_in_inc eq $PERL5HACKLIB) {
      next;
    }
    if( -f "$dir_in_inc/$slashed_module.pm") {
      $found_pm = "$dir_in_inc/$slashed_module.pm";
      last;
    }
  }

  if(!defined($found_pm)) {
    Carp::croak("Could not find $module in \@INC\n");
  }

  if(! -f "$PERL5HACKLIB/$slashed_module.pm") {
    File::Copy::copy($found_pm, "$PERL5HACKLIB/$slashed_module.pm")
      or croak("Can not copy $found_pm to $PERL5HACKLIB/$slashed_module.pm: $!");
  }

  unshift(@INC, $PERL5HACKLIB) unless $INC[0] eq $PERL5HACKLIB;

  eval "require $module";
  $@ ? Carp::croak("Error loading $module: $@\n") : return 1;
}

sub _colon_to_slash {
  my $module = shift;
  $module =~ s{::}{/}g;
  return $module;
}


1;

__END__


=pod

=head1 NAME

Module::LocalLoad - create and use a local lib/ for globally installed packages

=head1 SYNOPSIS

  my $module = 'IO::File';
  load($module) and printf("%s v%s loaded\n", $module, $module->VERSION);

=head1 DESCRIPTION

You might find yourself in a situation where you need to change something in the
source of a globally installed package. Doing so directly might not be such a
good idea, and sometimes not even possible.

This module will help you set up a temporary local lib/ for the modules that you
are working on right now. See the L</EXAMPLES> section.

=head1 EXPORTS

=head2 load()

=over 4

=item Arguments:    $package

=item Return value: Boolean

=back

When load() is called with a valid, globally installed package name several
things happen. First, we check if the environment variable C<PERL5HACKLIB> is
defined and points to a directory that'll be our new lib/.
If the directory already contains a copy of the package, we go ahead and load
it, else we must first copy it.

=head1 EXAMPLES

You want to muck around in the inner workings of the IO::File module.

  # io-file-hack.pl
  use Module::LocalLoad;


  my $m = 'IO::File';
  my $f = $m;
  $f =~ s{::}{/}g;

  load($m) and printf("%s v%s loaded - %s\n", $m, $m->VERSION, $INC{"$f.pm"});

This will produce something like:

  IO::File v1.14 loaded - /tmp/lib/IO/File.pm

Next up, go make some changes to /tmp/lib/IO/File.pm . Don't forget to change
the $VERSION variable!

  vim /tmp/lib/IO/File.pm

  IO::File v1.14.1 loaded - /tmp/lib/IO/File.pm

=head1 ENVIRONMENT

=over 4

=item PERL5HACKLIB

=back

Where the temporary lib should be set up.

=head1 AUTHOR

    \ \ | / /
     \ \ - /
      \ | /
      (O O)
      ( < )
      (-=-)

  Magnus Woldrich
  CPAN ID: WOLDRICH
  magnus@trapd00r.se
  http://japh.se

=head1 CONTRIBUTORS

None required yet.

=head1 COPYRIGHT

Copyright 2011 the B<Module::LocalLoad> L</AUTHOR> and L</CONTRIBUTORS> as
listed above.

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

# vim: set ts=2 et sw=2:
