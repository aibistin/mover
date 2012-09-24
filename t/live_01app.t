#!/usr/bin/env perl

#-------------------------------------------------------------------------------
#  Use Mechanize to test my mover app
#  Tests The Log Out And Log In Actions
#-------------------------------------------------------------------------------
use Modern::Perl 2010;
use autodie;

#use strict;
#use warnings;

use Data::Dumper;
use Log::Log4perl;
use WebService::Validator::HTML::W3C;
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

#SKIP: {
#    skip "Set APP_TEST for the tests to run fully",
#    skip_all if !$ENV{APP_TEST};
#}:
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

my %test_list_h = (
    test_html      => $FALSE,
    test_links     => $TRUE,
    test_redirects => $TRUE,
    test_login     => $TRUE,
    test_forms     => $TRUE,
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
#  Test Logging Out and Logging In Again
#-------------------------------------------------------------------------------

$user_list = test_logout_and_log_in_again($user_list);

#-------------------------------------------------------------------------------
# Go back to the login page and it should show that we are already logged in
#-------------------------------------------------------------------------------
$user_list = test_login_page_after_login($user_list);

#-------------------------------------------------------------------------------
#  Check the Logout Link.
#  Log out.
#-------------------------------------------------------------------------------

$user_list = logout_and_test_logout($user_list);

#-------------------------------------------------------------------------------
# Log back in and Test Login Page again
#-------------------------------------------------------------------------------
$_->{user_agent}->get_ok( '/login',
"Intro page - Click on Enter button to Return to the Login Page for $_->{user_id}"
) for @$user_list;

$user_list = test_login_page_login($user_list);
#
# See if these users are really logged in
#$user_list = test_if_logged_in($user_list);

#-------------------------------------------------------------------------------
# Test The Main Menu Page
# Should be Redirected to Main Menu after Login
#-------------------------------------------------------------------------------

$user_list = test_main_menu($user_list);

#-------------------------------------------------------------------------------
#  Test Estimates Menu Page
#-------------------------------------------------------------------------------
$user_list = test_estimates_menu($user_list);



#-------------------------------------------------------------------------------
#  Test Create A Customer
#-------------------------------------------------------------------------------
$user_list = test_customer_create($user_list);

#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#  Test logout  and Logout
#-------------------------------------------------------------------------------
   logout_and_test_logout($user_list);
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

    $user->{user_agent}->content_contains(
        "What it does",
        "Intro - Brief descripion of what this applicaion does $user->{user_id}"
    );

    $user->{user_agent}->page_links_ok(
        "Intro - Check all links on the Intro
        page $user->{user_id}"
    );

    $user->{user_agent}->content_contains(
        "/login\">Sign In</a>",
"Intro - Check for 'Sign In' menu item From Top Toolbar Menu $user->{user_id}"
    );
    $user->{user_agent}->content_like(
        qr/(\/login).+Enter /,
        "Intro - Check for 'Enter' Button with a login link. $user->{user_id}"
    );

    #------ Checks the HTML on the Intro Page
    if ( $user->{test_list}->{test_html} ) {
        $user->{user_agent}
          ->html_lint_ok("Intro - HTML validity check. $user->{user_id}");
    }

    #------ Check Link to Login Page
    $user->{user_agent}->follow_link_ok( { text_regex => qr/enter/i },
        "Inro Page - Enter -> Link check to Login Page $user->{user_id}" );

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
    #    $log->debug( "Check Login Page - Users Type ." . ref($users) );
    #    for my $waster (@$users) {
    #        $log->debug("Check Login Page - Users Id .$waster->{user_id}.");
    #    }
    $_->{user_agent}
      ->get_ok( '/login', "Login Test - Get the login page $_->{user_id}" )
      for @$user_list;

    $_->{user_agent}->title_is(
        "Login", "Login - Check for login page title
        $_->{user_id}"
    ) for @$users;

    #Checks the HTML on the Login Page
    if ( $users->[0]->{test_list}->{test_html} ) {
        $users->[0]->{user_agent}->html_lint_ok(
            "Login - HTML on Login page -
            $users->[0]->{user_id}"
        );
    }

    #------ log in with form or with parms in URL

    for my $user (@$users) {

        # Login Using the Login Form
        if ( $user->{login_type} eq $FORM ) {

            #------ Log in using the "Sign In" Button
            $user->{user_agent}->set_fields(
                username => $user->{user_id},
                password => $user->{user_pwd}
            );
            $user->{user_agent}
              ->click_ok( 'submit', "Click the Sign In Button to Login" );

        }
        else {
            #------ log in using URL instead of a form
            $user->{user_agent}->get_ok(
"http://localhost/login?username=$user->{user_id}&password=$user->{user_pwd}",
                "Login $user->{user_id} using URL"
            );
        }

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
# Log out and log back in again. Test actions and results.
#
# Users will be logged in after this test.
#-------------------------------------------------------------------------------
sub test_logout_and_log_in_again {
    my ($users) = @_;

    $users = test_login_page_after_login($users);

    # First user will do for the rest of these tests
    my $user = $users->[0];

    $_->{user_agent}->get_ok( "/logout", "Logout -> Back to Inro Page" )
      for @$users;

    #------ Intro Page Should Be Displayed after Logout
    $users = test_intro_page($users);

    #------ Go to Login Page
    $_->{user_agent}->get_ok( '/login',
        "Intro Page - Click on Enter -> Get Login Page. $_->{user_id}" )
      for @$users;

    #Check Login Page again.Pass Parameers in URl this time
    # Log In
    $users = test_login_page_login($users);

    # See if these users are really logged in
    $users = test_if_logged_in($users);

    return $users;
}

#-------------------------------------------------------------------------------
#  Test The Main Mover Menu
#  User Must be logged in to test this
#-------------------------------------------------------------------------------
sub test_main_menu {
    my ($users) = @_;

    # See if these users are really logged in
    $users = test_if_logged_in($users);

    for my $u (@$users) {

        $u->{user_agent}->title_like(
            qr/Main Menu/, "Main Menu - Main Menu Title
            $u->{user_id}"
        );

        $u->{user_agent}->content_like( qr/Main Menu/,
            "Main Menu - Main Menu Heading $u->{user_id}" );
    }

    #------- The first User in the list is enough for this test
    my $user = $users->[0];

    $user->{user_agent}->content_contains( "menu/estimates_menu",
        "Main Menu - Link (button) to the Estimates Menu $user->{user_id}" );

    $user->{user_agent}->content_contains( "menu/customer_menu",
        "Main Menu - Link (button) to the Customer Menu $user->{user_id}" );

    # Check For Menu Button Types
    #    $user->{user_agent}->content_contains(
    #        "Estimates", "Main Menu - Estimates Button $user->{user_id}"
    #    );

    #    $user->{user_agent}->content_contains(
    #        "Customers", "Main Menu - Customers Button $user->{user_id}"
    #    );
    #
    #    $user->{user_agent}->content_contains(
    #        "Dispatch", "Main Menu - Dispatch
    #            Button $user->{user_id}"
    #    );

    #    $user->{user_agent}->content_contains(
    #        "Storage", "Main Menu - Storage
    #            Button $user->{user_id}"
    #    );
    #
    #    $user->{user_agent}->content_contains(
    #        "Fleet", "Main Menu - Fleet Button
    #            $user->{user_id}"
    #    );

    #    $user->{user_agent}->content_contains(
    #        "Equipment", "Main Menu -
    #            Equipment Button $user->{user_id}"
    #    );
    #
    #    $user->{user_agent}->content_contains(
    #        "Admin", "Main Menu - Admin Button
    #            $user->{user_id}"
    #    );

    #------ Check the HTML on the Main Menu Page
    if ( $user->{test_list}->{test_html} ) {

        $user->{user_agent}
          ->html_lint_ok("Main Menu - HTML on Main Menu Page $user->{user_id}");

    }

    #------ Check All followable Links on Main menu Page
    #    my @menu_links = $user->{user_agent}->followable_links();

    #    $_->{user_agent}->links_ok(
    #        \@menu_links, "Main Menu - Check all FOLLOWABLE links on Main Menu
    #    Page. $_->{user_id}"
    #    ) for @$users;

    #------ Just check the Important Menu Links
    my @menu_links = qw(/menu/estimates_menu /menu/customers_menu );
    $_->{user_agent}->links_ok(
        \@menu_links, "Main Menu - Check Main Menu links
            $_->{user_id}"
    ) for @$users;

    #    $_->{user_agent}->page_links_ok(
    #        "Check ALL links on the Main Menu Page
    #            $_->{user_id}"
    #    ) for @$users;

    return $users;
}

#-------------------------------------------------------------------------------
#  Test Estimates Menu Page
#  Get this page first,  then test the buttons and links.
#-------------------------------------------------------------------------------
sub test_estimates_menu {
    my ($users) = @_;

    #------ Go to Estimates menu Page
    $_->{user_agent}->get_ok( '/menu/estimates_menu',
        "Estimates Menu - Got tht Estimates Menu Page for $_->{user_id}" )
      for @$users;

    for my $user (@$users) {

        #------ Check the title
        $user->{user_agent}->title_is( "Estimates Menu",
            "Estimates Menu Title for $user->{user_id}" );

        $users = test_if_logged_in($users);

        $user->{user_agent}->content_contains( "Estimates Department",
            "Estimates Menu - Estimates Menu Heading for $user->{user_id}" );

        $user->{user_agent}->content_contains(
            "Schedule, Modify And View Estimates",
            "Estimates Menu - Estimates Menu Sub Heading for $user->{user_id}"
        );

        #Checks the HTML on the Estimates Menu Page
        if ( $user->{test_list}->{test_html} ) {
            $user->{user_agent}->html_lint_ok("HTML on Estimates Menu Page");
        }

        $user->{user_agent}->content_contains(
            "Schedule A Visual Estimate",
"Estimates Menu - $user->{user_id} should have a Schedule A Visual Estimate Link"
        );
        $user->{user_agent}->content_contains(
            "Complete A Phone Estimate",
"Estimates Menu - $user->{user_id} should have a Schedule A Complete A Phone Estimate Link"
        );

        #    "$user->{user_id}' should NOT have a create link");
        $user->{user_agent}->content_contains(
            "List Estimates",
"Estimates Menu - $user->{user_id} should have a button description to list estimates."
        );

        #------ Check All followable Links on Estimates menu Page
        my @est_menu_links = $user->{user_agent}->followable_links();
        $user->{user_agent}->links_ok( \@est_menu_links,
"Estimates Menu - Check all FOLLOWABLE links on Estimates Menu Page. for $user->{user_id}"
        );

        $user->{user_agent}->page_links_ok(
"Estimates Menu - Check ALL links on the Estimates Menu Page for $user->{user_id}"
        );

    }
    return $users;
}

#-------------------------------------------------------------------------------
#  Test Create A Customer
#  Create a new custome 
#  Test This Creation
#-------------------------------------------------------------------------------
sub test_customer_create{
    my ($users) = @_;
    
    #------ Go to Estimates menu Page
    $_->{user_agent}->get_ok( '/customer/create_customer',
        "Create Customer - Got the Create Customer Page for $_->{user_id}" )
      for @$users;




#-------------------------------------------------------------------------------
#  split this to new Script
#-------------------------------------------------------------------------------
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

    #------ Test the HTML on the Already Login Page
    if ( $user->{test_list}->{test_html} ) {
        $user->{user_agent}->html_lint_ok(
            "Login Page When Logged In - HTML on Already Logged In Page");
    }

  #------ Test the 'Logout' link (see also 'text_regex' and 'url_regex' options)

    $user->{user_agent}->follow_link_ok( { url_regex => qr/logout/i },
        "Login Page When Logged In - Follow the logout link $user->{user_id}" );

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

    #    my @links = qw (logout);
    #    $user->{user_agent}->links_ok( \@links,
#    $user->{user_agent}->links_ok( '/logout',
#        "Logout - Link to Logout is good for $user->{user_id}" );

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

