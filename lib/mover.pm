package mover;
use Moose;
use namespace::autoclean;
use Catalyst::Runtime 5.80;
use Log::Log4perl::Catalyst;

#use Log::Log4perl qw(:easy);

# Set flags and add plugins for the application.
#
# Note that ORDERING IS IMPORTANT here as plugins are initialized in order,
# therefore you almost certainly want to keep ConfigLoader at the head of the
# list if you're using it.
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

        #Set the location for TT files
        INCLUDE_PATH => [
            __PACKAGE__->path_to( 'root', 'src' ),
            __PACKAGE__->path_to( 'root', 'forms', 'miniforms' ),
        ],
    },
    default_view => 'HTML',
);
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
        default => {
            credential => {
                class         => 'Password',
#                password_type => 'crypted'
                #Catalyst::Plugin::Authentication::Store::DBIC to call the
                #check_password (User.pm passphrase_check_method)
                password_type   => 'self_check',
            },
            store => {
                class      => 'DBIx::Class',
                user_model => 'DB::User',

                #                user_model                => 'Mover::User',
                role_relation             => 'roles',
                role_field                => 'role',
                use_userdata_from_session => '1'        # Data is more stale
            },
        },
    },
);

#
#------ Start the application
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
