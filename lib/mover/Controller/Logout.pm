package mover::Controller::Logout;
use Moose;
use namespace::autoclean;
BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

mover::Controller::Logout - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

=cut

#sub index :Path :Args(0) {
#    my ( $self, $c ) = @_;
#
#    $c->response->body('Matched mover::Controller::Logout in Logout.');
#}

=head2 index
Logout logic
=cut
sub index : Path : Args(0) {
    my ($self, $c) = @_;

    # Clear the user's state
    $c->logout;

    # Send the user to the starting point
    $c->response->redirect($c->uri_for('/'));
}

=d2 list
 If the user exists or not
=cut

#sub user_status_actions : Private {
#    my ($self, $c) = @_;
#    if (!$c->user_exists) {
#        $c->stash(template => 'login.tmpl');
#        $c->stash->{LOG_STATUS_MESSAGE} = "You are already signed in as: ";
#        $c->stash->{USER_NAME}          = $c->request->params->{username};
#        $c->stash->{LOG_ACTION_MESSAGE} = "You can logout here: ";
#        $c->stash->{RETURN_URL}         = $c->uri_for('/logout');
#    }
#    else {
#
#        # If not logged in then send them to login
#        $c->stash(template => 'login.tmpl');
#        $c->stash->{LOG_STATUS_MESSAGE} = "You are not signed in: ";
#        $c->stash->{LOG_ACTION_MESSAGE} = "You can logon here: ";
#        $c->stash->{RETURN_URL}         = $c->uri_for('/login');
#    }
#}

=head1 AUTHOR

austin,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
__PACKAGE__->meta->make_immutable;
1;
