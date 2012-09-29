package mover::Controller::Intro;
use Moose;
use namespace::autoclean;

# My additions
#use Log::Log4perl qw(:easy);

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME
 
mover::Controller::Intro - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

=cut

#
#sub index : Path : Args(0) {
#    my ( $self, $c ) = @_;
#
#    $c->log->debug( "Got to introduction index page.";
#    $c->stash( template => 'Intro/intro.tt2' );
#
#    #    $c->response->body('Matched mover::Controller::Intro in Intro.');
#}
#

=head2  intro_banner_page
 
Introduction to this application. Users can log in from here. 
Non Users can see what it is all about.
 
=cut

#sub intro_banner_page : Path('intro_banner_page') {
sub index : Path : Args(0) {
    my ( $self, $c ) = @_;
    $c->log->debug("Got to introduction banner page.");
    $c->stash->{app_page} = 'intro';
    $c->stash( template => 'Intro/intro.tt2' );
}

=head1 AUTHOR

austin,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
