package mover::Controller::Customer;
use Moose;
use namespace::autoclean;

#------ Additional
use Data::Dumper;
use base 'DBIx::Class::ResultSet';
use Log::Log4perl qw(:easy);
use lib '/home/austin/perl/Validation';
use MyValid;

#use lib '/home/austin/perl/MyDate';
use MyDate;

#BEGIN {extends 'Catalyst::Controller'; }
BEGIN { extends 'Catalyst::Controller::HTML::FormFu'; }

#------
my $YES = my $TRUE  = 1;
my $NO  = my $FALSE = 0;
my $HOST                  = 'http://localhost:3000';
my $CUSTOMER_PATH         = 'Customer/';
my $CREATE_CUSTOMER       = 'create_customer';
my $CREATE_CUSTOMER_LABEL = 'Schedule A New Customer';
my $UPDATE_CUSTOMER       = 'update_customer';
my $DELETE_CUSTOMER       = 'delete_customer';
my $DISPLAY_CUSTOMER      = 'display_customer';          # 'display_customer';
my $MAX_DAYS              = 366;
my $MAX_WEEKS             = 52;
my $MAX_MONTHS            = 12;
my $LAST_NAME_MAX_LENGTH  = 40;
my $FIRST_NAME_MAX_LENGTH = 40;
my $NAME_MAX_LENGTH     = $LAST_NAME_MAX_LENGTH + $FIRST_NAME_MAX_LENGTH;
my $MAX_NUM_OF_NAMES    = 10;
my $MIN_WEEKS           = -52;
my $FIRST_DAY_OF_WEEK   = 1;
my $LAST_DAY_OF_WEEK    = 7;
my $MAX_CUSTOMERS       = 10000;
my $PHONE_NO_MAX_LENGTH = 20;
my $ERROR_MESSAGE       = undef;
my $i                   = 1;
my %DAYS =
  map { ( $i++ => $_ ) }
  qw/monday tuesday wednesday thursday friday saturday sunday/;
$i = 1;
my %MONTHS =
  map { ( $i++ => $_ ) }
  qw/janurary feburary march april may june july august september october november december/;

#------ Java Script Locations
my $CUSTOMER_FORM_VALIDATION_JS =
  "static/jquery/js/jquery_customer_form_valid.js";
my $PHONE_FORM_VALIDATION_JS =
  "static/jquery/js/jquery_customer_phone_valid.js";
my $FIRST_NAME_FORM_VALIDATION_JS =
  "static/jquery/js/jquery_first_name_form_valid.js";
my $LAST_NAME_FORM_VALIDATION_JS =
  "static/jquery/js/jquery_last_name_form_valid.js";
my $FULL_NAME_FORM_VALIDATION_JS =
  "static/jquery/js/jquery_full_name_form_valid.js";
my $ID_FORM_VALIDATION_JS = "static/jquery/js/jquery_customer_id_form_valid.js";
my $DATE_VALIDATION_JS    = "static/jquery/js/jquery_date_valid.js";

#------
my $DATE_PICKER_JS         = "static/jquery/js/datepicker_ui_function.js";
my $CITY_STATE_ZIP_JS      = "static/jquery/js/local_cities.js";
my $CITY_STATE_ZIP_COPY_JS = "static/jquery/js/jquery_state_zip_copy.js";
my $EMPLOYEE_NAME_ID_JS = "static/jquery/js/jquery_employee_name_id_auto_c.js";

=head1 NAME

mover::Controller::Customer - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

=cut

sub index : Path : Args(0) {
    my ( $self, $c ) = @_;
    $c->response->body(
'Matched mover::Controller::Customer in Customer.. Try a different location.'
    );
}

#------ Chained For Customer

=head2 base
    Can place common logic to start chained dispatch here for customer
=cut

sub base : Chained('/') : PathPart('customer') : CaptureArgs(0) {
    my ( $self, $c ) = @_;

    # Store the ResultSet in stash so it's available for other methods
    $c->stash(

        resultset => $c->model('DB::Customer')
    );
    DEBUG '*** INSIDE BASE customer METHOD : Got first Customer resultset ***';

    # Load status messages
    $c->load_status_msgs;
}

=head2 object
    Fetch the customer object based on its id and store it
    it in the stash
=cut

sub object : Chained('base') : PathPart('id') : CaptureArgs(1) {
    my ( $self, $c, $customer_id ) = @_;
    DEBUG '*** Just INSIDE BASE Customer object METHOD ***';
    DEBUG "*** The object id is: $customer_id ***";

    #------ Find the customer object and store it in the stash
    $c->stash->{object} = $c->stash->{resultset}->find($customer_id);
    $c->detach('/error_404') if !$c->stash->{object};

    #    DEBUG('*** Customer Customer Object =  ***' . $c->stash->{object});
}

#
##
####------ List Customer  Created by a particular employee
##
#

=head2 
    List customers created by employee
=cut

