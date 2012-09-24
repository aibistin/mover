#!/usr/bin/env perl
# IMPORTANT: if you delete this file your app will not work as
# expected.  You have been warned.
use inc::Module::Install 1.02;
use Module::Install::Catalyst;    # Complain loudly if you don't have
                                  # Catalyst::Devel installed or haven't said
                                  # 'make dist' to create a standalone tarball.

name 'mover';
all_from 'lib/mover.pm';
requires 'Moose';
requires 'Catalyst::Runtime' => '5.90010';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Action::RenderView';
requires 'Catalyst::Plugin::StackTrace';

#------ Ones I added
#------ Plugins
requires 'Catalyst::Plugin::Session::State';
requires 'Catalyst::Plugin::Session::Store';
requires 'Catalyst::Plugin::Authentication';
requires 'Catalyst::Authentication::Store::DBIx::Class';
requires 'Catalyst::Plugin::Session::Store::FastMmap';
requires 'Catalyst::Plugin::Session::Store::File';         #good on windows
requires 'Catalyst::Plugin::Session::Store::Memcached';    #good on unix systems
requires 'Catalyst::Plugin::Session::State::Cookie';
requires 'Catalyst::Plugin::StatusMessage';
requires 'Catalyst::Plugin::Authorization::Roles';
requires 'Catalyst::Plugin::Unicode::Encoding';
requires 'Catalyst::Plugin::AutoCRUD';
requires 'Catalyst::Plugin::FormValidator::Simple';

#------ Ones I added
requires 'Catalyst::Plugin::Session';
requires 'Catalyst::Log::Log4perl';
requires 'Perl6::Junction';
requires 'HTML::FormFu';

#requires 'Catalyst::Controller::HTML::FormFu';
#requires 'Catalyst::Controller::HTML::FormFu::ExtJS';
requires 'HTML::FormFu::Model::DBIC';
requires 'HTML::FormFu::Constraint';
#
requires 'Catalyst::View::HTML::Template';
requires 'Catalyst::View::Component::jQuery';
#
requires 'HTML::FormFu::Filter::NonNumeric';

#------ And Ones I added
requires 'namespace::autoclean';
requires
  'Config::General';  # This should reflect the config file format you've chosen

#------- See Catalyst::Plugin::ConfigLoader for supported formats
test_requires 'Test::More' => '0.88';
catalyst;

requires 'Catalyst::Plugin::Authentication';
requires 'Catalyst::Plugin::Authorization::Roles';
requires 'Catalyst::Plugin::Session';
requires 'Catalyst::Plugin::Session::State::Cookie';
requires 'Catalyst::Plugin::Session::Store::FastMmap';
requires 'Catalyst::Authentication::Store::DBIx::Class';
requires 'Catalyst::Authentication::Credential::HTTP';
requires 'DBIx::Class::EncodedColumn';

install_script glob('script/*.pl');
auto_install;
WriteAll;
