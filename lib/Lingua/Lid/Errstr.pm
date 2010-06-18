package Lingua::Lid::Errstr;

#
# Alex Linke <alinke@lingua-systems.com>
#
# Copyright (c) 2010 by Lingua-Systems Software GmbH
#

use strict;
use Tie::Scalar;
use Carp qw/confess/;

use Lingua::Lid;

our @ISA = qw/Tie::Scalar/;

our $VERSION = '0.01';


sub TIESCALAR
{
    my $self;
    return bless \$self, __PACKAGE__;
}


sub FETCH
{
    return Lingua::Lid::errstr();
}


sub STORE
{
    confess('Storing values to $Lingua::Lid::errstr prohibited');
}


1;


=head1 NAME

Lingua::Lid::Errstr - provides $Lingua::Lid::errstr

=head1 SYNOPSIS

    use Lingua::Lid;
     
    print $Lingua::Lid::errstr, "\n";
     
    print Lingua::Lid::errstr(), "\n";  # preferred

=head1 DESCRIPTION

B<Lingua::Lid::Errstr> implements a thread-safe replacement of the former
package variable B<$Lingua::Lid::errstr>.

=head1 NOTES

B<$Lingua::Lid::errstr> is provided for backwards compatibility with
B<Lingua::Lid> v0.01. It may be removed in a future release. Any new code
using B<Lingua::Lid> should utilize the function B<Lingua::Lid::errstr>().

=head1 AUTHOR

Alex Linke E<lt>alinke@lingua-systems.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 Lingua-Systems Software GmbH

This extension is free software. It may be used, redistributed and/or
modified under the terms of the zlib license. For details, see the full text
of the license in the file LICENSE.

=cut


# vim: sts=4 sw=4 enc=utf-8 et ai
