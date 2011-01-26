use 5.008000;
use strict;
use ExtUtils::MakeMaker;

my $BASE;


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
if ($^O ne "linux" && $^O ne "solaris" && $^O ne "freebsd")
{
    print <<NOTICE;

lid is currently not available for $^O.

Visit http://www.lingua-systems.com/language-identifier/lid-library/ for a
list of supported operating systems.

NOTICE

    die "OS unsupported\n";
}


##
## Determine lid's installation path
##
$BASE = "/opt/ls"          if ($^O eq "linux" or $^O eq "solaris");
$BASE = "/usr/local"       if ($^O eq "freebsd");
$BASE = $ENV{LID_BASE_DIR} if (defined $ENV{LID_BASE_DIR});


##
## Check the assumed directories exist and lid.h is located there
##
lid_missing("$BASE/lib does not exist")      unless -d "$BASE/lib";
lid_missing("$BASE/include does not exist")  unless -d "$BASE/include";
lid_missing("lid.h not in $BASE/include")    unless -e "$BASE/include/lid.h";


WriteMakefile(
    NAME              => 'Lingua::Lid',
    VERSION_FROM      => 'lib/Lingua/Lid.pm',
    PREREQ_PM         => {},
    ABSTRACT_FROM     => 'lib/Lingua/Lid.pm',
    AUTHOR            => 'Alex Linke <alinke@lingua-systems.com>',
    LIBS              => ["-L$BASE/lib -llid"],
    DEFINE            => '',
    INC               => "-I$BASE/include",
);


sub lid_missing
{
    print STDERR <<NOT_FOUND;
ERROR: $_[0]

The lid C library could not be found beneath $BASE.

If you already purchased a copy of lid and decided to install it to a non
default location, set the LID_BASE_DIR environment variable to your
installation's base directory:

    env LID_BASE_DIR=/path/ perl Makefile.PL

Otherwise, point your browser to lid's website for further information:

    http://www.lingua-systems.com/language-identifier/lid-library/

NOT_FOUND

    exit(1);
}


# vim: sts=4 sw=4 ai et
