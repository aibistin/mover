use utf8;

package mover::Schema::Result::Estimator;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

mover::Schema::Result::Estimator

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

=head1 TABLE: C<estimator>

=cut

__PACKAGE__->table("estimator");

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

=head2 created

  data_type: 'timestamp'
  is_nullable: 1

=head2 updated

  data_type: 'timestamp'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
    "id",
    { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
    "last_name",
    { data_type => "text", is_nullable => 1 },
    "first_name",
    { data_type => "text", is_nullable => 1 },
    "created",
    { data_type => "timestamp", is_nullable => 1 },
    "updated",
    { data_type => "timestamp", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 estimate_estimators

Type: has_many

Related object: L<mover::Schema::Result::EstimateEstimator>

=cut

__PACKAGE__->has_many(
    "estimate_estimators",
    "mover::Schema::Result::EstimateEstimator",
    { "foreign.estimator_id" => "self.id" },
    { cascade_copy           => 0, cascade_delete => 0 },
);

# Created by DBIx::Class::Schema::Loader v0.07017 @ 2012-03-07 22:14:49
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:eao+4VduQ/USEUdkRB5VTA
# You can replace this text with custom code or comments, and it will be preserved on regeneration

#################################################################################
#####                       WORKSPACE BEGINS                                 ####
#################################################################################
#
## Enable automatic date handling
##
#
__PACKAGE__->add_columns(
    "created", { data_type => 'timestamp', set_on_create => 1 },
    "updated",
    { data_type => 'timestamp', set_on_create => 1, set_on_update => 1 },
);

#
# Full Estimator name
#

=head2 full_name
   Gets the estimators full namer,  complete with
   Prefix,   First,  MI, Last,  Suffix
=cut

sub full_name {
    my ($self) = @_;

    #    return
    my $full_name =
      ( defined $self->prefix )
      ? $self->prefix . ' ' . $self->first_name . ' ' . $self->last_name
      : $self->first_name . ' ' . $self->last_name;
    return (
        defined $self->suffix
        ? $full_name . ' ' . $self->suffix
        : $full_name
    );
}

#
# Full Estimator name with Init Caps
#

=head2 full_name_initcaps
   Gets the estimators full namer,  complete with
   Prefix,   First,  MI, Last,  Suffix
   Added Initcaps for completeness
=cut

sub full_name_initcaps {
    my ($self) = @_;

    #    return
    my $full_name =
      ( defined $self->prefix )
      ? ucfirst $self->prefix . ' '
      . ucfirst $self->first_name . ' '
      . ucfirst $self->last_name
      : ucfirst $self->first_name . ' ' . ucfirst $self->last_name;
    return (
        defined $self->suffix
        ? $full_name . ' ' . ucfirst $self->suffix
        : $full_name
    );
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

#################################################################################
#####                       WORKSPACE ENDS                                   ####
#################################################################################

#------
__PACKAGE__->meta->make_immutable;
###################################################################
1;
