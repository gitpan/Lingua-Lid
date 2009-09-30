use strict;
use Test::More tests => 4;

use Lingua::Lid qw/lid_version/;

my $supported = qr/2\.0\.\d+/;


my $v = lid_version();

# 1
ok($v,                   "lid_version returns a true value");

# 2
ok($v =~ /^[\d.]+$/,     "lid_version returns a version number");

# 3
ok($v =~ /^$supported$/, "supported version");


eval { lid_version("abc") };

# 4
like($@, qr/^Usage:/,    "Wrong invocation: show usage");

# vim: sts=4 sw=4 enc=utf-8 ai et ft=perl
