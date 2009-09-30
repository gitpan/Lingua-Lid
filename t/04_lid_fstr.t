use strict;
use Test::More tests => 32;
use Encode qw/encode decode/;

use Lingua::Lid qw/lid_fstr/;


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


my $res;

$res = lid_fstr("");

# 1
is($Lingua::Lid::errstr, "Invalid argument", "Empty: errstr set correctly");

# 2
is($res, undef, "Empty: return -> undef");


$res = lid_fstr("\0" x 128);

# 3
is($Lingua::Lid::errstr, "Binary input data", "NUL: errstr set correctly");

# 4
is($res, undef, "NUL: return -> undef");


$res = lid_fstr(undef);

# 5
is($Lingua::Lid::errstr, "Invalid argument", "undef: errstr set correctly");

# 6
is($res, undef, "undef: return -> undef");


foreach my $test (@tests)
{
    $res = lid_fstr($test->{str});

    # 7...
    is($Lingua::Lid::errstr, undef, $test->{id} . ": errstr unset");

    # 8...
    is_deeply($res, $test->{res}, $test->{id} . ": results correct");
}


eval { lid_fstr("abc", "def") };

# 31
like($@, qr/^Usage:/, "Wrong usage #1: show usage");


eval { lid_fstr() };

# 32
like($@, qr/^Usage:/, "Wrong usage #2: show usage");

# vim: sts=4 sw=4 enc=utf-8 ai et ft=perl