sub list_created_by_employee : Chained('base') :
  PathPart('list_created_by_employee') : Args(1) {
    my ( $self, $c, $employee_id ) = @_;
    DEBUG "*** INSIDE list_by_employee_id. Employee id is: $employee_id";

    # Ensure user has permission to see this resultset
    $c->detach('/error_noperms')
      unless $c->stash->{resultset}->viewing_permission( $c->user->get_object );

    #----- Get the customers created by this employee
    $c->stash->{resultset} =
      $c->stash->{resultset}->search( { 'created_by' => $employee_id }, );
    $c->stash->{template} = 'Customer/list.tt2';
}

#
##
####------ List By Customer Last Name
##
#

=head2 list_by_last_name
    List customers
    That have a customer last name like the entered name
=cut

sub list_by_last_name : Chained('base') : PathPart('list_by_last_name') :
  Args(0) {
    my ( $self, $c ) = @_;
    my $l_name = $c->request->params->{last_name} || undef;
    my $valid = MyValid->new();
    DEBUG "*** INSIDE Customer list_by_last_name. Last name is: $l_name";

    # Ensure user has permission to see this resultset
    $c->detach('/error_noperms')
      unless $c->stash->{resultset}->viewing_permission( $c->user->get_object );

    #----- Get the customers
    if ( defined $l_name ) {
        if (   $valid->is_length_ok( $l_name, $LAST_NAME_MAX_LENGTH )
            && $valid->is_it_a_name($l_name) )
        {
            DEBUG
              "*** INSIDE Customer list_by_last_name. Last name is: $l_name";
            $c->stash->{resultset} =
              $c->stash->{resultset}
              ->search( { last_name => { 'like' => "%$l_name%" } } );
            $c->stash->{sub_heading} = "Customers with last names like $l_name";
            $c->stash->{customer_count} = $c->stash->{resultset}->count // 0;
            $c->stash->{found_msg}      = $c->stash->{customer_count}
              . " customers found with last names like $l_name";
        }
        else {

            #------  Bad data Set an error message
            $ERROR = $TRUE;
            $c->stash( last_name => $l_name );
            $c->stash( error_msg => $ERROR_MESSAGE );
            DEBUG '*** Customer last name ' . $ERROR_MESSAGE;
            $c->stash->{resultset}      = undef;
            $c->stash->{customer_count} = 0;
            $c->stash->{found_msg} =
"Enter a valid last name no longer than $LAST_NAME_MAX_LENGTH characters "
              . "<br /> $l_name is an invalid name.";
        }
    }
    else {

        #------ First time through. No name selected yet
        $c->stash->{sub_heading}    = "Find Customers by last name.";
        $c->stash->{resultset}      = undef;
        $c->stash->{customer_count} = 0;
        $c->stash->{found_msg} =
          'Enter the last name of the customer you are looking for.';
    }
    my $action = $c->uri_for('/customer/list_by_last_name');

    #------ Add Last Name Form Here
    my $last_name_form = <<END;
	<form class="form-inline" method="post"  action="$action" id="last_name">
		<div class="control-group">
			<div class="controls">
				<input type="text" class="input-mini" placeholder="Lastname" 
			   label="Last Name" title="Enter the last name of the customer"
		 	     id="last_name" name="last_name" %]>
		 	     <button type="submit" name="submit"  class="btn btn-info btn-mini">Find Customer</button>
	 		</div>
		 	 
		  </div>
	</form>
END

    #------ Add js to bottom template  (Form Validation to JS array)
    $c->stash(
        bottom_js => 'js/bottom_js.tt2',
        js_array  => [ $self->last_name_form_valid_js($c), ],
    );

    # <p class="help-inline">Enter the customers last name</p>
    $c->stash->{top_form} = $last_name_form;
    $c->stash->{template} = 'Customer/customer_list.tt2';
}

#
##
####------ List Customer First Name
##
#

=head2 list_by_first_name
    List customers
    That have a customer first name like the entered name
=cut

