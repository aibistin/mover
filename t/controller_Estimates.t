use strict;
use warnings;
use Test::More;
use Catalyst::Test 'mover';

use mover::Controller::Estimates;
#------ My Addiotions
#       Test Using Mechanize
use Test::WWW::Mechanize::Catalyst;
#------------------------------------------------------------
#
#
my ($mech, $req);

$mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'mover');
$mech->credentials( 'test04' , 'mypass' );

#------ Login
$req = request('/login');
ok( $req->is_success, 'Login Request should succeed from estimates Test script.' );

$mech->get('/');
#print "Printing web content 1.\n";
#print $mech->content;

#------ Login
#$req = request('/login');

#------ Estimate List
$req = request('/list');

ok( $req->is_success, 'Should get estimate list' );



#$mech->page_links_ok('Check all links');

#$mech->content_contains("Welcome to the world of Catalyst",
#	"Content contains hello world text");


#------ Schedule An Estimate
$mech->get_ok('/schedule_estimate');

$mech->submit_form( form_id => 'estForm',
	fields
=> {
	first_name =>  'Bazzer',
	last_name => 'GoBazza',
	address_1 => '516 5\'th Avenue ',
	city      => 'New York',
	state    =>  'NY',
	phone_1  => '2122224880',
	estimate_date => '2012-07-31',
	estimate_time =>  '10:00',
	estimator_id  => 1,
	comments      => 'Outstanding Stuff'
}
);



$req = request('/logout');
ok( $req->is_redirect, 'Logout Request should succeed' );

#------ THE END
done_testing();