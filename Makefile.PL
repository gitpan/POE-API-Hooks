# $Id: Makefile.PL 402 2004-10-08 05:26:09Z sungo $

use ExtUtils::MakeMaker;
WriteMakefile(
	NAME => 'POE::API::Hooks',
	AUTHOR => 'Matt Cashner (sungo@pobox.com)',
	VERSION_FROM => 'lib/POE/API/Hooks.pm',
	PREREQ_PM => {
		POE => '0',
		Params::Validate => '0',
	},
	dist => {
		PREOP => 'svn log -r 1:HEAD -v > Changes; perldoc -t lib/POE/API/Hooks.pm > README',
	},
);
