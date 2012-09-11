use utf8;
package mover::Schema::Result::Department;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

mover::Schema::Result::Department

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

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "PassphraseColumn");

=head1 TABLE: C<department>

=cut

__PACKAGE__->table("department");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'text'
  is_nullable: 1

=head2 description

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
  "name",
  { data_type => "text", is_nullable => 1 },
  "description",
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

=head2 employees

Type: has_many

Related object: L<mover::Schema::Result::Employee>

=cut

__PACKAGE__->has_many(
  "employees",
  "mover::Schema::Result::Employee",
  { "foreign.department" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07017 @ 2012-08-18 12:15:07
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:c7IORHelrIjIBJgsB+lkHw

#-------------------------------------------------------------------------------
#  Workspace Begins
#-------------------------------------------------------------------------------









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
       return $self->name || '';
}











#-------------------------------------------------------------------------------
#  Workspace Ends
#-------------------------------------------------------------------------------

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