sub list_by_first_name : Chained('base') : PathPart('list_by_first_name') :
  Args(0) {
    my ( $self, $c ) = @_;
    my $f_name = $c->request->params->{first_name} || undef;
    my $valid = MyValid->new();
    DEBUG "*** INSIDE Customer list_by_first_name. First name is: $f_name";

    # Ensure user has permission to see this resultset
    $c->detach('/error_noperms')
      unless $c->stash->{resultset}->viewing_permission( $c->user->get_object );

    #----- Get the customers
    if ( defined $f_name ) {
        if (   $valid->is_length_ok( $f_name, $FIRST_NAME_MAX_LENGTH )
            && $valid->is_it_a_name($f_name) )
        {
            DEBUG
              "*** INSIDE Customer list_by_first_name. First name is: $f_name";
            $c->stash->{resultset} =
              $c->stash->{resultset}
              ->search( { first_name => { 'like' => "%$f_name%" } } );
            $c->stash->{sub_heading} =
              "Customers with first names like $f_name";
            $c->stash->{customer_count} = $c->stash->{resultset}->count // 0;
            $c->stash->{found_msg} = $c->stash->{customer_count}
              . " customers found with first names like $f_name";
        }
        else {

            #------  Bad data Set an error message
            $ERROR = $TRUE;
            $c->stash( first_name => $f_name );
            $c->stash( error_msg  => $ERROR_MESSAGE );
            DEBUG '*** Customer first name ' . $ERROR_MESSAGE;
            $c->stash->{resultset}      = undef;
            $c->stash->{customer_count} = 0;
            $c->stash->{found_msg} =
"Enter a valid first name no longer than $FIRST_NAME_MAX_LENGTH characters "
              . "<br /> $f_name is an invalid name.";
        }
    }
    else {

        #------ First time through. No name selected yet
        $c->stash->{sub_heading}    = "Find Customers by first name.";
        $c->stash->{resultset}      = undef;
        $c->stash->{customer_count} = 0;
        $c->stash->{found_msg} =
          'Enter the first name of the customer you are looking for.';
    }
    my $action = $c->uri_for('/customer/list_by_first_name');

    #------ Add First Name Form Here
    my $first_name_form = <<END;
    <form class="form-inline" method="post"  action="$action" id="first_name">
        <div class="control-group">
            <div class="controls">
                <input type="text" class="input-mini" placeholder="Firstname" 
               label="First Name" title="Enter the first name of the customer"
                 id="first_name" name="first_name" %]>
                 <button type="submit" name="submit"  class="btn btn-info btn-mini">Find Customer</button>
            </div>
             
          </div>
    </form>
END

    #------ Add js to bottom template  (Form Validation to JS array)
    $c->stash(
        bottom_js => 'js/bottom_js.tt2',
        js_array  => [ $self->first_name_form_valid_js($c), ],
    );
    $c->stash->{top_form} = $first_name_form;
    $c->stash->{template} = 'Customer/customer_list.tt2';
}

#
##
####------ List Customer Customer Id
##
#

=head2 list_by_customer_id
    Find a customer by the customer id
=cut

sub list_by_customer_id : Chained('base') : PathPart('list_by_customer_id') :
  Args(0) {
    my ( $self, $c ) = @_;
    my ($form_action);
    my $customer_id = $c->request->params->{customer_id} || undef;
    my $valid = MyValid->new();
    DEBUG
      "*** INSIDE Customer list_by_customer_id. Customer id is: $customer_id";

    # Ensure user has permission to see this resultset
    $c->detach('/error_noperms')
      unless $c->stash->{resultset}->viewing_permission( $c->user->get_object );

    #----- Get the customers
    if ( defined $customer_id ) {
        if (   $valid->is_it_numeric($customer_id)
            && $valid->is_it_between( $customer_id, 1, $MAX_CUSTOMERS ) )
        {
            DEBUG
              "*** INSIDE Customer list_by_customer_id. Id is: $customer_id";
            $c->stash->{resultset} =
              $c->stash->{resultset}->search( { 'me.id' => $customer_id } );
            $c->stash->{sub_heading} = "Found a customer with ID: $customer_id";
            $c->stash->{customer_count} = $c->stash->{resultset}->count // 0;

#                $c->stash->{found_msg}
#                     = $c->stash->{customer_count} . " customers found with customer Id's like $customer_id";
        }
        else {

            #------  Bad data Set an error message
            $ERROR = $TRUE;
            $c->stash( customer_id => $customer_id );
            $c->stash( error_msg   => $ERROR_MESSAGE );
            DEBUG '*** Customer customer Id ' . $ERROR_MESSAGE;
            $c->stash->{resultset}      = undef;
            $c->stash->{customer_count} = 0;
            $c->stash->{found_msg} =
                "Enter a valid customer Id no larger than $MAX_CUSTOMERS"
              . "<br /> $customer_id is invalid.";

        }
    }
    else {

        #------ First time through. No id selected yet
        $c->stash->{sub_heading}    = "Find Customers by customer Id.";
        $c->stash->{resultset}      = undef;
        $c->stash->{customer_count} = 0;
        $c->stash->{found_msg} =
          'Enter the customer Id for the customer you are looking for.';
        $c->stash->{template} = 'Customer/customer_list.tt2';
        $form_action = $c->uri_for('/customer/list_by_customer_id');
    }

    #------ Add Customer Id Form Here
    my $customer_id_form = <<END;
    <form class="form-inline" method="post"  action="$form_action" id="customer_id">
        <div class="control-group">
            <div class="controls">
                <input type="text" class="input-mini" placeholder="Customer Id." 
               label="Customer Id" title="Enter the customer Id"
                 id="customer_id" name="customer_id" %]>
                 <button type="submit" name="submit"  class="btn btn-info btn-mini">Find Customer</button>
            </div>
             
          </div>
    </form>
END

    #------ Add js to bottom template  (Form Validation to JS array)
    $c->stash(
        bottom_js => 'js/bottom_js.tt2',
        js_array  => [ $self->id_form_valid_js($c), ],
    );
    $c->stash->{top_form} = $customer_id_form;

    $c->stash->{template} = 'Customer/customer_list.tt2';
}

=head2 list_by_phone_no
    Find a customer by any customer phone Number
=cut

