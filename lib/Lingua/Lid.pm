package Lingua::Lid;

#
# Copyright (C) 2009-2014 Lingua-Systems Software GmbH
#

use 5.008000;
use strict;

require Exporter;
require DynaLoader;

our @ISA = qw/DynaLoader Exporter/;

use Lingua::Lid::Errstr;


our $VERSION = '0.04';


our @EXPORT      = ();
our %EXPORT_TAGS = ( 'all' => [ qw/lid_version lid_version_ct
                                   lid_ffile lid_fstr/ ] );
our @EXPORT_OK   = ( @{ $EXPORT_TAGS{'all'} } );


# ...for backward compatibility
tie our $errstr, 'Lingua::Lid::Errstr';


# Workaround for shared library name clashes on Win32
local $DynaLoader::dl_dlext = "xs.$DynaLoader::dl_dlext" if $^O eq "MSWin32";


bootstrap Lingua::Lid;


1;


=head1 NAME

Lingua::Lid - Interface to the language and encoding identifier "lid"


=head1 SYNOPSIS

    use Lingua::Lid qw/:all/;

    # Identify the language and character encoding of...

    # ...a string
    $result = lid_fstr("This is a short English sentence.");

    # ...a plain text file
    $result = lid_ffile("/path/to/a/file.txt");

    # ...if $result is undef, an error occurred:
    die Lingua::Lid::errstr() unless $result;

    print "Lingua::Lid v$Lingua::Lid::VERSION, using lid v",
        lid_version(), "\n";


=head1 DESCRIPTION

The Perl extension B<Lingua::Lid> provides a Perl interface to Lingua-Systems'
language and character encoding identification library B<lid>, which is
required to build and use this extension.

The interface is implemented using the XS language and makes the functionality
of the B<lid> C library functions available to Perl applications and modules
in a simple to use way.

B<Lingua::Lid> is thread-safe an can be used my more than one thread
simultaneously, if compiled with B<lid> v3.0.0 or above.

This man page covers the usage of the B<Lingua::Lid> Perl extension only - for
more information on B<lid> and a list on supported languages and character
encodings, have a look at its manual, which is both included in its
distribution and freely available under
L<http://www.lingua-systems.com/language-identifier/lid-library/>.

B<Lingua::Lid> aims to stick with the C interface as close as reasonable - but
with respect to common Perl conventions. Have a look at "COMPARISON TO THE C
INTERFACE" for details.

=head1 EXPORTS

No symbols are exported by default.

Any function needed must either be requested for import explicitly or the
export tag C<:all> may be used to import symbols for all provided functions:

  use Lingua::Lid qw/lid_ffile lid_fstr/; # or
  use Lingua::Lid qw/:all/;

The function Lingua::Lid::errstr() is not exportable and has to be called
with its full package name.

=head1 FUNCTIONS

=head2 lid_fstr( C<$string> )

Mnemonic: "Language and encoding identification... from string"

This function takes a C<$string> as an argument and identifies its language
and encoding.
It returns a hash reference containing the results. See
S<IDENTIFICATION RESULTS DATA STRUCTURE> for details.

If an error occurs, the function returns C<undef>. Use Lingua::Lid::errstr()
to obtain an appropriate message describing the error.

=head2 lid_ffile( C<$file> )

Mnemonic: "Language and encoding identification... from file"

This function takes a plain text C<$file>'s path as an argument and identifies
its language and encoding.  It returns a hash reference containing the
results. See S<IDENTIFICATION RESULTS DATA STRUCTURE> for details.

If an error occurs, the function returns C<undef>. Use Lingua::Lid::errstr()
to obtain an appropriate message describing the error.

=head2 lid_version( )

This function returns the version of the B<lid> C library that is currently
loaded (I<runtime> version).

=head2 lid_version_ct( )

This function returns the version of the B<lid> C library that B<Lingua::Lid>
has been compiled with (I<compile time> version).

=head1 IDENTIFICATION RESULTS DATA STRUCTURE

The functions lid_fstr() and lid_ffile() return a I<hash reference>
containing the results of the language and encoding identification.

