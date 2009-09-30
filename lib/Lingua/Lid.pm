#
# Alex Linke, <alinke@lingua-systems.com>
#
# Copyright (C) 2009 Lingua-Systems Software GmbH
#

package Lingua::Lid;

use 5.008000;
use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);


our @EXPORT      = ();
our %EXPORT_TAGS = ( 'all' => [ qw/lid_version lid_ffile lid_fstr/ ] );
our @EXPORT_OK   = ( @{ $EXPORT_TAGS{'all'} } );


our $VERSION = '0.01';

our $errstr;


require XSLoader;
XSLoader::load('Lingua::Lid', $VERSION);


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
     
    print "Lingua::Lid v$Lingua::Lid::VERSION, using lid v",
        lid_version(), "\n";


=head1 DESCRIPTION

The Perl extension B<Lingua::Lid> provides a Perl interface to Lingua-Systems'
language and character encoding identification library B<lid>, which is
required to build and use this extension.

The interface is implemented using the XS language and makes the functionality
of the B<lid> C library functions available to Perl applications and modules
in a simple to use way.

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


=head1 FUNCTIONS

=head2 lid_fstr( C<$string> )

Mnemonic: "Language and encoding identification... from string"

This function takes a C<$string> as an argument and identifies its language
and encoding.
It returns a hash reference containing the results. See
S<IDENTIFICATION RESULTS DATA STRUCTURE> for details.

If an error occurs, the function returns C<undef> and sets
C<$Lingua::Lid::errstr> to an appropriate message describing the error.

=head2 lid_ffile( C<$file> )

Mnemonic: "Language and encoding identification... from file"

This function takes a plain text C<$file>'s path as an argument and identifies
its language and encoding.  It returns a hash reference containing the
results. See S<IDENTIFICATION RESULTS DATA STRUCTURE> for details.

If an error occurs, the function returns C<undef> and sets
C<$Lingua::Lid::errstr> to an appropriate message describing the error.

=head2 lid_version( )

This function returns the version of the underlying B<lid> C library.


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

The functions lid_fstr() and lid_ffile() return C<undef> if an error occurs
and set B<Lingua::Lid>'s package variable C<$errstr> (C<$Lingua::Lid::errstr>)
to an appropriate message describing the error.

Have a look at B<lid>'s manual for a list of all error messages.

=over 4

=item NOTE:

The C<$Lingua::Lid::errstr> variable is reset to C<undef> whenever lid_fstr()
or lid_ffile() are called.

=back


=head1 COMPARISON TO THE C INTERFACE

B<Lingua::Lid>'s function lid_fstr() and lid_ffile() behave exactly as their
B<lid> counterparts in C.

The C functions lid_fnstr() and lid_fwstr() are not needed, use the
B<Lingua::Lid> function lid_fstr() in any Perl code instead.

The C function lid_strerror() and the global C variable C<lid_errno> are not
needed. Rather than returning a pointer to C<NULL>, B<Lingua::Lid>'s
lid_fstr() and lid_ffile() return C<undef> on errors and set
C<$Lingua::Lid::errstr> to an appropriate message describing the error.

The C define C<LID_VERSION> is not available in B<Lingua::Lid>, use
lid_version() instead.

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
      "Too short."
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
          print "lid_fstr() failed: $Lingua::Lid::errstr\n";
      }
  }

The program above produces the following output:

  Lingua::Lid v0.01, using lid v2.0.2
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

Alex Linke, E<lt>alinke@lingua-systems.comE<gt>


=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lingua-Systems Software GmbH

This extension is free software. It may be used, redistributed and/or
modified under the terms of the zlib license. For details, see the full text
of the license in the file LICENSE.

=cut


# vim: sts=4 sw=4 enc=utf-8 ai et tw=78
