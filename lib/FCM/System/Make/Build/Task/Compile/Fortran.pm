# ------------------------------------------------------------------------------
# (C) British Crown Copyright 2006-15 Met Office.
#
# This file is part of FCM, tools for managing and building source code.
#
# FCM is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# FCM is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with FCM. If not, see <http://www.gnu.org/licenses/>.
# ------------------------------------------------------------------------------
use strict;
use warnings;
# ------------------------------------------------------------------------------
package FCM::System::Make::Build::Task::Compile::Fortran;
use base qw{FCM::System::Make::Build::Task::Compile};

our %PROP_NO_PREPROCESS_OF = (
    'fc'               => 'gfortran',
    'fc.flags'         => '',
    'fc.flag-compile'  => '-c',
    'fc.flag-include'  => '-I%s',
    'fc.flag-module'   => '',
    'fc.flag-omp'      => '',
    'fc.flag-output'   => '-o%s',
    'fc.include-paths' => '',
);

our %PROP_OF = (
    %PROP_NO_PREPROCESS_OF,
    'fc.defs'          => '',
    'fc.flag-define'   => '-D%s',
);

sub new {
    my ($class, $attrib_ref) = @_;
    bless(
        $class->SUPER::new(
            {name => 'fc', prop_of => \&_prop_of, %{$attrib_ref}},
        ),
        $class,
    );
}

sub _prop_of {
    my ($attrib_ref, $target) = @_;
    if (!defined($target)) {
        return {%PROP_OF};
    }
    my $file_ext = $attrib_ref->{util}->file_ext($target->get_path_of_source());
    (lc($file_ext) eq $file_ext) ? {%PROP_NO_PREPROCESS_OF} : {%PROP_OF};
}

# ------------------------------------------------------------------------------
package FCM::System::Make::Build::Task::Compile::Fortran::Extra;
use base qw{FCM::Class::CODE};

use FCM::System::Exception;
use File::Basename qw{basename};

my $E = 'FCM::System::Exception';

our %PROP_OF = %FCM::System::Make::Build::Task::Compile::Fortran::PROP_OF;

__PACKAGE__->class(
    {prop_of => {isa => '%', default => {%PROP_OF}}},
    {action_of => {main => \&_main, prop_of => sub {\%PROP_OF}}},
);

sub _main {
    my ($attrib_ref, $target) = @_;
    my ($source, $dest) = (basename($target->get_key()), $target->get_path());
    if (!-e $source) {
        return;
    }
    rename($source, $dest) || return $E->throw($E->COPY, [$source, $dest], $!);
    $target;
}

# ------------------------------------------------------------------------------
1;
__END__

=head1 NAME

FCM::System::Make::Build::Task::Compile::Fortran

=head1 SYNOPSIS

    use FCM::System::Make::Build::Task::Compile::Fortran;
    my $task = FCM::System::Make::Build::Task::Compile::Fortran->new(\%attrib);
    $task->main($target);

=head1 DESCRIPTION

Wraps L<FCM::System::Make::Build::Task::Compile> to compile a Fortran source into
an object.

The module also provides the
FCM::System::Make::Build::Task::Compile::Fortran::Extra class to deal with the
module definition file generated by the compiler in the working directory.

=head1 COPYRIGHT

(C) Crown copyright Met Office. All rights reserved.

=cut
