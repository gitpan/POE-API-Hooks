# $Id: Hooks.pm 443 2004-12-12 19:48:04Z sungo $
package POE::API::Hooks;
# pod at bottom

BEGIN {
	use POE;
	use vars qw(
			$orig_dispatch_event 
			$orig_session_create
			$orig_data_ev_enqueue 
			);

	$orig_dispatch_event  = \&POE::Kernel::_dispatch_event;
	$orig_session_create  = \&POE::Session::create;
	$orig_data_ev_enqueue = \&POE::Kernel::_data_ev_enqueue;

	*{'POE::Kernel::_dispatch_event'} = \&ima_bad_monkey_dispatch_event;
	*{'POE::Session::create'} = \&ima_bad_monkey_session_create;
	*{'POE::Kernel::_data_ev_enqueue'} = \&ima_bad_monkey_data_ev_enqueue;
}

use warnings;
use strict;

use Params::Validate qw(validate CODEREF);

our $VERSION = '1.'.sprintf "%04d", (qw($Rev: 443 $))[1];

my %HOOKS = (
	before_event_dispatch  => [],
	after_event_dispatch   => [],

	before_session_create  => [],
	after_session_create   => [],

	before_event_enqueue   => [],
	after_event_enqueue    => [],
);

sub add {
	my $class = shift;
	validate(@_, {
		before_event_dispatch => {
			type => CODEREF,
			optional => 1,
		},

		after_event_dispatch => {
			type => CODEREF,
			optional => 1,
		},

		before_session_create => {
			type => CODEREF,
			optional => 1,
		},

		after_session_create => {
			type => CODEREF,
			optional => 1,
		},

		before_event_enqueue => {
			type => CODEREF,
			optional => 1,
		},

		after_event_enqueue => {
			type => CODEREF,
			optional => 1,
		},
	});

	my %args = @_;

	if($args{before_event_dispatch}) {
		push @{ $HOOKS{before_event_dispatch} }, $args{before_event_dispatch};
	}
	if($args{after_event_dispatch}) {
		push @{ $HOOKS{after_event_dispatch} }, $args{after_event_dispatch};
	}
	if($args{before_session_create}) {
		push @{ $HOOKS{before_session_create} }, $args{before_session_create};
	}
	if($args{after_session_create}) {
		push @{ $HOOKS{after_session_create} }, $args{after_session_create};
	}
	if($args{before_event_enqueue}) {
		push @{ $HOOKS{before_event_enqueue} }, $args{before_event_enqueue};
	}
	if($args{after_event_enqueue}) {
		push @{ $HOOKS{after_event_enqueue} }, $args{after_event_enqueue};
	}

	return;
}

sub ima_bad_monkey_dispatch_event {
	my @args = @_;
	if(@{ $HOOKS{before_event_dispatch} }) {
		foreach my $sub (@{ $HOOKS{before_event_dispatch} }) {
			eval { $sub->(@args); };
		}
	}

	my $rc = $orig_dispatch_event->(@args);

	if(@{ $HOOKS{after_event_dispatch} }) {
		foreach my $sub (@{ $HOOKS{after_event_dispatch} }) {
			eval { $sub->(@args); };
		}
	}

	return $rc;
}

sub ima_bad_monkey_session_create {
	my @args = @_;
	if(@{ $HOOKS{before_session_create} }) {
		foreach my $sub (@{ $HOOKS{before_session_create} }) {
			eval { $sub->(@args); };
		}
	}

	my $rc = $orig_session_create->(@args);

	if(@{ $HOOKS{after_session_create} }) {
		foreach my $sub (@{ $HOOKS{after_session_create} }) {
			eval { $sub->(@args); };
		}
	}

	return $rc;
}

sub ima_bad_monkey_data_ev_enqueue {
	my @args = @_;
	if(@{ $HOOKS{before_event_enqueue} }) {
		foreach my $sub (@{ $HOOKS{before_event_enqueue} }) {
			eval { $sub->(@args); };
		}
	}

	my $rc = $orig_data_ev_enqueue->(@args);

	if(@{ $HOOKS{after_event_enqueue} }) {
		foreach my $sub (@{ $HOOKS{after_event_enqueue} }) {
			eval { $sub->(@args); };
		}
	}

	return $rc;
}

1;

__END__

=pod

=head1 NAME

POE::API::Hooks - Implement lightweight hooks into POE

=head1 SYNOPSIS

  use POE;
  use POE::API::Hooks;

  POE::API::Hooks->add(
      before_event_dispatch  => \&do_something,
      after_event_dispatch   => \&do_something,
      before_session_create  => \&do_something,
      after_session_create   => \&do_something,
      before_event_enqueue   => \&do_something,
      after_event_enqueue    => \&do_something,
  );

  # ... carry on with life as normal ...

=head1 DISCUSSION

This module adds lightweight hooks into the inner workings of POE.
Currently, one can add hooks into POE that get called before/after an
event is dispatched, before/after a Session is created, and/or
before/after an event is enqueued.  These callbacks receive the exact
same argument list as their Kernel/Session counterpart. For event
dispatch related callbacks, see C<_dispatch_event> and
C<_data_ev_enqueue> in L<POE::Kernel>.
For session related callbacks, see C<create> in L<POE::Session>.

=head1 BUGS

When $_[KERNEL]->call($_[SESSION], "event") is used, _event_dispatch is
bypassed.  This is an optimization, not a bug, but it will cause the
event_dispatch hook to be bypassed under this condition.  Someone
relying on the event_dispatch hook may call this a bug.

=head1 AUTHOR

Matt Cashner (sungo@pobox.com)

=head1 DATE

$Date: 2004-12-12 14:48:04 -0500 (Sun, 12 Dec 2004) $

=head1 REVISION

$Rev: 443 $

=head1 LICENSE

Copyright (c) 2004, Matt Cashner. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

=over 4

=item * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

=item * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

=item * Neither the name of the Matt Cashner nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

=back

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut

# sungo // vim: ts=4 sw=4 noexpandtab
