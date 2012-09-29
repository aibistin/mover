package mover;
use Moose;
use namespace::autoclean;
use Catalyst::Runtime 5.80;
use Log::Log4perl::Catalyst;

#use Log::Log4perl qw(:easy);

# Set flags and add plugins for the application.
# Keep ConfigLoader at the head of the plugins.
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory
use Catalyst qw/
  ConfigLoader

  -Debug

  StackTrace

  Static::Simple

  Authentication

  Session
  Session::Store::FastMmap
  Session::State::Cookie

  StatusMessage

  Authorization::Roles

  FormValidator::Simple

  Unicode::Encoding
  AutoCRUD

  Authentication
  Authorization::Roles
  Session
  Session::State::Cookie
  Session::Store::FastMmap

  /;

#         Log::Log4perl
#     Session::Store::Memcached
#      Session::State
#      Session::Store
#  Session::Store::File
#  Session::Store::FastMmap
#  Session::Store::Memcached
#    Catalyst::View::HTML::Template

extends 'Catalyst';
our $VERSION = '0.01';

#------
#-----  Logging
__PACKAGE__->log( Log::Log4perl::Catalyst->new() );

#   Log::Log4perl->easy_init($DEBUG);
#------
# Configure the application.
#
# Note that settings in mover.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.
__PACKAGE__->config(
    name => 'mover',

    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback => 1,
    enable_catalyst_header                      => 1,   # Send X-Catalyst header

    #------- Disable Caching
    #    before 'finalize_headers' => sub {
    #        my $c = shift;
    #        $c->response->headers->header( 'Cache-control' => 'no-cache' );
    #},
);

__PACKAGE__->config(

    # Configure the view
    'View::HTML' => {

        #------ Set the location for TT files
        INCLUDE_PATH => [
            __PACKAGE__->path_to( 'root', 'src' ),
            __PACKAGE__->path_to( 'root', 'src', 'Includes' ),
            __PACKAGE__->path_to( 'root', 'forms', 'miniforms' ),
        ],
    },
    default_view => 'HTML',
);

#-------------------------------------------------------------------------------
#  Added Test Configuration File Locaion And Authentication Database
#  Location For Test Scripts Only
# The Production Location will be in the Application Root Directory
#-------------------------------------------------------------------------------
if ( $ENV{APP_TEST} ) {
    __PACKAGE__->config( 'Plugin::ConfigLoader' =>
          { file => __PACKAGE__->path_to('t/lib/mover_testing.conf') } );
}
__PACKAGE__->config( name => 'mover' );

#----- Set Up Log4perl with configuration file
__PACKAGE__->log(Log::Log4perl::Catalyst->new('log_mover.conf'));

#
#----- Configure SimpleDB Authentication
#----- User Authentication
#
# Configure SimpleDB Authentication
__PACKAGE__->config(
    'Plugin::Authentication' => {

        #------   This is the original simple Authentication from Tutorial
        #        default => {
        #            class           => 'SimpleDB',
        #            user_model      => 'DB::User',
        #            password_type   => 'self_check',
        #        },
        #------   This is the more complex Authentication from Book
        #         Employees is the original Using mover.db User table
        #         Employees is the default,  To Use users,  have to specify
        #         the 'realm' users.
        #
        'default_realm' => 'employees',
        'realms'        => {
            'employees' => {
                credential => {
                    class         => 'Password',
                    password_type => 'self_check',
                },
                store => {
                    class         => 'DBIx::Class',
                    user_model    => 'DB::User',
                    role_relation => 'roles',
                    role_field    => 'role',
                    use_userdata_from_session => '1'    # Data is more stale
                },
            },

            #------ This users is from the Book Catalyst::Helper::AuthDBIC
            #       With an Auth table in db/auth.db
            #       I may use this for testing
            'users' => {
                'store' => {
                    'role_column' => 'role_text',
                    'user_class'  => 'Auth::User',
                    'class'       => 'DBIx::Class',
                },
                'credential' => {
                    'password_type'      => 'hashed',
                    'password_field'     => 'password',
                    'password_hash_type' => 'SHA-1',
                    'class'              => 'HTTP',
                    'type'               => 'basic',
                }
            },
        },
    }
);

#__PACKAGE__->config( authentication => {
#    'default_realm' => 'users',
#    'realms' => {
#        'users' => {
#            'store' => {
#                'role_column' => 'role_text',
#                'user_class' => 'Auth::User',
#                'class' => 'DBIx::Class',
#            },
#            'credential' => {
#                 'password_type' => 'hashed',
#                 'password_field' => 'password',
#                 'password_hash_type' => 'SHA-1',
#                 'class' => 'HTTP',
#                 'type' => 'basic',
#             }
#        }
#    },
#});

#
#------ Start the mover application
#
__PACKAGE__->setup();

=head1 NAME

mover - Catalyst based application

=head1 SYNOPSIS

    script/mover_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<mover::Controller::Root>, L<Catalyst>

=head1 AUTHOR

austin,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
