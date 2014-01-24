use 5.008000;
use strict;
use ExtUtils::MakeMaker;

use File::Spec;
use Config;


##
## Check if executed by an automated CPAN Test
##
## In that case, signal the test to stop by not creating a Makefile and
## returning zero. This is necessary because Lingua::Lid implements an
## interface to a commercial library that will most likely not be present
## on any CPAN tester's machine.
##
exit 0 if $ENV{AUTOMATED_TESTING};


##
## Check if the OS is supported by lid
##
unless ( $^O =~ /^(linux|freebsd|solaris|mswin32)$/i )
{
    print <<NOTICE;

lid is currently not available for $^O.

Visit http://www.lingua-systems.com/language-identifier/lid-library/ for a
list of supported operating systems.

NOTICE

    die "OS unsupported\n";
}


##
## Determine lid installation information
##
my %lid = locate_lid();

my %flags = (
    lib => $Config{ccname} eq "cl" ? "" : "-L$lid{lib_dir} -llid",
    obj => $Config{ccname} eq "cl" ? "$lid{lib_dir}\\lid.lib" : "",
    inc => "-I$lid{inc_dir}"
);


my %extra_flags = ();

if ( $^O eq "MSWin32" )
{
    # Workaround for shared library name clashes on Win32
    $extra_flags{DLEXT} = "xs.$Config{dlext}";
}


WriteMakefile(
    NAME          => 'Lingua::Lid',
    VERSION_FROM  => 'lib/Lingua/Lid.pm',
    PREREQ_PM     => {},
    ABSTRACT_FROM => 'lib/Lingua/Lid.pm',
    AUTHOR        => 'Alex Linke <alinke@lingua-systems.com>',
    DEFINE        => '',
    OBJECT        => "Lid$Config{_o} $flags{obj}",
    LIBS          => [ $flags{lib} ],
    INC           => $flags{inc},
    %extra_flags
);


sub locate_lid
{
    my $arch_libdir = $Config{archname} =~ /64(?!int)/ ? "lib64" : "lib";
    my $lib_prefix  = $^O eq "MSWin32" ? "" : "lib";

    my @bases = $^O eq "MSWin32" ?
                    ( 'C:\\lid' )  :
                    ( '/usr', '/usr/local', '/opt/ls' );


    unshift @bases, $ENV{LID_BASE_DIR} if defined $ENV{LID_BASE_DIR};


    foreach my $base (@bases)
    {
        my %i = (
            lib_dir => File::Spec->catfile( $base, $arch_libdir ),
            lib     => File::Spec->catfile(
                        $base, $arch_libdir, "${lib_prefix}lid.$Config{dlext}"
                       ),
            inc_dir => File::Spec->catfile( $base, "include" ),
            inc     => File::Spec->catfile( $base, "include", "lid.h" )
        );

        if ( -f $i{lib} && -f $i{inc} )
        {
            print "lid found beneath $base.\n";
            return %i;
        }
    }


    print STDERR <<NOT_FOUND;

The lid C library could not be found.

Tried: @bases

If you already purchased a copy of lid and decided to install it to a non
default location, set the LID_BASE_DIR environment variable to point to
your installation's base directory and rerun Makefile.PL:

    export LID_BASE_DIR=/path/           (Unix, sh)
    setenv LID_BASE_DIR /path/           (Unix, csh)
    set    LID_BASE_DIR=C:\\path          (Win32)

    perl Makefile.PL

Otherwise, point your browser to lid's website for further information:

    http://www.lingua-systems.com/language-identifier/lid-library/

NOT_FOUND

    exit(1);
}


# vim: sts=4 sw=4 ts=4 ai et
