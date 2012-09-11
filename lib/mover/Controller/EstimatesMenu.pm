package mover::Controller::EstimatesMenu;
use Moose;
use namespace::autoclean;
use Log::Log4perl qw(:easy);
use Data::Dumper;

#BEGIN { extends 'Catalyst::Controller'; }
BEGIN { extends 'Catalyst::Controller::HTML::FormFu'; }

=head1 NAME

mover::Controller::EstimatesMenu - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

###############################################################################
#------
my $YES = my $TRUE  = 1;
my $NO  = my $FALSE = 0;
my $HOST                     = 'http://localhost:3000';
my $ESTIMATES_CONTROLLER     = 'Estimates';
my $LIST_ALL_ESTIMATES       = 'list';
my $LIST_ALL_ESTIMATES_LABEL = 'View All Estimates';
my $SCHEDULE_ESTIMATE_LABEL  = 'Schedule A New Estimate';
my $UPDATE_ESTIMATE          = 'update_estimate';
my $DELETE_ESTIMATE          = 'delete_estimate';
my $DISPLAY_ESTIMATE         = 'display_estimate';       # 'display_estimate';
my $LAST_NAME_MAX_LENGTH     = 40;
my $FIRST_NAME_MAX_LENGTH    = 40;
my $NAME_MAX_LENGTH  = $LAST_NAME_MAX_LENGTH + $FIRST_NAME_MAX_LENGTH;
my $MAX_NUM_OF_NAMES = 10;
my $MIN_WEEKS = -52;
my $MAX_WEEKS = +52;
my $FIRST_DAY_OF_WEEK = 1;
my $LAST_DAY_OF_WEEK = 7;
my $MAX_MONTHS = 12;

my $ERROR_MESSAGE    = undef;

 
#------ Java Script Locations
my $CUSTOMER_FORM_VALIDATION_JS = "static/jquery/js/jquery_customer_form_valid.js";
my $PHONE_FORM_VALIDATION_JS = "static/jquery/js/jquery_customer_phone_valid.js";
my $FIRST_NAME_FORM_VALIDATION_JS = "static/jquery/js/jquery_first_name_form_valid.js";
my $LAST_NAME_FORM_VALIDATION_JS = "static/jquery/js/jquery_last_name_form_valid.js";
my $FULL_NAME_FORM_VALIDATION_JS = "static/jquery/js/jquery_full_name_form_valid.js";
my $ID_FORM_VALIDATION_JS = "static/jquery/js/jquery_customer_id_form_valid.js";
my $DATE_VALIDATION_JS  = "static/jquery/js/jquery_date_valid.js";
#------
my $DATE_PICKER_JS      = "static/jquery/js/datepicker_ui_function.js";
my $CITY_STATE_ZIP_JS      = "static/jquery/js/local_cities.js";
my $CITY_STATE_ZIP_COPY_JS   = "static/jquery/js/jquery_state_zip_copy.js";
my $EMPLOYEE_FULL_NAME_AUTO_C_JS      = "static/jquery/js/jquery_employee_name_id_auto_c.js";
 
=head2 index

=cut

sub index : Path : Args(0) {
    my ($self, $c) = @_;
    $c->response->body(
        'Matched mover::Controller::EstimatesMenu in EstimatesMenu. Try a different location.'
    );
}

#------ Chained For Estimates Menu

=head2 base
    Can place common logic to start chained dispatch here for Estimates menu
=cut

sub base : Chained('/') : PathPart('estimatesmenu') : CaptureArgs(0) {
    my ($self, $c) = @_;
    DEBUG '*** INSIDE BASE EstimatesMenu METHOD ***';

    # Load status messages
    $c->load_status_msgs;
}

=head2 main_menu
    Start at the main menu.
=cut

sub main_menu : Chained('base') : PathPart('main_menu') { # : CaptureArgs(0) {
    my ($self, $c) = @_;
    DEBUG '*** INSIDE BASE EstimatesMenu Menu METHOD ***';

    # Set the template
    $c->stash->{template} = 'EstimatesMenu/estimatesmenu.tt2';
    $c->forward($c->view('HTML'));
}

#
##
### ------ Customer Part
##
#

=head2 by_customer
    Find estimates by customer menu.
=cut

