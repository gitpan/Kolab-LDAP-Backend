package Kolab::LDAP::Backend;

##
##  Copyright (c) 2003  Code Fusion cc
##
##    Writen by Stuart Bingë  <s.binge@codefusion.co.za>
##    Portions based on work by the following people:
##
##      (c) 2003  Tassilo Erlewein  <tassilo.erlewein@erfrakon.de>
##      (c) 2003  Martin Konold     <martin.konold@erfrakon.de>
##      (c) 2003  Achim Frank       <achim.frank@erfrakon.de>
##
##
##  This  program is free  software; you can redistribute  it and/or
##  modify it  under the terms of the GNU  General Public License as
##  published by the  Free Software Foundation; either version 2, or
##  (at your option) any later version.
##
##  This program is  distributed in the hope that it will be useful,
##  but WITHOUT  ANY WARRANTY; without even the  implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
##  General Public License for more details.
##
##  You can view the  GNU General Public License, online, at the GNU
##  Project's homepage; see <http://www.gnu.org/licenses/gpl.html>.
##

use 5.008;
use strict;
use warnings;
use Kolab;
use Kolab::Util;
use vars qw(
    %startup
    %run
    %backends
);

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = (
    'all' => [ qw(
        &load
        &startup
        &run
        %backends
    ) ]
);

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(

);

our $VERSION = '0.01';

sub load
{
    my $p = shift || '';
    $p .= '_' if ($p);

    my $backend = $Kolab::config{$p . 'directory_mode'};
    return if (exists($backends{$backend}));

    Kolab::log('B', "Loading backend `$backend'");

    unless (eval "require Kolab::LDAP::Backend::$backend") {
        Kolab::log('B', "Backend `$backend' does not exist, exiting", KOLAB_ERROR);
        exit(1);
    }

    $startup{$backend} = \&{'Kolab::LDAP::Backend::' . $backend . '::startup'};
    $run{$backend} = \&{'Kolab::LDAP::Backend::' . $backend . '::run'};

    $backends{$backend} = 1;
}

# shutdown is handled per-module, using signals
sub startup
{
    foreach my $backend (keys %backends) {
        my $func = $startup{$backend};
        unless (eval '&$func') {
            $func = 'Kolab::LDAP::Backend::' . $backend . '::startup';
            Kolab::log('B', "Function `$func' does not exist, exiting", KOLAB_ERROR);
            exit(1);
        }
    }
}

sub run
{
    my $backend = shift || 1;
    return if (!exists($run{$backend}));

    my $func = $run{$backend};
    unless (eval '&$func') {
        $func = 'Kolab::LDAP::Backend::' . $backend . '::run';
        Kolab::log('B', "Function `$func' does not exist, exiting", KOLAB_ERROR);
        exit(1);
    }
}

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Kolab::LDAP::Backend - Perl extension for blah blah blah

=head1 SYNOPSIS

  use Kolab::LDAP::Backend;
  blah blah blah

=head1 ABSTRACT

  This should be the abstract for Kolab::LDAP::Backend.
  The abstract is used when making PPD (Perl Package Description) files.
  If you don't want an ABSTRACT you should also edit Makefile.PL to
  remove the ABSTRACT_FROM option.

=head1 DESCRIPTION

Stub documentation for Kolab::LDAP::Backend, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

root, E<lt>root@(none)E<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2003 by root

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
