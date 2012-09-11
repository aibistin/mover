use strict;
use warnings;
use Test::More;


use Catalyst::Test 'mover';
use mover::Controller::Intro;

ok( request('/intro')->is_success, 'Request should succeed' );
done_testing();
