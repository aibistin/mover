use utf8;

package mover::Schema::Result::Customer;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

mover::Schema::Result::Customer

=cut

use strict;
use warnings;
use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::TimeStamp>

=item * L<DBIx::Class::PassphraseColumn>

=back

=cut

__PACKAGE__->load_components( "InflateColumn::DateTime", "TimeStamp",
    "PassphraseColumn" );

=head1 TABLE: C<customer>

=cut

__PACKAGE__->table("customer");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 last_name

  data_type: 'text'
  is_nullable: 1

=head2 first_name

  data_type: 'text'
  is_nullable: 1

=head2 m_i

  data_type: 'text'
  is_nullable: 1

=head2 prefix

  data_type: 'text'
  is_nullable: 1

=head2 suffix

  data_type: 'text'
  is_nullable: 1

=head2 alias

  data_type: 'text'
  is_nullable: 1

=head2 address_1

  data_type: 'text'
  is_nullable: 1

=head2 address_2

  data_type: 'text'
  is_nullable: 1

=head2 city

  data_type: 'text'
  is_nullable: 1

=head2 state

  data_type: 'text'
  is_nullable: 1

=head2 zip

  data_type: 'text'
  is_nullable: 1

=head2 phone_1

  data_type: 'text'
  is_nullable: 1

=head2 phone_2

  data_type: 'text'
  is_nullable: 1

=head2 phone_3

  data_type: 'text'
  is_nullable: 1

=head2 email_1

  data_type: 'text'
  is_nullable: 1

=head2 email_2

  data_type: 'text'
  is_nullable: 1

=head2 recommended_by

  data_type: 'text'
  is_nullable: 1

=head2 repeat

  data_type: 'integer'
  is_nullable: 1

=head2 type

  data_type: 'integer'
  is_nullable: 1

=head2 comments

  data_type: 'text'
  is_nullable: 1

=head2 created

  data_type: 'timestamp'
  is_nullable: 1

=head2 created_by

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 updated

  data_type: 'timestamp'
  is_nullable: 1

=head2 updated_by

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
    "id",
    {
        data_type         => "integer",
        is_auto_increment => 1,
        is_nullable       => 0
    },
    "last_name",
    { data_type => "text", is_nullable => 1 },
    "first_name",
    { data_type => "text", is_nullable => 1 },
    "m_i",
    { data_type => "text", is_nullable => 1 },
    "prefix",
    { data_type => "text", is_nullable => 1 },
    "suffix",
    { data_type => "text", is_nullable => 1 },
    "alias",
    { data_type => "text", is_nullable => 1 },
    "address_1",
    { data_type => "text", is_nullable => 1 },
    "address_2",
    { data_type => "text", is_nullable => 1 },
    "city",
    { data_type => "text", is_nullable => 1 },
    "state",
    { data_type => "text", is_nullable => 1 },
    "zip",
    { data_type => "text", is_nullable => 1 },
    "phone_1",
    { data_type => "text", is_nullable => 1 },
    "phone_2",
    { data_type => "text", is_nullable => 1 },
    "phone_3",
    { data_type => "text", is_nullable => 1 },
    "email_1",
    { data_type => "text", is_nullable => 1 },
    "email_2",
    { data_type => "text", is_nullable => 1 },
    "recommended_by",
    { data_type => "text", is_nullable => 1 },
    "repeat",
    { data_type => "integer", is_nullable => 1 },
    "type",
    { data_type => "integer", is_nullable => 1 },
    "comments",
    { data_type => "text", is_nullable => 1 },
    "created",
    { data_type => "timestamp", is_nullable => 1 },
    "created_by",
    {
        data_type      => "integer",
        is_foreign_key => 1,
        is_nullable    => 1
    },
    "updated",
    { data_type => "timestamp", is_nullable => 1 },
    "updated_by",
    {
        data_type      => "integer",
        is_foreign_key => 1,
        is_nullable    => 1
    },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 created_by

Type: belongs_to

Related object: L<mover::Schema::Result::Employee>

=cut

__PACKAGE__->belongs_to(
    "created_by",
    "mover::Schema::Result::Employee",
    { id => "created_by" },
    {
        is_deferrable => 1,
        join_type     => "LEFT",
        on_delete     => "CASCADE",
        on_update     => "CASCADE",
    },
);

=head2 estimates

Type: has_many

Related object: L<mover::Schema::Result::Estimate>

=cut

__PACKAGE__->has_many(
    "estimates",
    "mover::Schema::Result::Estimate",
    { "foreign.customer_id" => "self.id" },
    { cascade_copy          => 0, cascade_delete => 0 },
);

=head2 updated_by

Type: belongs_to

Related object: L<mover::Schema::Result::Employee>

=cut

__PACKAGE__->belongs_to(
    "updated_by",
    "mover::Schema::Result::Employee",
    { id => "updated_by" },
    {
        is_deferrable => 1,
        join_type     => "LEFT",
        on_delete     => "CASCADE",
        on_update     => "CASCADE",
    },
);