sub by_customer : Chained('base') : PathPart('by_customer') {
    my ($self, $c) = @_;
    my ($first_name, $last_name, $search_name, $saved_name);
    my $ERROR = $FALSE;
    $ERROR_MESSAGE = '';
    $saved_name    = '';
    DEBUG '*** INSIDE Estimates by_customer METHOD ***';

    #----- Check which input field was activated
SWITCH: {

        #------  Find estimates based on customer last name
        (defined($saved_name = $c->request->body_params->{last_name})) && do {

    #        $saved_name = $last_name = $c->request->body_params->{last_name};
    #------ Find the estimates if the trimmed input name seems ok
            if (($last_name = $self->is_it_text($saved_name))
                && $self->is_length_ok($last_name, $LAST_NAME_MAX_LENGTH))
            {
                DEBUG " Redirecting to estimates to : "
                    . $c->uri_for($c->controller('Estimates')
                                  ->action_for('list_by_last_name'));
                $c->response->redirect(
                                    $c->uri_for(
                                        $c->controller('Estimates')
                                            ->action_for('list_by_last_name'),
                                        $last_name
                                    )
                );
                $c->detach();
                return;
            }
            else {

                # Set an error message
                $ERROR = $TRUE;
                $c->stash(last_name => $saved_name);
                $c->stash(error_msg => $ERROR_MESSAGE);
                DEBUG '*** Customer last name ' . $ERROR_MESSAGE;
            }
            last SWITCH;
        };

        #------  Find estimated based on customer first name
        (defined($saved_name = $c->request->body_params->{first_name}))
            && do {

            #        $saved_name =  $c->request->body_params->{first_name};
            #------ Find the estimates if the input name seems ok
            if (($first_name = $self->is_it_text($saved_name))
                && $self->is_length_ok($first_name, $FIRST_NAME_MAX_LENGTH))
            {
                DEBUG " Redirecting to estimates to : "
                    . $c->uri_for($c->controller('Estimates')
                                  ->action_for('list_by_first_name'));
                $c->response->redirect(
                                   $c->uri_for(
                                       $c->controller('Estimates')
                                           ->action_for('list_by_first_name'),
                                       $first_name
                                   )
                );
                $c->detach();
                return;
            }
            else {

                # Set an error message
                $ERROR = $TRUE;
                $c->stash(first_name => $saved_name);
                $c->stash(error_msg  => $ERROR_MESSAGE);
                DEBUG '*** Customer First name '
                    . $saved_name
                    . ' failed: '
                    . $ERROR_MESSAGE;
            }
            last SWITCH;
            };

       #------  Search for customers based on a set of first and/or last names
        (defined($saved_name = $c->request->body_params->{search_name}))
            && do {
            my (@names, $original_names, $names_string);
            if ($original_names =
                $self->split_name_into_array(
                                       $c->request->body_params->{search_name}
                )
                )
            {
            CHECK_NAMES:

                #------ Trim and check all the names
                #            while (my $name = @$names){
                foreach my $name (@$original_names) {
                    next CHECK_NAMES
                        if (($name = $self->is_it_text($name))
                        && ($self->is_length_ok($name, $LAST_NAME_MAX_LENGTH))
                        && ($names_string .= " $name "));
                    $ERROR = $TRUE;
                    last CHECK_NAMES;
                }
            }
            else {
                $ERROR = $TRUE;
            }

            #------ Find the estimates for these names if they seem real.
            if (not $ERROR) {
                DEBUG " Redirecting to estimates to : "
                    . $c->uri_for($c->controller('Estimates')
                                  ->action_for('search_customer_names'));
                $c->response->redirect(
                               $c->uri_for(
                                   $c->controller('Estimates')
                                       ->action_for('list_by_multiple_names'),
                                   $names_string
                               )
                );
                $c->detach();
                return;
            }
            else {

                #------ Display the Error message
                $c->stash(search_name => $saved_name);
                $c->stash(error_msg   => $ERROR_MESSAGE);
                DEBUG
                    '*** INSIDE BASE EstimatesMenu by_customer. Got a bad name in : '
                    . $saved_name . ' '
                    . $ERROR_MESSAGE;
            }
            last SWITCH;
            };

        #------ If not dispatched by now, it must be an empty string
        # Set an error message
        $c->stash(error_msg => "Enter a name.");
    }    # End Switch

    # Set the template
    $c->stash->{template} = 'EstimatesMenu/by_customer.tt2';
    $c->forward($c->view('HTML'));
}

#
##
### ------ Estimator Part
##
#