The hash reference contains the following keys:

=over 4

=item I<language>

The language's name (in English), i.e. "German", "French", "English".

=item I<isocode>

The language's ISO 639-3 code, i.e. "deu", "fra", "eng".

=item I<encoding>

The character encoding, i.e. "UTF-8", "ISO-8859-1", "UTF-32BE".

=back

  $result = {
                'language'  =>  'English',
                'isocode'   =>  'eng',
                'encoding'  =>  'ASCII'
            };


=head1 ERROR HANDLING

The functions lid_fstr() and lid_ffile() return C<undef> if an error occurs.
Lingua::Lid::errstr() can be used to obtain an appropriate message describing
the last occurred error.

Have a look at B<lid>'s manual for a list of all error messages.

=over 4

=item NOTE:

The C<$Lingua::Lid::errstr> variable is still supported and thread-safe, too.
Internally it is tied to Lingua::Lid::errstr() using
B<Lingua::Lid::Errstr>.
However, as of B<Lingua::Lid> v0.02 Lingua::Lid::errstr() is preferred and
should be used in any new code. C<$Lingua::Lid::errstr> may be removed in a
future release.

=back

=head1 COMPARISON TO THE C INTERFACE

B<Lingua::Lid>'s function lid_fstr() and lid_ffile() behave exactly as their
B<lid> counterparts in C.

The C functions lid_fnstr() and lid_fwstr() are not needed, use the
B<Lingua::Lid> function lid_fstr() in any Perl code instead.

The C function lid_strerror() and the per-thread pseudo-variable C<lid_errno>
are not needed. Rather than returning a pointer to C<NULL>, B<Lingua::Lid>'s
lid_fstr() and lid_ffile() return C<undef> on errors.
Lingua::Lid::errstr() can be used to obtain an appropriate message describing
the last occurred error.

B<lid>'s function lid_version_string() is available as lid_version() in
B<Lingua::Lid>.

The C defines C<LID_VERSION_STRING> (C<LID_VERSION> in lid v2.x.x) is not
available in B<Lingua::Lid>, use lid_version_ct() instead.

B<Lingua::Lid>'s results data structure sticks to the C C<lid_t *> structure
as close as possible. See "IDENTIFICATION RESULTS DATA STRUCTURE" above.

=head1 EXAMPLES

  use strict;
  use Lingua::Lid qw/lid_fstr lid_version/;

  print "Lingua::Lid v$Lingua::Lid::VERSION, using lid v",
    lid_version(), "\n";

  my @strings =
  (
      "This is a short English sentence.",
      "Dies ist ein kurzer deutscher Satz.",
      " "
  );

  foreach my $string (@strings)
  {
      if (my $r = lid_fstr($string))
      {
          print join(" - ", $r->{language}, $r->{isocode},
                            $r->{encoding}), "\n";
      }
      else
      {
          print "lid_fstr() failed: ", Lingua::Lid::errstr(), "\n";
      }
  }

The program above produces the following output:

  Lingua::Lid v0.02, using lid v3.0.0
  English - eng - ASCII
  German - deu - ASCII
  lid_fstr() failed: Insufficient input length

=head1 BUGS

None known.

Please report bugs either using CPAN's bug tracker or to
E<lt>perl@lingua-systems.comE<gt>.


=head1 SEE ALSO

=over 4

=item *

Lingua::Lid's website:
L<http://www.lingua-systems.com/language-identifier/Lingua-Lid-Perl-extension/>

=item *

lid's website:
L<http://www.lingua-systems.com/language-identifier/lid-library/>

=item *

B<lid>'s manual (available in English and German)

=back


=head1 AUTHOR

Alex Linke E<lt>alinke@lingua-systems.comE<gt>


=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009-2014 Lingua-Systems Software GmbH

This extension is free software. It may be used, redistributed and/or
modified under the terms of the zlib license. For details, see the full text
of the license in the file LICENSE.

=cut


# vim: sts=4 sw=4 ts=4 ai et tw=78