sub list_by_phone_no : Chained('base') : PathPart('list_by_phone_no') :
  Args(0) {
    my ( $self, $c ) = @_;
    my $phone_no = $c->request->params->{phone_no} || undef;

    #    my $valid = MyValid->new();
    DEBUG "*** INSIDE Customer list_by_phone_no. phone Number is: $phone_no";

    # Ensure user has permission to see this resultset
    $c->detach('/error_noperms')
      unless $c->stash->{resultset}->viewing_permission( $c->user->get_object );

    #----- Get the customers
    if ( defined $phone_no ) {
        if (   MyValid->is_it_numeric($phone_no)
            && MyValid->is_length_ok( $phone_no, $PHONE_NO_MAX_LENGTH ) )
        {
            $phone_no =~ s/^\s+//;
            $phone_no =~ s/\s+$//;
            DEBUG
"*** INSIDE Customer list_by_phone_no. first_name # is: $phone_no";

            #------ Remove leading 1 from phone number
            if ( substr( $phone_no, 0, 1 ) == 1 ) {
                $phone_no = substr( $phone_no, 1 );
            }
            $c->stash->{resultset} = $c->stash->{resultset}->search(
                [
                    { 'me.first_name_1' => $phone_no },
                    { 'me.first_name_2' => $phone_no },
                    { 'me.first_name_3' => $phone_no }
                ]
            );
            $c->stash->{customer_count} = $c->stash->{resultset}->count // 0;
            $c->stash->{sub_heading} =
              ( $c->stash->{customer_count} > 1 )
              ? "Customers matching : $phone_no"
              : ( $c->stash->{customer_count} == 1 )
              ? "Customer matching : $phone_no"
              : "No customer found with phone number $phone_no";

#                $c->stash->{found_msg}
#                     = $c->stash->{customer_count} . " customers found with phone Number's like $phone_no";
        }
        else {

            #------  Bad data Set an error message
            $ERROR = $TRUE;
            $c->stash( phone_no  => $phone_no );
            $c->stash( error_msg => $ERROR_MESSAGE );
            DEBUG '*** Customer phone Number ' . $ERROR_MESSAGE;
            $c->stash->{resultset}      = undef;
            $c->stash->{customer_count} = 0;
            $c->stash->{found_msg}      = "Enter a valid (US) Phone Number"
              . "<br /> $phone_no is invalid.";
        }
    }
    else {

        #------ First time through. No id selected yet
        $c->stash->{sub_heading}    = "Find Customers by phone Number.";
        $c->stash->{resultset}      = undef;
        $c->stash->{customer_count} = 0;
        $c->stash->{found_msg} =
          'Enter the phone Number for the customer you are looking for.';
    }
    my $form_action = $c->uri_for('/customer/list_by_phone_no');

    #------ Add phone Number Form Here
    my $phone_no_form = <<END;
    <form class="form-inline" method="post"  action="$form_action" id="phone_no">
        <div class="control-group">
            <div class="controls">
                <input type="text" class="input-mini" placeholder="phone Number." 
               label="phone Number" title="Enter the phone Number"
                 id="phone_no" name="phone_no" %]>
                 <button type="submit" name="submit"  class="btn btn-info btn-mini">Find Customer</button>
            </div>
             
          </div>
    </form>
END
    $c->stash->{top_form} = $phone_no_form;

#------ Add js to bottom template  (jQ Datepicker And Form Validation to JS array)
    $c->stash(
        bottom_js => 'js/bottom_js.tt2',
        js_array  => [ $self->phone_form_valid_js($c) ],
    );

    #    $c->stash->{'validation_js'} = <<END_JS;
    #    <script type="text/javascript"
    #    src="$js">
    #    </script>'
    #END_JS
    $c->stash->{template} = 'Customer/customer_list.tt2';
}

#
##
####------ List Customers By First And Last Name
##
#

=head2 list_by_customer_name
    List customers
    Matching Passed first and last names
=cut

sub list_by_customer_name : Chained('base') :
  PathPart('list_by_customer_name') : Args(1) {
    my ( $self, $c, $first_last_name ) = @_;

    # Ensure user has permission to see this resultset
    $c->detach('/error_noperms')
      unless $c->stash->{resultset}->viewing_permission( $c->user->get_object );

    DEBUG
      "*** INSIDE Customer list_by_customer_name. Name is: $first_last_name";
    my @wanted_name = split( ' ', $first_last_name );

    #----- Get the customers
    $c->stash->{resultset} = $c->stash->{resultset}->search(
        -and => [
            'me.first_name' => lc( $wanted_name[0] ),
            'me.last_name'  => lc( $wanted_name[1] )
        ],
    );

    #------ Add js to bottom template  (Form Validation to JS array)
    $c->stash(
        bottom_js => 'js/bottom_js.tt2',
        js_array  => [
            $self->first_name_form_valid_js($c),
            $self->last_name_form_valid_js($c),
        ],
    );

    $c->stash->{template} = 'Customer/list.tt2';
}

#
##
####------ List Customer By Multiple Names
##
#

