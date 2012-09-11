package mover::Controller::Login;
use Moose;
use namespace::autoclean;
use Data::Dumper;
use Log::Log4perl qw(:easy);

#------
use lib '/home/austin/perl/Validation';
use MyValid;
use MyDate;

# Use this along with DBIC to check for uniqueness
#use FormValidator::Simple qw/DBIC::Unique/;
#------
BEGIN { extends 'Catalyst::Controller'; }

#------
my $YES = my $TRUE  = 1;
my $NO  = my $FALSE = 0;
my $SUBMIT_BUTTON_VALUE = 'Sign In';
my $MAX_LOGIN_ATTEMPT   = 3;

=head1 NAME

mover::Controller::Login - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index
    Login logic
=cut

sub index : Path : Args(0) {
    my ( $self, $c ) = @_;

    $c->log->debug('*** INSIDE login index METHOD ***');

    my ( $username, $password );

    $self->set_login_form_validation($c);

    #my $SUBMIT_BUTTON_VALUE = 'Sign In';
    # Get the username and password from form
    #    my $username = $c->request->params->{username};
    #    my $password = $c->request->params->{password};

    #------ If Form Submitted
    if (   ( defined $c->request->params->{submit} )
        && ( $c->request->params->{submit} =~ /In/i ) )
    {

        $c->stash->{login_attempt_count} += 1;

        if ( $c->stash->{login_attempt_count} > $MAX_LOGIN_ATTEMPT ) {

            DEBUG 'Too many login attempts : '
              . $c->stash->{login_attempt_count};
            $c->stash->{login_attempt_count} = 0;
            $c->stash( error_msg => 'Too many attempts. You are fired! ' );
            $c->response->redirect( $c->uri_for('/intro') );
            $c->detach;
            return;
        }

        #------ Print debug info if invalid form
        $self->print_invalid_form_info($c) if ( $c->form->has_error );

        $username = $c->form->valid('username');

        $password = $c->form->valid('password');

        DEBUG '*** Validated Username is : '
          . ( $username or 'No valid username' );
        DEBUG '*** Validated Password is : '
          . ( $password or 'No valid password' );

        #------  Attempt to log the user in
        if (
               $username
            && $password
            && (
                $c->authenticate(
                    {
                        username => $username,
                        password => $password
                    }
                )
            )
          )
        {

            DEBUG "We are in. Successful login.";
            $c->stash->{login_attempt_count} = 0;

            # Then let them use the application
            $c->response->redirect(
                $c->uri_for( $c->controller('Menu')->action_for('index') ) );

            $c->detach();
            return;
        }
        else {
            DEBUG 'Invalid Username : ' . ( $username or 'No username' );
            DEBUG 'Invalid Password : ' . ( $password or 'No password' );
            $c->stash( error_msg => "Bad username or password." );
        }

    }    # End Is form submitted
    $c->stash( template => 'Login/login.tt2' );
}

#-------------------------------------------------------------------------------
#  Set Form Validation Parameters
#  Returns nothing
#-------------------------------------------------------------------------------

=d2 set_login_form_validation
   Initialize the form validation parameters
   Returns nothing
=cut

sub set_login_form_validation {
    my ( $self, $c ) = @_;

    #------ FormValidator checks
    $c->form(
        username => [ qw/NOT_BLANK NOT_SP ASCII/, [ 'LENGTH', 5, 20 ], ],
        password => [
            qw/NOT_BLANK NOT_SP ASCII/,
            [ 'LENGTH', 8, 20 ],
            [ 'REGEX',  qr/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$/ ],
        ]
    );

    #            [ 'REGEX',   qr/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$/ ],
    return $c->form->valid('password');
}

#-------------------------------------------------------------------------------
#  Form Error Debug Messages
#-------------------------------------------------------------------------------

=d2 print_invalid_form_info
 Print invalid Form Debug Information
=cut

sub print_invalid_form_info {
    my ( $self, $c ) = @_;

    my $username = $c->form->valid('username');
    my $password = $c->form->valid('password');

    #------ Print Invalid Info To Debugger
    if ( $c->form->has_error ) {
        DEBUG "*** Bad Login Username ... " if ( not $username );
        DEBUG "*** Bad Login password ... " if ( not $password );

        foreach my $key ( @{ $c->form->error() } ) {
            foreach my $type ( @{ $c->form->error($key) } ) {
                DEBUG "Error invalid: $key - $type \n";
            }
        }
        my $missings = $c->form->missing;
        foreach my $missing_data (@$missings) {
            DEBUG "Missing $missing_data;";
        }
        my $invalids = $c->form->invalid;
        foreach my $invalid_data (@$invalids) {
            DEBUG "Invalid $invalid_data;";
        }
    }

}

=head1 AUTHOR

austin,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;
1;
