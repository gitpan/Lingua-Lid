use strict;
use Test::More tests => 14;

use Lingua::Lid qw/lid_ffile/;

my @tests = (
    {
        file => "t/wikipedia_de_perl.txt",
        res  => {
            language => "German",
            isocode  => "deu",
            encoding => "UTF-8"
        },
    },
    {
        file => "t/wikipedia_en_perl.txt",
        res  => {
            language => "English",
            isocode  => "eng",
            encoding => "ASCII",
        },
    },
);

my $non_existent_file = "t/$$.txt";

my $res;

$res = lid_ffile($non_existent_file);

# 1
is($res, undef, "Non existent file: result -> undef");

# 2
is($Lingua::Lid::errstr, "Failed to open file",
                         "Non existent: errstr set correctly");


{
    no warnings; # on passing "undef" to lid_ffile()

    $res = lid_ffile(undef);
}

# 3
is($res, undef, "undef: result -> undef");

# 4
is($Lingua::Lid::errstr, "Failed to open file",
                         "undef: errstr set correctly");


$res = lid_ffile("");

# 5
is($res, undef, "empty: result -> undef");

# 6
is($Lingua::Lid::errstr, "Failed to open file",
                         "empty: errstr set correctly");


$res = lid_ffile("\0" x 128);

# 7
is($res, undef, "NUL: result -> undef");

# 8
is($Lingua::Lid::errstr, "Failed to open file", "NUL: errstr set correctly");


foreach my $test (@tests)
{
    $res = lid_ffile($test->{file});

    # 9 + 11
    is($Lingua::Lid::errstr, undef, $test->{file} . ": errstr unset");

    # 10 + 12
    is_deeply($res, $test->{res}, $test->{file} . ": results correct");
}


eval { lid_ffile("abc", "def") };

# 13
like($@, qr/^Usage:/, "Wrong usage #1: show usage");


eval { lid_ffile() };

# 14
like($@, qr/^Usage:/, "Wrong usage #2: show usage");

# vim: sts=4 sw=4 enc=utf-8 ai et ft=perl
