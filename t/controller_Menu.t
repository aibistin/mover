use strict;
use warnings;
use Test::More;


use Catalyst::Test 'mover';
use mover::Controller::Menu;

ok( request('/menu')->is_success, 'Request should succeed' );
done_testing();
