package Module::LocalLoad;
use strict;
use vars qw($VERSION);
$VERSION = '0.025';

use Carp              qw(croak);
use File::Copy        qw(cp);
use File::Path        qw(make_path);


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
    make_path("$PERL5HACKLIB/$mod_file")
      or croak("Cant mkdir '$PERL5HACKLIB/$mod_file'\n");
  }

  my $module_in_inc;
  for my $d(@INC) {
    if(-f "$d/$mod_file.pm") {
      $module_in_inc = "$d/$mod_file.pm";
      last;
    }
  }

  if(!defined($module_in_inc)) {
    croak "No such module '$mod' in \@INC\n";
  }

  unshift(@INC, $PERL5HACKLIB);

  my $base = _get_base_class( $mod_file );

  if(!-f "$PERL5HACKLIB/$mod_file.pm") {
    cp($module_in_inc, "$PERL5HACKLIB/$base")
      or croak("Copy failed: '$module_in_inc' -> '$PERL5HACKLIB/$base'\n");
  }

  eval "require $mod";
  $@ ? croak $@ : return 1;
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

Module::LocalLoad - Load modules from local env

=head1 SYNOPSIS

  my $module = 'IO::File';
  load($module) and printf("%s v%s loaded\n", $module, $module->VERSION);

=head1 DESCRIPTION

Let your global modules be locals, and place them in a safe haven where no one
but you can, and will, hurt them.

=head1 ENVIRONMENT

PERL5HACKLIB

=head1 AUTHOR

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