# Created by DBIx::Class::Schema::Loader v0.07017 @ 2012-05-02 22:17:27
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:lSMbWPSyOPVGh55SFd47zQ
# You can replace this text with custom code or comments, and it will be preserved on regeneration
#################################################################################
#####                       WORKSPACE BEGINS                                 ####
#################################################################################
#use Log::Log4perl qw(:easy);
use Regexp::Common qw(time);
use lib '../../Model/Valid';
use MyValid;
use MyDate;

#------- Constant types

#todo Get list of valid time zone strings.
my $LOCAL_TZ   = 'America/New_York';
my $DEFAULT_TZ = 'UTC';

#-------
#
## Enable automatic date handling
##
#
__PACKAGE__->add_columns(
    "created",
    {
        time_zone     => 'local',
        data_type     => 'timestamp',
        set_on_create => 1
    },
    "updated",
    {
        time_zone     => 'local',
        data_type     => 'timestamp',
        set_on_create => 1,
        set_on_update => 1
    },
);
###############################################################
# Create Customer
###############################################################

###############################################################
# List Customer
###############################################################

=head2 customer_list
Return a comma-separated list of customers
=cut

sub customer_list {
    my ($self) = @_;

    # Loop through all estimates. Customer full name
    # Result Class method for each
    my @names;
    foreach my $estimate ( $self->estimate ) {
        push( @names, $estimate->full_name );
    }
    return join( ', ', @names );
}

#-------------------------------------------------------------------------------
#  Create a customer full name from First,  Last,  MI,  Prefix
#  and Suffix.
#-------------------------------------------------------------------------------

=head2 full_name
   Join first name with last name, including prefix and suffix
   Uppercase the first initial
=cut

sub full_name {
    my ($self) = @_;

    my $full_name =
      ( defined $self->prefix )
      ? ucfirst( $self->prefix ) . ' '
      . ucfirst( $self->first_name ) . ' '
      . ucfirst( $self->last_name )
      : ucfirst( $self->first_name ) . ' ' . ucfirst( $self->last_name );
    return (
        defined $self->suffix
        ? $full_name . ' ' . $self->suffix
        : $full_name
    );
}

#-------
#------ Matching Names

=head2 customer last name like
   A predefined search for customer estimates with a 'LIKE' search in the string
=cut

sub last_name_like {
    my ( $self, $name_str ) = @_;
    return $self->search( { last_name => { 'like' => "%$name_str%" } } );
}

#-------------------------------------------------------------------------------
#  Displays more detailed information about this record
#  when using Autocrud
#-------------------------------------------------------------------------------

=head2 display_name
    AUTOCRUD 
    Better displaying of columns that reference other tables with Autocrud
=cut

sub display_name {
    my ($self) = @_;
    return $self->full_name || '';
}

#######################################################################
#------ Date Times
#######################################################################

=head2 created_datetime
   Convert the Customer created date to datetime format
   Stored in UTC time zone. Display in Local Time Zone
=cut

sub created_datetime {
    my ($self) = @_;
    return undef if ( not defined $self->created );

    return ( MyDate->format_date_time_tz( $self->created, $DEFAULT_TZ ) )
      ->set_time_zone($LOCAL_TZ);
    undef;
}

=head2 updated_datetime
   Convert the Customer Updated date to datetime format
   Stored in UTC time zone. Display in Local Time Zone
=cut

sub updated_datetime {
    my ($self) = @_;
    return undef if ( not defined $self->updated );

    return ( MyDate->format_date_time_tz( $self->updated, $DEFAULT_TZ ) )
      ->set_time_zone($LOCAL_TZ);
    undef;
}

#-------------------------------------------------------------------------------
#  Permissions
#-------------------------------------------------------------------------------

=head2 create_allowed_by
    Can the specified user create customers
=cut

sub create_allowed_by {
    my ( $self, $user ) = @_;

    #    return ($user->has_role('admin');
    return ( $user->has_role('can_create_customer') );

    #    return undef;
}

=head2 delete_allowed_by
    Can the specified user delete the current customer
=cut

sub delete_allowed_by {
    my ( $self, $user ) = @_;

    #    return ($user->has_role('admin');
    return ( $user->has_role('can_delete_customer') );

    #    return undef;
}

=head2 update_allowed_by
    Can the specified user edit the current customer
=cut

sub update_allowed_by {
    my ( $self, $user ) = @_;

    return ( $user->has_role('can_update_customer') );

    #    return $user->has_role('admin');
    #    return undef;
}

=head2 display_allowed_by
    Can the specified list the customers
=cut

sub display_allowed_by {
    my ( $self, $user ) = @_;

    return ( $user->has_role('can_view_customer') );

    #    return $user->has_role('admin');
    #    return undef;
}

#################################################################################
#####                       WORKSPACE ENDS                                   ####
#################################################################################
__PACKAGE__->meta->make_immutable;
1;
