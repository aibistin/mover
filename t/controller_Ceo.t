use strict;
use warnings;
use Test::More;


use Catalyst::Test 'mover';
use mover::Controller::Ceo;

ok( request('/ceo')->is_success, 'Request should succeed' );
done_testing();
