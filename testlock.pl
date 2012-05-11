#!/usr/bin/perl -w

use lib "blib/lib";
use DDLock::Client ();
use Data::Dumper ();

$Data::Dumper::Terse = 1;
$Data::Dumper::Indent = 1;

$| = 1;

my $DDServers =  [
	'localhost:7003',
	'localhost:7004',
	'localhost',
   ];

foreach my $servers ( $DDServers, [] ) {
	print "Creating client...";
	my $cl = new DDLock::Client ( servers => $servers )
		or die $DDLock::Client::Error;
	print "done:\n";

	print "Creating a 'foo' lock...";
	my $lock = $cl->trylock( "foo" )
		or print "Error: $DDLock::Client::Error\n";
	print "done.\n";

	if ( my $pid = fork ) {
		waitpid( $pid, 0 );
	} else {
		print "Trying to create a 'foo' lock in process $$...";
		my $lock2 = $cl->trylock( "foo" )
			or print "Error: $DDLock::Client::Error\n";
		print "done:\n";
		exit;
	}

	print "Releasing the 'foo' lock...";
	$lock->release or die;
	print "done.\n\n";
}