=head2 list_by_multiple_names
    List customers
    That have a first or last  name like the entered names
    Pass an array ref of names
=cut

sub list_by_multiple_names : Chained('base') :
  PathPart('list_by_multiple_names') : Args(1) {
    my ( $self, $c, $names ) = @_;
    my @wanted_names = split( ' ', $names );
    DEBUG " Searching for customer names " . Dumper(@wanted_names);

    # Ensure user has permission to see this resultset
    $c->detach('/error_noperms')
      unless $c->stash->{resultset}->viewing_permission( $c->user->get_object );

    my (@like_names);
    for my $name (@wanted_names) {
        push @like_names, '%' . $name . '%';
    }

    #----- Get the customer details for this shipper
    $c->stash->{resultset} = $c->stash->{resultset}->search(
        -or => [
            first_name => { 'like' => \@like_names },
            last_name  => { 'like' => \@like_names }
        ]
    );

    #------ Add js to bottom template  (Form Validation to JS array)
    $c->stash(
        bottom_js => 'js/bottom_js.tt2',
        js_array  => [
            $self->first_name_form_valid_js($c),
            $self->last_name_form_valid_js($c),
        ],
    );

    $c->stash->{template} = 'Customer/list.tt2';

}

#
##
####------ Generic list of Customers
##
#

=d2 list
Fetch all customer objects and display some details 
Sorted by 
=cut

sub list : Chained('base') : PathPart('list') : Args(0) {
    my ( $self, $c ) = @_;

    #    $DB::single = 1;    # For Debug
    DEBUG "******  List customers method ******";

    # Ensure user has permission to see this resultset
    $c->detach('/error_noperms')
      unless $c->stash->{resultset}->viewing_permission( $c->user->get_object );

    my $sort_by_1 = 'me.last_name';     # Timestamp
    my $sort_by_2 = 'me.first_name';    # string
    my $sort_by_3 = 'me.created';       # string
    my $sort_by_4 = 'me.updated';

    $c->stash->{resultset} =
      $c->stash->{resultset}->search( {},
        { 'order_by' => [ $sort_by_1, $sort_by_2, $sort_by_3, $sort_by_4 ], },
      );
    $c->stash->{customer_count} = $c->stash->{resultset}->count // 0;

    # Set the template
    $c->stash->{template} = 'Customer/customer_list.tt2';
}

###############################################################################
# Single Customer Details
###############################################################################

=head2 display_Customer_details
    One page Customer detail display
=cut

sub display_customer_details : Chained('object') :
  PathPart('display_customer_details') : Args(0) {
    my ( $self, $c ) = @_;
    my $customer_id = $c->stash->{object}->id;
    DEBUG "*** INSIDE display_customer_details. Customer ID: " . $customer_id;

    # Does the customer have the premission to to see the Sustomer details.
    $c->detach('/error_noperms')
      unless $c->stash->{object}->display_allowed_by( $c->user->get_object );

    #------ Show History of Estimates
    my $est_history = $c->model('DB::Estimate')->with_customer_id($customer_id);
    my $estimate_count;
    if ( ( $estimate_count = $est_history->count() ) > 0 ) {
        $c->stash->{estimate_history} = $est_history;
        $c->stash->{estimate_history_count} = $estimate_count // 0;
        DEBUG
          " Found $estimate_count Estimates for customer with ID: $customer_id";
    }
    else {
        $c->stash->{estimate_history} = 0;
    }

    #------ Print Updated By/Date only if it has been updated
    $c->stash->{updated} = DateTime->compare( $c->stash->{object}->created,
        $c->stash->{object}->updated );
    DEBUG "*** Created Date." . $c->stash->{object}->created;
    DEBUG "*** Updated Date." . $c->stash->{object}->updated;
    $c->stash->{template} = 'Customer/display_customer_details.tt2';
}

#-------------------------------------------------------------------------------
#  Delete
#  Delete an customer.
#-------------------------------------------------------------------------------

=head2 delete
    Delete customer
=cut

sub delete : Chained('object') : PathPart('delete') : Args(0) {
    my ( $self, $c ) = @_;
    $c->log->debug( '*** INSIDE delete . User is ' . $c->user->id . ' ***' );

   # Ensure the user has permission to delete customers
   #    $c->detach('/error_noperms')
   #      unless $c->stash->{object}->delete_allowed_by( $c->user->get_object );

    # Uses  'Catalyst::Plugin::Authorization::Roles' to ensure this user
    # has permission to delete a customer from the database
    $c->detach('/error_noperms')
      unless $c->check_user_roles('can_delete_customer');

    # Saved the PK id for status_msg below
    my $id = $c->stash->{object}->id;

    # Use the customer object saved by 'object' and delete it along
    # with related 'customerEstimators' entries
    $c->stash->{object}->delete;
    $c->log->debug( '*** INSIDE delete . Id to delete is ' . $id . ' ***' );

    # Redirect the user back to the list page
    $c->response->redirect(
        $c->uri_for(
            $self->action_for('list'),
            {
                mid => $c->set_status_msg(
                        'Deleted customer ID: '
                      . $id
                      . ' With Name: '
                      . $c->stash->{object}->full_name
                )
            }
        )
    );
}