=head2 by_estimator
    Find estimates by estimator Menu.
=cut

sub by_estimator : Chained('base') : PathPart('by_estimator') {
    my ($self, $c) = @_;
    my ($estimator_id, $search_name, $saved_id, $saved_name, $first_name);
    DEBUG '*** INSIDE BASE EstimatesMenu by_estimator ***';
    DEBUG '*** The estimator id is: ***'
        . $c->request->body_params->{estimator_id};
    $ERROR_MESSAGE = '';

    #----- Check which input field was activated
SWITCH: {

        #------  Find estimates based on customer last name
        (defined($saved_id = $c->request->body_params->{estimator_id}))
            && do {
            DEBUG
                "*** Searching for estimates for estimator id: $saved_id   ***";

            #------ Find the estimates if the trimmed input name seems ok
            if (($estimator_id = $self->is_it_numeric($saved_id))
                && $self->is_length_ok($estimator_id, $LAST_NAME_MAX_LENGTH))
            {
                DEBUG " Redirecting to estimates to : "
                    . $c->uri_for($c->controller('Estimates')
                                  ->action_for('list_by_estimator_id'));
                $c->response->redirect(
                                 $c->uri_for(
                                     $c->controller('Estimates')
                                         ->action_for('list_by_estimator_id'),
                                     $estimator_id
                                 )
                );
                $c->detach();
                return;
            }
            else {

                # Set an error message
                $ERROR = $TRUE;
                $c->stash(estimator_id => $saved_id);
                $c->stash(error_msg    => $ERROR_MESSAGE);
                DEBUG '*** Estimator id ' . $ERROR_MESSAGE;
            }
            last SWITCH;
            };

        #------  Search for estimators based on first and last (employee)name
        (defined($saved_name = $c->request->body_params->{employee_name}))
            && do {

            #
            my ($employee_name);

            #------ Find the estimates if the input name seems ok
            if (($employee_name = $self->is_it_two_names($saved_name))
                && $self->is_length_ok($employee_name, $NAME_MAX_LENGTH))
            {
                DEBUG " Redirecting to estimates to : "
                    . $c->uri_for($c->controller('Estimates')
                                  ->action_for('list_by_employee_name'));
                $c->response->redirect(
                                $c->uri_for(
                                    $c->controller('Estimates')
                                        ->action_for('list_by_employee_name'),
                                    $employee_name
                                )
                );
                $c->detach();
                return;
            }
            else {

                # Set an error message
                $ERROR = $TRUE;
                $c->stash(employee_name => $saved_name);
                $c->stash(error_msg     => $ERROR_MESSAGE);
                DEBUG '*** Employee name '
                    . $saved_name
                    . ' failed: '
                    . $ERROR_MESSAGE;
            }
            last SWITCH;
            };

        #------ If not dispatched by now, it must be an empty string
        # Set an error message
        $c->stash(error_msg => "Select an estimator.");
    }    # End Switch

    # Set the template
    #------ Get a sorted list of estimators
    $c->stash->{estimators} = $self->create_estimator_list($c);
    $c->stash->{admin}      = $self->create_office_staff_list($c);

    #todo ------ Need to make a callback database search for employee data
    my $emp_id_names =
        $self->create_employee_ids_names($self->create_employee_list($c));
    my $names_str = '';

    #------ Copy the Full Name to the string
    foreach my $emp (@$emp_id_names) {
        $names_str .= '"' . $emp->[1] . '",';

#       $names_str .=  '{ label: ' . '"'.$emp->[1]. '", value: '. '"'.$emp->[0].'" },' ;
    }

#    http://www.jensbits.com/2011/05/09/jquery-ui-autocomplete-widget-with-perl-and-mysql/
#    [ { label: "Choice1", value: "value1" }, ... ]
    
    chop($names_str);
    DEBUG "Chopped Names are " . '[' . $names_str . ']';
    $c->stash->{employee_full_names} = '[' . $names_str . ']';


#------ Add js to bottom template  (jQ Employee ID ->NAME ->autocomplete and
#       validation js to JS array)
    $c->stash(bottom_js => 'js/bottom_js.tt2',
              js_array  => [
                            $self->full_name_form_valid_js($c), 
              ],
    );

    $c->stash->{template}           = 'EstimatesMenu/by_estimator.tt2';
 
    $c->forward($c->view('HTML'));
}

#
##
### ------ Date Part
##
#

