#
# Alex Linke <alinke@lingua-systems.com>
#
# Copyright (c) 2010-2011 Lingua-Systems Software GmbH
#

use strict;
use Test::More;
use Encode qw/encode decode/;
use Config;

use Lingua::Lid qw/lid_fstr lid_version/;


my %text = (
    German   => q|Perl ist eine freie, plattformunabhängige und | .
                q|interpretierte Programmiersprache, die mehrere | .
                q|Programmierparadigmen unterstützt.|,
    English  => q|Perl is a high-level, general-purpose, interpreted, | .
                q|dynamic programming language.|,
    Spanish  => q|Perl es un lenguaje de programación diseñado por Larry | .
                q|Wall en 1987.|,
    Swedish  => q|Perl är ett skriptspråk skapat av Larry Wall 1987.|,
    Finnish  => q|Perl on Larry Wallin kehittämä tulkattava | .
                q|proseduraalinen skriptimäinen ohjelmointikieli.|,
    Estonian => q|Perl on algupäraselt protseduraalne keel, mis toetab | .
                q|nüüd ka objektorienteeritud programmeerimist.|,
);


my @tests = (
    {
        str  => $text{German},
        id   => "German_UTF-8",
        res  => {
            language => "German",
            isocode  => "deu",
            encoding => "UTF-8"
        }
    },
    {
        str  => encode("ISO-8859-1", decode("UTF-8", $text{German})),
        id   => "German_ISO-8859-1",
        res  => {
            language => "German",
            isocode  => "deu",
            encoding => "ISO-8859-1"
        }
    },
    {
        str  => $text{English},
        id   => "English_ASCII",
        res  => {
            language => "English",
            isocode  => "eng",
            encoding => "ASCII"
        }
    },
    {
        str  => encode("UTF-32BE", decode("UTF-8", $text{English})),
        id   => "English_UTF32-BE",
        res  => {
            language => "English",
            isocode  => "eng",
            encoding => "UTF-32BE"
        }
    },
    {
        str  => $text{Spanish},
        id   => "Spanish_UTF-8",
        res  => {
            language => "Spanish",
            isocode  => "spa",
            encoding => "UTF-8"
        }
    },
    {
        str  => encode("ISO-8859-1", decode("UTF-8", $text{Spanish})),
        id   => "Spanish_ISO-8859-1",
        res  => {
            language => "Spanish",
            isocode  => "spa",
            encoding => "ISO-8859-1"
        }
    },
    {
        str  => $text{Swedish},
        id   => "Swedish_UTF-8",
        res  => {
            language => "Swedish",
            isocode  => "swe",
            encoding => "UTF-8"
        }
    },
    {
        str  => encode("UTF-16LE", decode("UTF-8", $text{Swedish})),
        id   => "Swedish_UTF-16LE",
        res  => {
            language => "Swedish",
            isocode  => "swe",
            encoding => "UTF-16LE"
        }
    },
    {
        str  => $text{Finnish},
        id   => "Finnish_UTF-8",
        res  => {
            language => "Finnish",
            isocode  => "fin",
            encoding => "UTF-8"
        }
    },
    {
        str  => encode("ISO-8859-1", decode("UTF-8", $text{Finnish})),
        id   => "Finnish_ISO-8859-1",
        res  => {
            language => "Finnish",
            isocode  => "fin",
            encoding => "ISO-8859-1"
        }
    },
    {
        str  => $text{Estonian},
        id   => "Estonian_UTF-8",
        res  => {
            language => "Estonian",
            isocode  => "est",
            encoding => "UTF-8"
        }
    },
    {
        str  => encode("UTF-16BE", decode("UTF-8", $text{Estonian})),
        id   => "Estonian_UTF-16BE",
        res  => {
            language => "Estonian",
            isocode  => "est",
            encoding => "UTF-16BE"
        }
    }
);


if ($Config{useithreads} && lid_version() =~ /^3\./)
{
    require threads;

    plan tests => scalar(@tests) * 4;
}
else
{
    plan skip_all => "$^X does not support threads"
        unless $Config{useithreads};
    plan skip_all => "lid does not support threads in v" . lid_version();
}



## Start a separate thread for each test
foreach my $test (@tests)
{
    my $scalar = threads->create(
        sub {
            return {
                test => $test,
                res  => lid_fstr($test->{str})
            };
        }
    );
}


## Wait for and check all threads' return values
foreach my $t (threads->list())
{
    my $rv = $t->join();

    isnt($rv, undef, $t->tid() . ": return value not undef");

    is($Lingua::Lid::errstr, undef,
        $rv->{test}->{id} . ': $Lingua::Lid::errstr unset');

    is(Lingua::Lid::errstr(), undef,
        $rv->{test}->{id} . ': Lingua::Lid::errstr() returns undef');


    is_deeply($rv->{res}, $rv->{test}->{res},
        $rv->{test}->{id} . ": results correct");
}


# vim: sts=4 sw=4 ai et ft=perl