#
##
###------ Forms
##
#

=head2 formfu_create
    Use HTML::FormFu to create a new Customer
=cut

#------ CREATE A CUSTOMER
sub create_customer : Chained('base') : PathPart('create_customer' ) : Args(0)
  : FormConfig('customer/create_customer.yml') {
    my ( $self, $c ) = @_;
    $c->log->debug("*** INSIDE $CREATE_CUSTOMER ***");

    # Does the user have permission to create a new Customer
    #    $c->detach('/error_noperms')
    #      unless $c->model('DB::Estimate')->create_allowed_by( $c->user );

    # Uses  'Catalyst::Plugin::Authorization::Roles' to ensure this user
    #    # has permission to create a new Customer
    #    $c->detach('/error_noperms')
    #      unless $c->check_user_roles('can_create_estimate');

    # Uses  'Catalyst::Plugin::Authorization::Roles' to ensure this user
    # has permission to create a new customer
    $c->detach('/error_noperms')
      unless $c->check_user_roles('can_create_customer');

    # Get the form that the :FormConfig attribute saved in the stash
    my $form = $c->stash->{form};

    # Check permissions
    #    $c->detach('/error_noperms')
    #        unless $c->model('DB::Customer')->create_allowed_by($c->user);
    #    $c->log->debug('*** Whats in this Form anyway ***' . Dumper($form));
    # is shorthand for "$form->submitted && !$form->has_errors"
    if ( $form->submitted_and_valid ) {
        my ( $customer, $city_state, $city, $state, $zip );

        #------ Create a new customer
        #todo find_or_create instead of new_result
        $customer =
          $c->model('DB::Customer')
          ->new_result( { 'created_by' => $c->user->id } );
        $form->model->update($customer);
        my $customer_id = $customer->id;
        my $full_name   = $customer->full_name();

        # Set a status message for the user & return to customers list
        $c->response->redirect(
            $c->uri_for(
                $self->action_for('display_customer_details'),
                [$customer_id],
                { mid => $c->set_status_msg("Customer $full_name created") }
            )
        );
        $c->detach;
    }
    else {

        #		DEBUG "Create customer form is: " . $c->stash->{form};
    }

#------ Add js to bottom template  (jQ Datepicker And Form Validation to JS array)
    $c->stash(
        bottom_js => 'js/bottom_js.tt2',
        js_array  => [
            $self->datepicker_activation_js($c),
            $self->customer_form_valid_js($c),
            $self->city_state_zip_js($c),
            $self->city_state_zip_copy_js($c),
        ],
    );

    $c->stash->{template} = "$CUSTOMER_PATH$CREATE_CUSTOMER.tt2";
    $c->forward( $c->view('HTML') );
}

=head2 update_customer
       Use HTML::FormFu to update an existing customer
=cut

#------ UPDATE A CUSTOMER
sub update_customer : Chained('object') : PathPart('update_customer') :
  Args(0) : FormConfig('customer/update_customer.yml') {
    my ( $self, $c ) = @_;
    my ( $customer_rs, $customer );
    DEBUG "*** Just Inside Update Customer ***";

    # Uses 'Catalyst::Plugin::Authorization::Roles' to ensure this user
    # has permission to update a customer
    $c->detach('/error_noperms')
      unless $c->check_user_roles('can_update_customer');

   # Check permissions
   #    $c->detach('/error_noperms')
   #      unless $c->stash->{object}->update_allowed_by( $c->user->get_object );

# Get the specified customer/customer result set already saved by the 'object' method
    $customer_rs = $c->stash->{object};

    # Make sure we were able to get a customer
    if ( not $customer_rs ) {

        # Set an error message for the user & return to customers list
        $c->response->redirect(
            $c->uri_for(
                $self->action_for('list'),
                {
                    mid =>
                      $c->set_error_msg("Invalid customer id ;-- Cannot edit")
                }
            )
        );
        $c->detach;
    }

    # Get the form that the :FormConfig attribute saved in the stash
    my $form = $c->stash->{form};

    # Check if the form has been submitted (vs. displaying the initial
    # form) and if the data passed validation.  "submitted_and_valid"
    # is shorthand for "$form->submitted && !$form->has_errors"
    if ( $form->submitted_and_valid ) {

        #------ Update the customer info
        $customer = $c->model('DB::Customer')->update_or_new(
            {
                'id'         => $customer_rs->id,
                'updated_by' => $c->user->id,

#                                                 'updated'   =>  DateTime->now->set_time_zone( 'America/New_York' ),
            },
            { key => 'primary' }
        );

        # Save the form data for the customer
        $form->model->update($customer);

        my $customer_id = $customer->id;
        my $full_name   = $customer->full_name();

        DEBUG "Customer updated time zone is  ***" . DateTime->now();

        # Set a status message for the user & return to customers list

        $c->response->redirect(
            $c->uri_for(
                $self->action_for('display_customer_details'),
                [$customer_id],
                { mid => $c->set_status_msg("Customer $full_name updated") }
            )
        );
        $c->detach;
    }
    else {

        #------ Change from submit to Update
        my $submit_el = $form->get_field(
            {
                name => 'submit',
                type => 'Submit',
            }
        );
        $submit_el->value('Update Customer');
        $submit_el->id('update');

        #------ Populate the form with existing values from DB
        $form->model->default_values($customer_rs);
        DEBUG " The New Submit Element is $submit_el";
    }

#------ Add js to bottom template  (jQ Datepicker And Form Validation to JS array)
    $c->stash(
        bottom_js => 'js/bottom_js.tt2',
        js_array  => [
            $self->datepicker_activation_js($c),
            $self->customer_form_valid_js($c),
            $self->city_state_zip_js($c),
            $self->city_state_zip_copy_js($c),
        ],
    );

    $c->stash->{new_heading} = "Edit Customer Details And Press Update";
    $c->stash->{template}    = "$CUSTOMER_PATH$CREATE_CUSTOMER.tt2";
    $c->stash->{updating}    = 1;
    $c->forward( $c->view('HTML') );
}

