package Module::LocalLoad;
use strict;
use vars qw($VERSION);
$VERSION = '0.026';

use Carp();
use File::Copy();
use File::Path();


sub import {
  my $who = (caller(1))[0];

  {
    no strict 'refs';
    *{"${who}::load"} = *load;
  }
}


sub load {
  my $mod = shift or return;
  my $who = (caller(1))[0];

  my $mod_file = _get_base_filename( $mod );

  my $PERL5HACKLIB = $ENV{PERL5HACKLIB} // '/tmp';

  if( ($PERL5HACKLIB !~ /lib/) or (!('lib' ~~ glob("$PERL5HACKLIB/*"))) ) {
    $PERL5HACKLIB .= '/lib';
  }
  if(!-d "$PERL5HACKLIB/$mod_file") {
    File::Path::make_path("$PERL5HACKLIB/$mod_file")
      or Carp::croak("Cant mkdir '$PERL5HACKLIB/$mod_file'\n");
  }

  my $module_in_inc;
  for my $d(@INC) {
    if(-f "$d/$mod_file.pm") {
      $module_in_inc = "$d/$mod_file.pm";
      last;
    }
  }

  if(!defined($module_in_inc)) {
    Carp::croak "No such module '$mod' in \@INC\n";
  }

  unshift(@INC, $PERL5HACKLIB);

  my $base = _get_base_class( $mod_file );

  if(!-f "$PERL5HACKLIB/$mod_file.pm") {
    File::Copy::copy($module_in_inc, "$PERL5HACKLIB/$base")
      or Carp::croak("Copy failed: '$module_in_inc' -> '$PERL5HACKLIB/$base'\n");
  }

  eval "require $mod";
  $@ ? Carp::croak $@ : return 1;
}

sub _get_base_class {
  my $module = shift;
  my($base) = $module =~ m|^(.+)/.*$|;
  return $base;
}

sub _get_base_filename {
  my $module = shift;
  $module =~ s|::|/|g;
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

None by default.

=head1 FUNCTIONS

=head2 load()

=over 4

=item Arguments:    $package

=item Return value: Boolean

=back

When load() is called with a valid, globally installed package name several
things happen. First, we check if the environment variable PERL5HACKLIB is
defined and points to a directory that'll be our new lib/.
If the directory already contains a copy of the package, we go ahead and load
it, else we must first copy it.


=head1 ENVIRONMENT

PERL5HACKLIB

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

Copyright 2011 B<Module::LocalLoad>s L</AUTHOR> and L</CONTRIBUTORS> as listed
above.

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

# vim: set ts=2 et sw=2:
