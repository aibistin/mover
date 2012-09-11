use strict;
use warnings;
use Test::More;


use Catalyst::Test 'mover';
use mover::Controller::Login;


#------ Login
$req = request('/login');
ok( $req->is_success, 'Login Request should succeed' );
#ok( request('/login')->is_success, 'Request should succeed' );
done_testing();