=d2 create_text_input_form
    Returns a simple search form with one text field
    As a string
    Pass a hash ref with form attr's
=cut

sub create_text_input_form : Private {
    my ( $self, my $attr ) = @_;
    my $form_attr   = $attr->{form_attr}        // undef;
    my $form_id     = $attr->{form_id}          // undef;
    my $form_label  = $attr->{form_label}       // undef;
    my $placeholder = $attr->{form_placeholder} // undef;
    my $title       = $attr->{form_title}       // undef;
    my $method      = $attr->{form_method}      // 'get';
    my $action      = $attr->{form_action}      // 'get';
    my $help_text   = $attr->{help_text}        // undef;
    my $button_attr = $attr->{button_attr}      // undef;
    my $button_text = $attr->{button_text}      // undef;

    #------ Add Last Name Form Here
    my $last_name_form = <<END;
	<form class="$form_attr" action="$action" id="$form_id" >
		<div class="control-group">
		  <label class="control-label" for="$form_id">$form_label</label>
			<div class="controls">
			  <input type="text" class="input-mini" placeholder="$placeholder" method="$method" 
			    title="$title" >
		 		<p class="help-inline">$help_text</p>
	 		</div>
		 	 <button type="submit" class="$button_attr">$button_text</button>
		  </div>
	</form>
END
    return $last_name_form;
}
#########################################################################
#------ Validations
#########################################################################

=d2 is_it_text
Check that the names contain only text
Pass the name. Strip white space. Check that the name is text only.
Return trimmed name if it is text only.
Return an undef if it is not text only.
Set the error message.
=cut

#sub is_it_text : Private {
#    my $self = shift;
#    my $name = shift;
#    $name =~ s/^\s+//;
#    $name =~ s/\s+$//;
#    return $name if ( $name =~ m/^[a-z]+$/i );
#    $ERROR_MESSAGE = "This contains some non alpha stuff! $name";
#    DEBUG "$name Failed the is_it_text test";
#    $FALSE;
#}

=d2 is_it_a_name
    Check that the names contain only text
    plus a few other characters that can be used in a last name
    like ' or - 
    Pass the name. Strip white space. Check that the name ok.
    Return trimmed name if it is ok.
    Return an undef if it is not ok.
    Set the error message.
=cut

#sub is_it_a_name : Private {
#    my $self = shift;
#    my $name = shift;
#    $name =~ s/^\s+//;
#    $name =~ s/\s+$//;
#    return $name if ( $name =~ m/^[a-z'-]+$/i );
#    $ERROR_MESSAGE = "This contains some non alpha stuff! $name";
#    DEBUG "$name Failed the is_it_a_name test";
#    $FALSE;
#}

=d2 is_it_two_names
    Check that the first/last names contain only text
    Pass the name. Strip white space. Check that the names aretext only
    seperated by white space
    Return trimmed names if names are ok.
    Return an undef they are not ok.
    Set the error message.
=cut

#
#sub is_it_two_names : Private {
#    my $self            = shift;
#    my $first_last_name = shift;
#    $first_last_name =~ s/^\s+//;
#    $first_last_name =~ s/\s+$//;
#    my @names = split( ' ', $first_last_name );
#    return $first_last_name
#      if ( ( @names == 2 )
#        && ( $names[0] =~ m/^[a-z]+$/i )
#        && ( $names[1] =~ m/^[a-z]+$/i ) );
#    $ERROR_MESSAGE = "This is not a real name! $first_last_name";
#    DEBUG "$first_last_name Failed the is it two names test";
#    $FALSE;
#}

=d2 is_it_numeric
    Check that the id contains only numeric date
    Pass the id. Strip white space. Check that the id is numeric only.
=cut

#sub is_it_numeric : Private {
#    my $self = shift;
#    my $id   = shift;
#    $id =~ s/^\s+//;
#    $id =~ s/\s+$//;
#    return $id if ( $id =~ m/^\d+$/i );
#    $ERROR_MESSAGE = "This is not a real number! $id";
#    DEBUG "$id Failed the is_it_numeric test";
#    undef;
#}
#

