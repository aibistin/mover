package mover::Schema::ResultSet::Customer;
use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

#-------------------------------------------------------------------------------
#  Lots of Pre Defined Searches to obtain Customer data based on specific
#  criteria.
#-------------------------------------------------------------------------------

=head2 created_after
     A predefined search for customers created after a specific date.
=cut

sub created_after {
    my ( $self, $datetime ) = @_;
    my $date_str =
      $self->result_source->schema->storage->datetime_parser->format_datetime(
        $datetime);

    return ( $self->search( { created => { '>' => $date_str } } ) );
}

=head2 updated_after
     A predefined search for Customers updated after a specific date
=cut

sub updated_after {
    my ( $self, $datetime ) = @_;
    my $date_str =
      $self->result_source->schema->storage->datetime_parser->format_datetime(
        $datetime);

    return ( $self->search( { updated => { '>' => $date_str } } ) );
}

=head2 created_on
     A predefined search for customers created on a particular day
=cut

sub created_on {
    my ( $self, $date ) = @_;
    my $date_str =
      $self->result_source->schema->storage->datetime_parser->format_datetime(
        $date);

    return ( $self->search( { created => { '=' => $date_str } } ) );
}

=head2 between_dates
     A predefined search for customers created on or
      between specified dates
=cut

sub between_dates {
    my ( $self, $date_obj_1, $date_obj_2 ) = @_;

    my $dtf        = $self->result_source->schema->storage->datetime_parser;
    my $date_str_1 = $dtf->format_datetime($date_obj_1);
    my $date_str_2 = $dtf->format_datetime($date_obj_2);
    return $self->search(
        { create_date => { -between => [ $date_str_1, $date_str_2, ], } },
    );

}

#-------------------------------------------------------------------------------
#  Customers Matching Names
#-------------------------------------------------------------------------------

=head2 customer last name like
   A predefined search for customer estimates with a 'LIKE' search in the string
=cut

sub last_name_like {
    my ( $self, $name_str ) = @_;

    return $self->search(
        { last_name => { 'like' => "%$name_str%" } },

    );
}

#-------------------------------------------------------------------------------
# Permissions
#-------------------------------------------------------------------------------

=head2 viewing_permission
    Can the user see Customer Info For 
    The Entire Resulset
=cut

sub viewing_permission {
    my ( $self, $user ) = @_;
    return $user->has_role('can_view_estimate');
}


#######################################################################
1;
