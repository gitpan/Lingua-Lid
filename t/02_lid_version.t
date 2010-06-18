use strict;
use Test::More tests => 9;

use Lingua::Lid qw/lid_version lid_version_ct/;

my $supported = qr/^[23]\.\d+\.\d+$/;


my $v_rt = lid_version();     # runtime version
my $v_ct = lid_version_ct();  # compile time version

# 1
ok($v_rt,                   "lid_version returns a true value");

# 2
ok($v_rt =~ /^[\d.]+$/,     "lid_version returns a version number");

# 3
ok($v_rt =~ /^$supported$/, "lid_version: supported version");


eval { lid_version("invalid") };

# 4
like($@, qr/^Usage:/,       "Wrong invocation: show usage");

# 5
ok($v_ct,                   "lid_version_ct returns a true value");

# 6
ok($v_ct =~ /^[\d.]+$/,     "lid_version_ct returns a version number");

# 7
ok($v_ct =~ /^$supported$/, "lid_version_ct: supported version");


eval { lid_version_ct("invalid") };

# 8
like($@, qr/^Usage:/,       "Wrong invocation: show usage");

# 9
is($v_rt, $v_ct,            "Compile time version == runtime version");

# vim: sts=4 sw=4 enc=utf-8 ai et ft=perl