=d2 is_it_between
    Check that a value is within a certain range (Inclusive)
    Pass the value and the Range (Start and end value )
    Return 1 for yes and 0 for no.
=cut

sub is_it_between : Private {
    my ( $self, $value, $first, $second ) = @_;
    return undef
      unless ( ( defined $value )
        && ( defined $first )
        && ( defined $second ) );
  SWITCH:
    {
        ( $first < $second ) && do {
            return $TRUE if ( ( $value >= $first ) && ( $value <= $second ) );
            last SWITCH;
        };
        ( $first > $second ) && do {
            return $TRUE if ( ( $value >= $second ) && ( $value <= $first ) );
            last SWITCH;
        };
    }
    $ERROR_MESSAGE = "This is not within the range $first to  $second";
    DEBUG "$value Failed the is_it_between test";
    $FALSE;
}

=d2 is_length_ok
    Check that the names is not too long
    Pass the name. Strip white space. Check that the name is not too long. 
    Return true(1) if length is ok.
    Return an undef if it is too long.
    Set the error message.
=cut

#sub is_length_ok : Private {
#    my $self       = shift;
#    my $name       = shift;
#    my $max_length = shift;
#
#    #    my ($self, &$name, $max_length) = @_;
#    return $TRUE if ( ( length $name ) <= $max_length );
#    $ERROR_MESSAGE = "This name is too long!";
#    DEBUG "$name Failed the is_length_ok test";
#    $FALSE;
#}
#
#
##
### ------ JQuery  Create/Update Form Validation
##
#

=head2 customer_form_valid_js
    Javascript to validate input data (Client Side)
    For Create/Update Estimate Form(s)
    pass $c
=cut

sub customer_form_valid_js {
    my ( $self, $c ) = @_;
    my $js = $c->uri_for('/') . $CUSTOMER_FORM_VALIDATION_JS;
    return <<END_JS;
    <script type="text/javascript" 
    src="$js">
    </script>
END_JS
}

=head2 first_name_form_valid_js
    Javascript to validate input data (Client Side)
    List customer by first_name 
    pass $c
=cut

sub first_name_form_valid_js {
    my ( $self, $c ) = @_;
    my $js = $c->uri_for('/') . $FIRST_NAME_FORM_VALIDATION_JS;
    return <<END_JS;
    <script type="text/javascript" 
    src="$js">
    </script>
END_JS
}

=head2 last_name_form_valid_js
    Javascript to validate input data (Client Side)
    List customer by last_name 
    pass $c
=cut

sub last_name_form_valid_js {
    my ( $self, $c ) = @_;
    my $js = $c->uri_for('/') . $LAST_NAME_FORM_VALIDATION_JS;
    return <<END_JS;
    <script type="text/javascript" 
    src="$js">
    </script>
END_JS
}

=head2 phone_form_valid_js
    Javascript to validate input data (Client Side)
    List customer by phone 
    pass $c
=cut

sub phone_form_valid_js {
    my ( $self, $c ) = @_;
    my $js = $c->uri_for('/') . $PHONE_FORM_VALIDATION_JS;
    return <<END_JS;
    <script type="text/javascript" 
    src="$js">
    </script>
END_JS
}

=head2 id_form_valid_js
    Javascript to validate input data (Client Side)
    List customer by id 
    pass $c
=cut

sub id_form_valid_js {
    my ( $self, $c ) = @_;
    my $js = $c->uri_for('/') . $ID_FORM_VALIDATION_JS;
    return <<END_JS;
    <script type="text/javascript" 
    src="$js">
    </script>
END_JS
}

=head2 datepicker_activation_js
    Javascript to Activate JQ Date Picker Calander
    pass $c
=cut

sub datepicker_activation_js {
    my ( $self, $c ) = @_;
    my $js = $c->uri_for('/') . my $DATE_PICKER_JS;
    return <<END_JS;
    <script type="text/javascript" 
    src="$js">
    </script>
END_JS
}

=head2 city_state_zip_js
    Javascript to provide USA cities states zips 
    and js to split the city state and zip fields
    For Create/Update Estimate Form(s)
    pass $c
=cut

sub city_state_zip_js {
    my ( $self, $c ) = @_;
    my $js = $c->uri_for('/') . $CITY_STATE_ZIP_JS;
    return <<END_JS;
    <script type="text/javascript" 
    src="$js">
    </script>
END_JS
}

=head2 city_state_zip_copy_js
    Javascript to split cities states zips 
    and copy to respective form fields
    For Create/Update Estimate Form(s)
    pass $c
=cut

sub city_state_zip_copy_js {
    my ( $self, $c ) = @_;
    my $js = $c->uri_for('/') . $CITY_STATE_ZIP_COPY_JS;
    return <<END_JS;
    <script type="text/javascript" 
    src="$js">
    </script>
END_JS
}

=head1 AUTHOR

austin,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;
1;
