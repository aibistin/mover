#!/usr/bin/perl
#
#Run with DBIC_TRACE=1 perl -Ilib set_hashed_passwords.pl
#
use strict;
use warnings;
use mover::Schema;
my $schema = mover::Schema->connect('dbi:SQLite:mover.db');
my @users = $schema->resultset('User')->all;
my ($password);
foreach my $user (@users) {
        print"\n User is : ". $user->id() . " with username : ".
        $user->username() . "  \n";
#        print"\n User password is : " . $user->password() . "  \n";
#        my $password = $user->password();
        if ($user->id() == '1'){
	         $user->password('Mover-101');
            }
            else{
	         $user->password('Helper-101');
            }
	$user->update;
}
