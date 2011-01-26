#
# Alex Linke <alinke@lingua-systems.com>
#
# Copyright (c) 2010-2011 Lingua-Systems Software GmbH
#

use strict;
use warnings;
use Test::More;
use Config;

use Lingua::Lid qw/lid_ffile lid_version/;

my @tests = (
    { file => "/nonexistent.$$.txt", errstr => "Failed to open file" },
    { file => "/dev/null",           errstr => "Insufficient input length" },
    { file => $^X,                   errstr => "Binary input data" },
    { file => $0,                    errstr => undef }
);
my $thr_each = 5;


if ($Config{useithreads} && lid_version() =~ /^3\./)
{
    require threads;
    require Time::HiRes;

    plan tests => scalar(@tests) * $thr_each * 2;
}
else
{
    plan skip_all => "$^X does not support threads"
        unless $Config{useithreads};
    plan skip_all => "lid does not support threads in v" . lid_version();
}


foreach my $test (@tests)
{
    my $scalar = threads->create( sub {

        my $res = {
            errstr_ok => $test->{errstr},
            file      => $test->{file},
            errstrs   => []
        };

        lid_ffile($test->{file});

        ## Check thread safety of both errstr package variable and function
        foreach (1..$thr_each)
        {
            Time::HiRes::usleep(10_000);

            push @{$res->{errstrs}},
                {
                    var  => $Lingua::Lid::errstr,
                    func => Lingua::Lid::errstr()
                };
        }

        return $res;
    });
}


for my $t (threads->list())
{
    my $res = $t->join();
    my $nr  = 0;

    foreach my $e (@{$res->{errstrs}})
    {
        $nr++;

        is($e->{var},  $res->{errstr_ok},
            $res->{file} . ": \$Lingua::Lid::errstr (threaded #$nr)");
        is($e->{func}, $res->{errstr_ok},
            $res->{file} . ": Lingua::Lid::errstr() (threaded #$nr)");
    }
}


# vim: sts=4 sw=4 ai et
