package mover::Controller::Root;
use Moose;
use namespace::autoclean;

#use Log::Log4perl qw(:easy);
use Data::Dumper;

BEGIN { extends 'Catalyst::Controller' }

#-------------------------------------------------------------------------------
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in mover.pm
#-------------------------------------------------------------------------------

__PACKAGE__->config( namespace => '' );

=head1 NAME

mover::Controller::Root - Root Controller for mover

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 index

The root page (/)

=cut

#-------------------------------------------------------------------------------
# Index
# Index will go directly to the Main Menu
#-------------------------------------------------------------------------------

=head2 index
    Will redirect to the Main Menu
=cut

sub index : Path : Args(0) {
    my ( $self, $c ) = @_;

    # Static Page (Catalyst Home Page)
    #    $c->response->body( $c->welcome_message );
    $c->response->redirect( $c->uri_for('menu') );
    return 0;
}

#-------------------------------------------------------------------------------

=head2 auto
    Check if there is a user and, if not, forward to login page
    Note that 'auto' runs after 'begin' but before your actions and that
    'auto's "chain" (all from application path to most specific class are run)
    See the 'Actions' section of 'Catalyst::Manual::Intro' for more info.
=cut

#-------------------------------------------------------------------------------
sub auto : Private {
    my ( $self, $c ) = @_;

    # Allow unauthenticated users to reach the login page.  This
    # allows unauthenticated users to reach any action in the Login
    # controller.  To lock it down to a single action, we could use:
    #   if ($c->action eq $c->controller('Login')->action_for('index'))
    # to only allow unauthenticated access to the 'index' action we
    # added above.
    if ( $c->controller eq $c->controller('login') ) {
        return 1;
    }

    # Intro will redirect to login after if needeed
    if ( $c->controller eq $c->controller('intro') ) {
        return 1;
    }

    # If a user doesn't exist, force login
    if ( !$c->user_exists ) {

  # Dump a log message to the development server debug output
  #        $c->log->debug('***Root::auto User not found, forwarding to /login');
        $c->log->debug( '*** Inside Root. No user logged in. Called from: '
              . $c->request->path );

        # $c->response->redirect($c->uri_for('/login'));
        $c->response->redirect( $c->uri_for('/intro') );

      # Return 0 to cancel 'post-auto' processing and prevent use of application
        return 0;
    }

    # User found, so return 1 to continue with processing after this 'auto'
    return 1;
}

=head2 default
Standard 404 error page
=cut

sub default : Path {
    my ( $self, $c ) = @_;
   #
   #        $c->response->body(
   #            '<h3>What are you doing here? Did you take a wrong turn?</h3>');
   #        $c->response->status(404);
   #
    $c->log->debug("*** Got to default Action in Root.pm");
    $c->stash(
        template  => 'error.tt2',
        error_404 => 'Looks like you took a wrong turn. Try using a map.',
    );
}

#
##
### ------ Form Validation
##
#

#
##
##------ Error messages
##
#

=head2 error_noperms
   Permissions error screen
=cut

sub error_noperms : Chained('/') : PathPart('error_noperms') : Args(0) {
    my ( $self, $c ) = @_;

    $c->log->debug("*** Got to error_noperms Action in Root.pm");
    $c->stash(
        template => 'error.tt2',
        error_noperms =>
          'You are not allowed to do this. Seek higher authority',
    );
}

=head2 error_404
   Generic Not Found Error
=cut

sub error_404 : Chained('/') : PathPart('error_404') : Args(0) {
    my ( $self, $c ) = @_;

    $c->log->debug("*** Got to error_404 Action in Root.pm");
    $c->stash(
        template  => 'error.tt2',
        error_404 => 'Looks like you took a wrong turn. Try using a map.',
    );
}

=head2 error_other
   Generic Error
=cut

sub error_other : Chained('/') : PathPart('error_other') : Args(0) {
    my ( $self, $c ) = @_;

    $c->log->debug("*** Got to error_other Action in Root.pm");
    $c->stash(
        template => 'error.tt2',
        error_other =>
'Let me know about this error.<br /> Send the link to aibistin.cionnaith@gmail.com. Thanks. ',
    );
}

=head2 end
Attempt to render a view, if needed.
Will also handle errors. 
=cut

#sub end : ActionClass('RenderView') {};
sub end : ActionClass('RenderView') {
    my ( $self, $c ) = @_;
    my ( $error_count, $error_messages_string );
    $error_count = scalar @{ $c->error };

    #----- If it is an unhandled Error
    if ( $error_count && ( not defined $c->stash->{template} ) ) {

        $c->log->warn(
            "*** Got to error area in the end Action in Root.pm due
            to $error_count errors."
        );
        foreach my $err_msg ( @{ $c->error } ) {
            $error_messages_string .= $err_msg . "\n";
        }

        $c->log->error(
            "End action has no template defined. Will use errot.tt2
            instead."
        );
        $c->log->error(
            "Unhandled Error Is $error_messages_string. Will use errot.tt2
            instead."
        );
        $c->res->status(500);

        #------ Clear these old messages
        $c->clear_errors;
        $c->stash(
            template               => 'error.tt2',
            internal_error_message => $error_messages_string,
            error_other =>
'Let me know about this error.<br /> Send the link to aibistin.cionnaith@gmail.com. Thanks. ',
        );
    }
}

#------ Send the template
#sub end : Private {
#    my ( $self, $c ) = @_;
##   ($c->stash->{template}) ||= 'Estimates/estimates.tmpl';
#    ($c->stash->{template}) ||= undef;
#    $c->forward( $c->view('HTML::Template') )
#     if ( defined $c->stash->{template});
#}

=head1 AUTHOR

austin,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
