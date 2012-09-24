use strict;
use warnings;
use Test::More;


use Catalyst::Test 'mover';
use mover::Controller::Logout;

my $req = request('/logout');
ok( $req->is_redirect, 'Logout Request should succeed' );

#ok( request('/logout')->is_success, 'Request should succeed' );
done_testing();
