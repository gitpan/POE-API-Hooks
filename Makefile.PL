# $Id: Makefile.PL 476 2005-04-30 17:31:43Z sungo $

use ExtUtils::MakeMaker;
WriteMakefile(
	NAME => 'POE::API::Hooks',
	AUTHOR => 'Matt Cashner (sungo@pobox.com)',
	VERSION_FROM => 'VERSION',
	PREREQ_PM => {
		POE => '0',
		Params::Validate => '0',
	},
	dist => {
		PREOP => 'svn log -r 1:HEAD -v > Changes; perldoc -t lib/POE/API/Hooks.pm > README',
	},
);
