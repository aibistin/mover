package mover::Controller::Menu;
use Moose;

#use Log::Log4perl qw(:easy);
use namespace::autoclean;
BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

mover::Controller::Menu - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

=cut

sub index : Path : Args(0) {
    my ( $self, $c ) = @_;
    $c->log->debug( '*** We got to Menu from  ' . $c->request->path );

    #------ Page Heading
    $c->stash(
        h2_main_heading  => "Main Menu",
        main_sub_heading => "Everything Starts From Here...",
    );

    #    $c->response->body('Matched mover::Controller::Menu in Menu.');
    $c->stash->{template} = 'Menu/menu.tt2';
}

#------ Chained Estimates Menu

=head2 estimates_menu
    Sets Up The Estimates Menu
=cut

sub estimates_menu : Path('estimates_menu') {
    my ( $self, $c ) = @_;

    #------ Page Heading
    $c->stash(
        h2_main_heading  => "Estimates Department",
        main_sub_heading => "Schedule, Modify And View Estimates",
    );

    $c->log->debug('*** INSIDE menu estimates_menu METHOD');
    $c->stash->{template} = 'Estimates/estimate_menu.tt2';
}

=head1 AUTHOR

austin,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;
1;