=head2 by_date
    Find estimates by Date.
=cut

sub by_date : Chained('base') : PathPart('by_date') : Args() :
    FormConfig('estimatesMenu/estimates_by_date_menu.yml') {
    my ($self, $c, $starting_date, $ending_date) = @_;
    my ($day, $week, $month);
    DEBUG '*** INSIDE BASE EstimatesMenu by_date ***';
    $ERROR_MESSAGE = '';
    # Get the form that the :FormConfig attribute saved in the stash
    my $form = $c->stash->{form};
    if ($form->submitted_and_valid) {

#        DEBUG '*** The estimate  date(s) is/are: ***'
#            . ($starting_date = $c->request->body_params->{starting_date}) . ' and '
#            . ( $ending_date = $c->request->body_params->{ending_date});
#----- Check which input field was activated
    SWITCH: {
            #
            #------  Find estimates between two dates
            #
            ((defined $starting_date) && (defined $ending_date))
                && do {
                DEBUG
                    "*** Searching for estimates starting on : $starting_date   ***";
                DEBUG "*** and ending on : $ending_date   ***";

                #------ Find the estimates id date is valid
                if (   ($self->is_date_valid($starting_date))
                    && ($self->is_date_valid($ending_date)))
                {
                    DEBUG " Redirecting to estimates to : "
                        . $c->uri_for($c->controller('Estimates')
                                      ->action_for('list_by_date'));
                    $c->response->redirect(
                                 $c->uri_for($c->controller('Estimates')
                                                 ->action_for('list_by_date'),
                                             $starting_date,
                                             $ending_date
                                 )
                    );
                    $c->detach();
                    return;
                }
                else {

                    # Set an error message
                    $ERROR = $TRUE;
                    $c->stash(error_msg => $ERROR_MESSAGE);
                    DEBUG '*** Estimate date for between dates '
                        . $ERROR_MESSAGE;
                    last SWITCH;
                }
                };
 
 
           
            
   
            my $date_field = $c->request->body_params->{schedule_date} // undef;

            #
            #------  Find Scheduled Estimates for a particular date
            #       
            ( (defined $date_field)
            && ( $self->is_date_format_valid($date_field)) )
                && do {
                 DEBUG
                    "*** Searching for estimates on : $date_field  ***";
                DEBUG " Redirecting to estimates to : "
                    . $c->uri_for(
                     $c->controller('Estimates')->action_for('list_by_date'));
                $c->response->redirect(
                                  $c->uri_for(
                                      $c->controller('Estimates')
                                          ->action_for('list_by_date'),
                                      $date_field
                                  )
                );
                $c->detach();
                return;
                }; # End day field
                
               
                
 
 
 
 
 
 
 
 
 
 
 
            #------ Temporary for testing          
            my $day_field = $form->get_field({ name => 'day', });

            #            my $param_value = $form->param_value->('day');
            #             DEBUG "*** Day field is: ". Dumper $day_field;
            #            DEBUG "*** Day field param_value is: ". $param_value;
#            DEBUG "*** Day field value is: " . $day_field->value;
#            DEBUG "*** Day field name value is: " . $day_field->name;
#            DEBUG "*** Day field stash value is: " . $c->stash->{form}->{day};
#            DEBUG "*** Day field body param value is: "
#                . $c->request->body_params->{day};
            $day_field = $c->request->body_params->{day} // undef;

            #
            #------  Find estimates based on day of week
            #        1 => monday , 7 => Sunday
            ( (defined $day_field)
            && ( $self->is_it_numeric($day_field))
            && ($self->is_it_between($day_field, $FIRST_DAY_OF_WEEK, $LAST_DAY_OF_WEEK)))
                && do {
                DEBUG
                    "*** Searching for estimates on day of week  number :$day_field   ***";
                DEBUG " Redirecting to estimates to : "
                    . $c->uri_for(
                     $c->controller('Estimates')->action_for('list_by_date'));
                $c->response->redirect(
                                  $c->uri_for(
                                      $c->controller('Estimates')
                                          ->action_for('list_by_day_of_week'),
                                      $day_field
                                  )
                );
                $c->detach();
                return;
                }; # End day field
                
               
                
            #
            #------  Find Scheduled Estimates For A particular Week
            #        0 = this week -1 = last week +1 = next week
            #        Maximum 52 in either direction       
            
            
            my $week_field = $c->request->body_params->{week} // undef;
            DEBUG
                    "*** Week field is  : $week_field";
                    
           ( ((defined $week_field) || ( $week_field == 0) || ($self->is_it_numeric($week_field)) )
             && ($self->is_it_between($week_field, $MIN_WEEKS, $MAX_WEEKS)))
                && do {
                DEBUG
                    "*** Searching for estimates for week number :$week_field   ***";
                DEBUG " Redirecting to estimates to : "
                    . $c->uri_for(
                     $c->controller('Estimates')->action_for('list_by_week'));
                $c->response->redirect(
                                  $c->uri_for(
                                      $c->controller('Estimates')
                                          ->action_for('list_by_week'),
                                      $week_field
                                  )
                );
                $c->detach();
                return;
                }; # End week field
                
                 
            #
            #------  Find Scheduled Estimates For A particular Month
            #        0 = Janurary  12 = December of this year
            #        Maximum of $MAX_MONTHS       
            
            
            my $month_field = $c->request->body_params->{month} // undef;
            DEBUG
                    "*** Month field is  : $month_field";
                    
           ( ((defined $month_field) && ( $month_field > 0) && ($self->is_it_numeric($month_field)) )
             && ($self->is_it_between($month_field, 1, $MAX_MONTHS)))
                && do {
                DEBUG
                    "*** Searching for estimates for month number :$month_field   ***";
                DEBUG " Redirecting to estimates to : "
                    . $c->uri_for(
                     $c->controller('Estimates')->action_for('list_by_month'));
                $c->response->redirect(
                                  $c->uri_for(
                                      $c->controller('Estimates')
                                          ->action_for('list_by_month'),
                                      $month_field
                                  )
                );
                $c->detach();
                return;
                }; # End month field
                
                
                

            # Set an error message
            $ERROR = $TRUE;
            $c->stash(error_msg => $ERROR_MESSAGE // ' No month value found');
            DEBUG '*** Estimate date for month ' . $ERROR_MESSAGE
                // ' No month value found';
            last SWITCH;
        }    # End SWITCH
        
    }
    
    
    
    else {
        #     
        #       DEBUG '*** Initial Form is  ' . $c->stash->{form};
    }
    $c->stash->{template} = 'EstimatesMenu/by_date.tt2';
    $c->forward($c->view('HTML'));
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

sub is_it_text : Private {
    my $self = shift;
    my $name = shift;
    $name =~ s/^\s+//;
    $name =~ s/\s+$//;
    return $name if ($name =~ m/^[a-z]+$/i);
    $ERROR_MESSAGE = "This contains some non alpha stuff! $name";
    DEBUG "$name Failed the is_it_text test";
    $FALSE;
}

=d2 is_it_a_last_name
Check that the names contain only text
plus a few other characters that can be used in a last name
like ' or - 
Pass the name. Strip white space. Check that the name ok.
Return trimmed name if it is ok.
Return an undef if it is not ok.
Set the error message.
=cut

sub is_it_a_last_name : Private {
    my $self = shift;
    my $name = shift;
    $name =~ s/^\s+//;
    $name =~ s/\s+$//;
    return $name if ($name =~ m/^[a-z'-]+$/i);
    $ERROR_MESSAGE = "This contains some non alpha stuff! $name";
    DEBUG "$name Failed the is_it_text test";
    $FALSE;
}




=d2 is_it_two_names
Check that the first/last names contain only text
Pass the name. Strip white space. Check that the names aretext only
seperated by white space
Return trimmed names if names are ok.
Return an undef they are not ok.
Set the error message.
=cut

sub is_it_two_names : Private {
    my $self            = shift;
    my $first_last_name = shift;
    $first_last_name =~ s/^\s+//;
    $first_last_name =~ s/\s+$//;
    my @names = split(' ', $first_last_name);
    return $first_last_name
        if (   (@names == 2)
            && ($names[0] =~ m/^[a-z]+$/i)
            && ($names[1] =~ m/^[a-z]+$/i));
    $ERROR_MESSAGE = "This is not a real name! $first_last_name";
    DEBUG "$first_last_name Failed the is_it_two_names test";
    $FALSE;
}

=d2 is_it_numeric
Check that the id contains only numeric date
Pass the id. Strip white space. Check that the id is numeric only.
=cut

sub is_it_numeric : Private {
    my $self = shift;
    my $id   = shift;
    $id =~ s/^\s+//;
    $id =~ s/\s+$//;
    return $id if ($id =~ m/^\d+$/i);
    $ERROR_MESSAGE = "This is not a real number! $id";
    DEBUG "$id Failed the is_it_numeric test";
    undef;
}

=d2 is_it_between
Check that a value is within a certain range (Inclusive)
Pass the value and the Range (Start and end value )
Return 1 for yes and 0 for no.
=cut

sub is_it_between : Private {
    my ($self, $value,  $first, $second)  = @_;
    return undef 
        unless ((defined $value) && (defined $first) && (defined $second));
     SWITCH: 
       {
           
         ($first < $second ) && do {
           return $TRUE if (($value >= $first) && ($value <= $second));
           last SWITCH;  
        }; 
        
        ($first > $second ) && do {
           return $TRUE if (($value >= $second) && ($value <= $first));
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

sub is_length_ok : Private {
    my ($self, $name, $max_length) = @_;
    return $TRUE if ((length $name) <= $max_length);
    $ERROR_MESSAGE = "This name is too long!";
    DEBUG "$name Failed the is_length_ok test";
    $FALSE;
}

=d2 split_name_into_array
Splits the multi part name into an array of names
Check that there are not too many parts;
Set the error message if there are too many names;
Return Array ref of names.
=cut

sub split_name_into_array : Private {
    my ($self, $name) = @_;
    $name =~ s/^\s+//;
    $name =~ s/\s+$//;
    my @array = split / /, $name;
    return \@array
        if ((@array) <= $MAX_NUM_OF_NAMES);
    $ERROR_MESSAGE = "Can only be $MAX_NUM_OF_NAMES names!";
    DEBUG "$name Failed the split_name_into_array test";
    $FALSE;
}

=d2 create_estimator_list
Get sorted list of all estimators
return Sorted array of estimator objects
=cut

sub create_estimator_list : Private {
    my ($self, $c) = @_;
    my $sort_by_1 = 'me.first_name';
    my $sort_by_2 = 'me.last_name';
    my $sort_by_3 = 'me.alias';
    my @estimator_objs =
        $c->model("DB::Employee")
        ->list_sales_department_order_by(
                               [ $sort_by_1, $sort_by_2, $sort_by_3 ])->all();

   # Create an array of arrayrefs where each arrayref is an estimator
   #    my @estimators =
   #     sort {    $a->first_name cmp $b->first_name
   #                      || $a->alias cmp $b->alias
   #                     || $a->last_name cmp $b->last_name } @estimator_objs;
   #
    return \@estimator_objs;
}

=d2 create_office_staff_list
Get a sorted list of office staff

return Sorted array of office staff objects
=cut

sub create_office_staff_list : Private {
    my ($self, $c) = @_;
    my $sort_by_1 = 'me.first_name';
    my $sort_by_2 = 'me.last_name';
    my $sort_by_3 = 'me.alias';
    my @staff_objs =
        $c->model("DB::Employee")
        ->list_office_staff_order_by([ $sort_by_1, $sort_by_2, $sort_by_3 ])
        ->all();

   # Create an array of arrayrefs where each arrayref is an estimator
   #    my @estimators =
   #     sort {    $a->first_name cmp $b->first_name
   #                      || $a->alias cmp $b->alias
   #                     || $a->last_name cmp $b->last_name } @estimator_objs;
    return \@staff_objs;
}

=d2 create_employee_list
Get a sorted list of employees
return Sorted array of employees
=cut

sub create_employee_list : Private {
    my ($self, $c) = @_;
    my $sort_by_1 = 'me.first_name';
    my $sort_by_2 = 'me.last_name';
    my $sort_by_3 = 'me.alias';
    my @employee_objs =
        $c->model("DB::Employee")
        ->list_employees_order_by([ $sort_by_1, $sort_by_2, $sort_by_3 ])
        ->all();
    return \@employee_objs;
}

=d2 create_employee_ids_names
Create a list of employee First/Last names with
Corresponding employee id.
Pass Array of employee objects
return an array of hashrefs {employee->id , employee->full_name}
=cut

sub create_employee_ids_names : Private {
    my ($self, $employees) = @_;
    my @employee_id_names;
    @employee_id_names = map { [ $_->id, $_->full_name ] } @{$employees};
    return \@employee_id_names;
}


=d2 is_date_valid   REPLACED BY IS_DATE_CURRENT IN MyDate.pm
We need a valid date
Only checks the date relative to current date
=cut

sub is_date_valid : Private {
    my ($self ,$input_date)  = @_;
    my @currentDate   = localtime();
    my $current_year  = ($currentDate[5] + 1900);
    my $current_month = ($currentDate[4] + 1);

    #----- Bad schedule date if before today
    my ($schedule_year, $schedule_month, $schedule_day) =
        (split '-', $input_date);
    DEBUG "Split date: $schedule_year,$schedule_month, $schedule_day. ";
    if (!$schedule_year || !$schedule_month || !$schedule_day) {
        $ERROR_MESSAGE = "Incorrect date format. Must be yyyy-mm-dd";
    }
    DEBUG
        "\nSplit date (schedule): $schedule_year : $schedule_month : $schedule_day exists. ";

    #------ Let this slide for now.
    #    return $FALSE if ($schedule_year < $current_year);
    #    return $FALSE
    #        if (   ($schedule_year eq $current_year)
    #            && ($schedule_month < $current_month));
    #    return $FALSE
    #        if (   ($schedule_year eq $current_year)
    #            && ($schedule_month eq $current_month)
    #            && ($schedule_day < $currentDate[3]));
    return $TRUE;
}

=d2 is_date_format_valid
We need a valid date
Only checks the date relative to current date
=cut

sub is_date_format_valid : Private {
    my ($self ,$input_date)  = @_;
use Regexp::Common qw(time);
    DEBUG '*** Inside is_date_format_valid with date : '. $input_date;
       
    

        if (defined $input_date){
             return $TRUE
              if( $input_date =~ m/^(\d\d\d\d-\d\d-\d\d).*T.*\d\d:\d\d:\d\d$/ );
             return $TRUE
              if( $input_date =~ m/^(\d\d\d\d-\d\d-\d\d).*$/ );
             return $TRUE
              if( $input_date =~ m/^(\d\d\d\d-\d\d-\d\d).*$/ );
             return $TRUE
              if( $input_date =~ m/^(\d\d-\d\d-\d\d\d\d).*$/ );
             return $TRUE
              if( $input_date =~ m/^(\d\d\d\d\/\d\d\/\d\d).*$/ );
             return $TRUE
              if( $input_date =~ m/^(\d\d\/\d\d\/\d\d\d\d).*$/ );
         
             DEBUG "*** Date did not match my Regex: $input_date";
             
            return $TRUE   
                if $input_date =~ $RE{time}{iso};
            return $TRUE   
                if $input_date =~ $RE{time}{mail};
            return $TRUE   
                if $input_date =~ $RE{time}{american};
            return $TRUE   
                if $input_date =~ $RE{time}{ymd};
            return $TRUE   
                if $input_date =~ $RE{time}{mdy};
            return $TRUE   
                if $input_date =~ $RE{time}{hms};
        }
   
    
      $ERROR_MESSAGE = "Requested date has unrecognized format : $input_date";
     DEBUG "*** Requested Date didnt match my Regex or lots of Regexp Common Time formats either: " . Dumper($input_date);
    return $FALSE;
    
}

###############################################################################

#-------------------------------------------------------------------------------
#    J Query stuff 
#-------------------------------------------------------------------------------

#
##
### ------ JQuery Employee Name Id Auto Complete
##
#

=head2 employee_full_name_auto_c_js
    Javascript to implement jQuery autocomplete
    for selecting employee full name in a form field
    pass $c
=cut
sub  employee_full_name_auto_c_js {
    my ($self, $c) = @_;
    DEBUG "The Autocomplete JS for employee is in $EMPLOYEE_FULL_NAME_AUTO_C_JS";
    my $js = $c->uri_for('/') . $EMPLOYEE_FULL_NAME_AUTO_C_JS;
    return <<END_JS;
    <script type="text/javascript" 
    src="$js">
    </script>
END_JS
}


#
##
### ------ JQuery Full Name Validation
##
#

=head2 full_name_form_valid_js
    Javascript to validate full name
    pass $c
=cut
sub  full_name_form_valid_js {
    my ($self, $c) = @_;
    my $js = $c->uri_for('/') . $FULL_NAME_FORM_VALIDATION_JS;
    return <<END_JS;
    <script type="text/javascript" 
    src="$js">
    </script>
END_JS
}

###############################################################################

=head1 AUTHOR

austin,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;
1;
