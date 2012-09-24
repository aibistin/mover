#!/usr/bin/env perl

#-------------------------------------------------------------------------------
#  Use Mechanize to test my mover app
#  Test all Customer Related Actions
#  Create,  Update,  Details etc
#-------------------------------------------------------------------------------
use Modern::Perl 2010;
use autodie;

#use strict;
#use warnings;

use Data::Dumper;
use Log::Log4perl;

#use WebService::Validator::HTML::W3C;
use Try::Tiny;
use Test::More;

diag <<EOF

*******************************WARNING*****************************
The APP_TEST environment variable is not set. Please run this test
script with the APP_TEST variable set to one (e.g. APP_TEST=1 prove –l
ensure that the authentication component of the application is tested
properly.
EOF
  if !$ENV{APP_TEST};

plan skip_all => 'Set APP_TEST for the tests to run fully' if !$ENV{APP_TEST};

BEGIN { use_ok( "Test::WWW::Mechanize::Catalyst" => "mover" ) }

#-------------------------------------------------------------------------------
#  Set Up Logging
#-------------------------------------------------------------------------------
my $LOG_CONFIG_FILE = '/home/austin/perl/log.conf';

Log::Log4perl->init($LOG_CONFIG_FILE);
my $log = Log::Log4perl->get_logger("Test::Mech");

#-------------------------------------------------------------------------------
#  Constant Types
#-------------------------------------------------------------------------------
my $TRUE  = 1;
my $FALSE = 0;

my $ADMIN_1  = 'admin';
my $REG_USER = 'helper01';

my $TEST_HTML      = $FALSE;
my $TEST_LINKS     = $TRUE;
my $TEST_REDIRECTS = $TRUE;
my $TEST_LOGIN     = $TRUE;
my $TEST_FORMS     = $TRUE;
my $URL            = 'url';
my $FORM           = 'form';
my $HOST           = $ENV{CATALYST_SERVER};

#my $customer_info = {
#
#    #    id             => undef,
#    last_name  => 'brown',
#    first_name => 'john',
#
#    #    m_i            => 'h',
#    prefix => 'Mr',
#
#    #    suffix         => 'Sr',
#    alias     => undef,
#    address_1 => '23 franklin St',
#    address_2 => '7N',
#    city      => 'New York ',
#    state     => 'NY',
#    zip       => '11101',
#    phone_1   => '212 2522222',
#
#    #    phone_2        => undef,
#    #    phone_3        => undef,
#    email_1 => 'john@brown.com',
#    email_2 => 'glory@gory.com',
#
#    #    recommended_by => '',
#    repeat => 0,
#
##type 0=not customer, 1=customer, 2=repeat customer, 3=account, 4=decorator, 5=super,6=friend,7=trouble
##    type     => undef,
#    comments => 'May be moving down south in the furure.',
#};
#
#my $customer_info = {
#    id             => undef,
#    last_name      => 'graybeard',
#    first_name     => 'bill',
#    m_i            => 'h',
#    prefix         => 'Mr',
#    suffix         => 'Sr',
#    alias          => undef,
#    address_1      => '455 Park Avenue',
#    address_2      => '2f',
#    city           => 'New York ',
#    state          => 'NY',
#    zip            => '11100 ',
#    phone_1        => '212 2222222',
#    phone_2        => undef,
#    phone_3        => undef,
#    email_1        => 'bill@thebeard.com',
#    email_2        => undef,
#    recommended_by => 'His brother Fred',
#    repeat         => 1,
#
##type 0=not customer, 1=customer, 2=repeat customer, 3=account, 4=decorator, 5=super,6=friend,7=trouble
#    type     => undef,
#    comments => 'Could use the special repeat customer rate',
#};
#
my $customer_info = {

    #    id             => undef,
    last_name  => 'frankelberg',
    first_name => 'residence',

    #    m_i            => 'h',
    prefix => 'Ms.',

    #    suffix         => 'Sr',
#    alias     => undef,
    address_1 => '224 East 73 Street',
    address_2 => '5K',
    city      => 'New York ',
    state     => 'NY',
    zip       => '11111',
    phone_1   => '212 2522622',
    phone_2   => '917 4454545',

    #    phone_3        => undef,
    email_1 => 'betty@address.com',

    recommended_by => 'Igor the super',
    repeat         => 3,

#type 0=not customer, 1=customer, 2=repeat customer, 3=account, 4=decorator, 5=super,6=friend,7=trouble
#    type     => undef,
    comments => 'Lots of fine china.',
};
#
my %test_list_h = (
    test_html      => $FALSE,
    test_links     => $TRUE,
    test_redirects => $TRUE,
    test_login     => $TRUE,
    test_forms     => $TRUE,
    test_customer  => $TRUE,
);

#-------------------------------------------------------------------------------
# Create two 'user agents' to simulate two different users ($ADMIN_1' & $REG_USER')
#-------------------------------------------------------------------------------
my $admin_user = Test::WWW::Mechanize::Catalyst->new;
my $basic_user = Test::WWW::Mechanize::Catalyst->new;

#------ Allow Redirects
$admin_user->requests_redirectable( [qw/ GET HEAD POST /] );
$basic_user->requests_redirectable( [qw/ GET HEAD POST /] );

#-------------------------------------------------------------------------------

my $user_list = [
    {
        user_agent     => $basic_user,
        user_id        => 'helper01',
        user_pwd       => 'Helper-101',
        user_nick_name => 'Peon',
        login_type     => $FORM,
        test_list      => \%test_list_h,
    },

    {
        user_agent     => $admin_user,
        user_id        => 'admin',
        user_pwd       => 'Mover-101',
        user_nick_name => 'Superuser',
        login_type     => $FORM,
        test_list      => \%test_list_h,
    }
];

#-------------------------------------------------------------------------------
#  Remember to test access to pages when NOT logged in
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# Second arg = optional description of test (will be displayed for failed tests)
# Note that in test scripts you send everything to 'http://localhost'
#-------------------------------------------------------------------------------
$_->{user_agent}->get_ok( '/', "Get Opening Web Page" ) for @$user_list;

#-------------------------------------------------------------------------------
#        Test Intro Page
#-------------------------------------------------------------------------------
$user_list = test_intro_page($user_list);

#-------------------------------------------------------------------------------
#    Test Login Page
#    Get Login form and fill it out to log in
#    Afterwards,  test if users are logged in.
#-------------------------------------------------------------------------------

$user_list = test_login_page_login($user_list);

#------ See if these users are really logged in
$user_list = test_if_logged_in($user_list);

#-------------------------------------------------------------------------------
#  Test Create A Customer
#-------------------------------------------------------------------------------
$user_list = test_customer_create($user_list);

#-------------------------------------------------------------------------------
#  Logout
#-------------------------------------------------------------------------------
$user_list = logout_and_test_logout($user_list);

#-------------------------------------------------------------------------------
done_testing;

1;

#-------------------------------------------------------------------------------
#  Functions
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#        Test Intro Page
#  Testing the Intro Page Before Log In
#-------------------------------------------------------------------------------
sub test_intro_page {
    my ($users) = @_;

    #------ Test First User only
    my $user = $users->[0];
    $user->{user_agent}->title_is( "Introduction To Moving Management",
        "Intro - Check for page title $user->{user_id}" );

    $user->{user_agent}->content_contains( "Moving Company Management System",
        "Intro - Check Page Heading $user->{user_id}" );

    return $users;
}

#-------------------------------------------------------------------------------
#  Test Login Page and Login
#  Get the Login page.
#  Log In using the Login form
# Users will be logged in after this test
#-------------------------------------------------------------------------------
sub test_login_page_login {
    my ($users) = @_;
    #
    $_->{user_agent}
      ->get_ok( '/login', "Login Test - Get the login page $_->{user_id}" )
      for @$user_list;

    $_->{user_agent}->title_is(
        "Login", "Login - Check for login page title
        $_->{user_id}"
    ) for @$users;

    #------ log in with form or with parms in URL

    for my $user (@$users) {

        #------ Log in using the "Sign In" Button
        $user->{user_agent}->set_fields(
            username => $user->{user_id},
            password => $user->{user_pwd}
        );
        $user->{user_agent}
          ->click_ok( 'submit', "Click the Sign In Button to Login" );
    }

    #------ Test if the Username Password were rejected.
    $_->{user_agent}->content_lacks( "Bad username or password",
        "Logged In - $_->{user_id} Username and password were accepted." )
      for @$users;

    $_->{user_agent}->title_unlike( qr/Login(.*)/,
        "Logged In - Redirected from Login Page for $_->{user_id}" )
      for @$users;
    return $users;
}

#-------------------------------------------------------------------------------
#  Test Create A Customer
#  Create a new custome
#  Test This Creation
#-------------------------------------------------------------------------------
sub test_customer_create {
    my ($users) = @_;

    #------ Go to Customer Create Page
    $_->{user_agent}->get_ok( '/customer/create_customer',
        "Create Customer - Got the Create Customer Page for $_->{user_id}" )
      for @$users;

    $_->{user_agent}->title_is( "Customer Entry",
        "Has Title For Customer Creation Page $_->{user_id}" )
      for @$users;

    my $user_a = $users->[1];

    #------ Create Customer Using Formfu form

    $user_a->{user_agent}->submit_form(
        form_id => 'custForm',
        fields  => $customer_info,
        button  => 'submit',
    );

    #    $user_a->{user_agent}->click_ok(
    #        'submit', "Create Customer - Click the Add Customer
    #                  Buttton to create a Shiny new Customer"
    #    );

    $user_a->{user_agent}->title_is(
        "Customer Detail",
"Create Customer - Has Redirected to Customer Details Page after New Customer for $user_a->{user_id}"
    );

    $user_a->{user_agent}->content_contains( lc($customer_info->{last_name}),
"Create Customer - Has Created Record for $customer_info->{last_name} by User: $user_a->{user_id}"
    );

    $user_a->{user_agent}->content_like(
        qr/(phone 1:).*(\d\d\d\d\d\d\d\d\d)/,
"Create Customer - Has Phone number displayed in details page for User: $user_a->{user_id}"
    );

    $user_a->{user_agent}->content_like(
        qr/(customer id:).*(\d)/i,
"Create Customer - Has Generated a Customer Id by User: $user_a->{user_id}"
    );

    return $users;
}

#-------------------------------------------------------------------------------`
# Go back to the login page and it should show that we are already logged in
#  Test Login Page After user logs in.
# Users remain logged in after this test.
#-------------------------------------------------------------------------------
sub test_login_page_after_login {
    my ($users) = @_;

    $_->{user_agent}->get_ok( "/login",
        "Login Page When Logged In - Return to Login Page. $_->{user_id}" )
      for @$users;

    # First user will do for the rest of these tests
    my $user = $users->[0];

    $user->{user_agent}->title_is( "Login",
"Login Page When Logged In - Title check for Login page $user->{user_id}"
    );
    $user->{user_agent}->content_like(
        qr/Please ?Note/i,
        "Login Page When Logged In - Already Logged In Motification message
        displayed $user->{user_id}"
    );

    $user->{user_agent}->content_like( qr/logout/i,
        "Login Page When Logged In - Logout link present for $user->{user_id}"
    );
    return $users;
}

#-------------------------------------------------------------------------------
#  Check If List of Users are Logged In
#  Passed a list of users
#  Users will remain logged in after this test
#-------------------------------------------------------------------------------
sub test_if_logged_in {
    my ($users) = @_;

    $_->{user_agent}->content_contains( $_->{user_id},
"Logged In Test - Content contains User ID: $_->{user_id} is present when logged into site."
    ) for @$users;

    $_->{user_agent}->text_contains( $_->{user_id},
"Logged In Test - Text like User ID: $_->{user_id} is present when logged into site."
    ) for @$users;

    #------ Chek Logout Link for first user in list
    $_->{user_agent}->content_like( qr/logout/i,
        "Logged In Test - $_->{user_id} has a logout link when logged in." )
      for @$users;

    return $users;
}

#-------------------------------------------------------------------------------
#  Test Logout
# Users will remain logged out after this test.
#-------------------------------------------------------------------------------
sub logout_and_test_logout {
    my ($users) = @_;

    #------ Test for the first user in list and some tests using all users
    #       in list.
    my $user = $users->[0];

    $_->{user_agent}->get_ok( "/logout",
        "Logout -  Logout and be redirected back to intro page $_->{user_id}" )
      for @$users;

    $_->{user_agent}->title_is(
        "Introduction To Moving Management",
"Logout - Introduction..... Title present in after logout redirection for $_->{user_id}"
    ) for @$users;

    $user->{user_agent}->content_contains(
        "Introduction To Moving Management",
"Logout - Content Headline for Introduction To ..... is present for $user->{user_id}"
    );

    return $users;
}

