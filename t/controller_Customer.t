use strict;
use warnings;
use Test::More;


use Catalyst::Test 'mover';
use mover::Controller::Customer;

ok( request('/customer')->is_success, 'Request should succeed' );
done_testing();
