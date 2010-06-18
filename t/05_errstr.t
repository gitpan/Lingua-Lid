#
# Alex Linke <alinke@lingua-systems.com>
#
# Copyright (c) 2010 Lingua-Systems Software GmbH
#

use strict;
use warnings;
use Test::More;

use Lingua::Lid qw/lid_ffile/;

my @tests = (
    { file => "/nonexistent.$$.txt", errstr => "Failed to open file" },
    { file => "/dev/null",           errstr => "Insufficient input length" },
    { file => $^X,                   errstr => "Binary input data" },
    { file => $0,                    errstr => undef }
);

plan tests => (scalar(@tests) * 2) + 1;


eval { $Lingua::Lid::errstr = "test"; };
like($@, qr/prohibited/, 'Storing to $Lingua::Lid::errstr prohibited');


foreach my $test (@tests)
{
    lid_ffile($test->{file});

    is($Lingua::Lid::errstr,  $test->{errstr},
        $test->{file} . ': $Lingua::Lid::errstr');
    is(Lingua::Lid::errstr(), $test->{errstr},
        $test->{file} . ': Lingua::Lid::errstr()');
}


# vim: sts=4 sw=4 enc=utf-8 ai et
