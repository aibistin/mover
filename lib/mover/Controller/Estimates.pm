package mover::Controller::Estimates;
use Moose;
use namespace::autoclean;
use Data::Dumper;
use Log::Log4perl qw(:easy);
use lib '/home/austin/perl/Validation';
use MyValid;
use MyDate;

#use HTML::FormFu::ExtJS;
BEGIN { extends 'Catalyst::Controller::HTML::FormFu'; }

#BEGIN { extends 'Catalyst::Controller'; }
#------
my $YES = my $TRUE  = 1;
my $NO  = my $FALSE = 0;
my $ESTIMATES_PATH          = 'Estimates/';
my $SCHEDULE_ESTIMATE       = 'schedule_estimate';
my $SCHEDULE_ESTIMATE_LABEL = 'Schedule A New Estimate';
my $UPDATE_ESTIMATE         = 'update_estimate';
my $DELETE_ESTIMATE         = 'delete_estimate';
my $DISPLAY_ESTIMATE        = 'display_estimate';          # 'display_estimate';
my $MAX_DAYS                = 366;
my $MAX_WEEKS               = 52;
my $MAX_MONTHS              = 12;
my $i                       = 1;
my %DAYS =
  map { ( $i++ => $_ ) }
  qw/monday tuesday wednesday thursday friday saturday sunday/;
$i = 1;
my %MONTHS =
  map { ( $i++ => $_ ) }
  qw/janurary feburary march april may june july august september october november december/;

#------ Java Script Locations
my $ESTIMATE_FORM_VALIDATION_JS =
  "static/jquery/js/jquery_estimates_form_valid.js";
my $PHONE_VALIDATION_JS    = "static/jquery/js/jquery_customer_phone_valid.js";
my $DATE_VALIDATION_JS     = "static/jquery/js/jquery_date_valid.js";
my $DATE_PICKER_JS         = "static/jquery/js/datepicker_ui_function.js";
my $CITY_STATE_ZIP_JS      = "static/jquery/js/local_cities.js";
my $CITY_STATE_ZIP_COPY_JS = "static/jquery/js/jquery_state_zip_copy.js";

#Log::Log4perl->easy_init($DEBUG);

=head1 NAME

mover::Controller::Estimates - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

=cut

sub index : Path : Args(0) {
    my ( $self, $c ) = @_;
    $c->response->body(
'Matched mover::Controller::Estimates in Estimates. Try a different location.'
    );
}

#------ Chained For Customer Estimate

=head2 base
    Can place common logic to start chained dispatch here for customer estimates
=cut

sub base : Chained('/') : PathPart('estimates') : CaptureArgs(0) {
    my ( $self, $c ) = @_;

# Store the ResultSet in stash so it's available for other methods
#   $c->stash(resultset => $c->model('DB::Customer')->related_resultset('estimates')
    $c->stash(
        resultset => $c->model('DB::Customer')->related_resultset('estimates')
    );
    DEBUG '*** INSIDE BASE estimates METHOD : Got first Estimate resultset ***';

    # Load status messages
    $c->load_status_msgs;
}

=head2 object
    Fetch the estimate_customer object based on its id and store it
    it in the stash
=cut

sub object : Chained('base') : PathPart('id') : CaptureArgs(1) {
    my ( $self, $c, $estimate_id ) = @_;
    DEBUG '*** Just INSIDE BASE object METHOD ***';
    DEBUG "*** The object id is: $estimate_id ***";

    #------ Find the estimate object and store it in the stash
    $c->stash->{object} = $c->stash->{resultset}->find($estimate_id);

  #    $c->stash->{resultset}->find({estimate.id => $estimate_id});
  #     DEBUG "*** The object for this id is: ***". Dumper $c->stash->{object} ;
  # Make sure the lookup was successful.  You would probably
  # want to do something like this in a real app:
    $c->detach('/error_404') if !$c->stash->{object};

    #
    #    die "Estimate $id not found!" if !$c->stash->{object};
    DEBUG( '*** Estimate Customer Object =  ***' . $c->stash->{object} );
}

#------ List Estimates Sorted by date

=d2 list
Fetch all estimate objecs and display some estimate details 
Sorted by estimate date
=cut

sub list : Chained('base') : PathPart('list') : Args(0) {
    my ( $self, $c ) = @_;

    #    $DB::single = 1;    # For Debug
    DEBUG "******  List estimates method ******";
    my $sort_by_1 = 'estimates.estimate_date';    # Timestamp
    my $sort_by_2 = 'estimates.estimate_time';    # string
    my $sort_by_3 = 'me.last_name';               # string
    $c->stash->{resultset} =
      $c->stash->{resultset}
      ->search( {}, { 'order_by' => [ $sort_by_1, $sort_by_2, $sort_by_3 ] }, );

    # Ensure user has permission to see this resultset
    $c->detach('/error_noperms')
      unless $c->stash->{resultset}->viewing_permission( $c->user->get_object );

    # Set the template
    $c->stash->{estimate_count} = $c->stash->{resultset}->count // 0;
    $c->stash->{found_msg} = $c->stash->{estimate_count} . " estimates found.";
    $c->stash->{template}  = 'Estimates/list.tt2';
}

#
##
####------ List Estimates By Estimator Id
##
#

=head2 
    List estimates
    Created by estimator ; by id
=cut

sub list_by_estimator_id : Chained('base') : PathPart('list_by_estimator_id')
  : Args(1) {
    my ( $self, $c, $estimator_id ) = @_;
    DEBUG "*** INSIDE list_by_estimator_id. Estimator id is: $estimator_id";

    #----- Get the estimates for this estimator
    $c->stash->{resultset} =
      $c->stash->{resultset}
      ->search( { 'estimates.estimator_id' => $estimator_id }, );

    # Ensure user has permission to see this resultset
    $c->detach('/error_noperms')
      unless $c->stash->{resultset}->viewing_permission( $c->user->get_object );

    # Set the template
    $c->stash->{estimate_count} = $c->stash->{resultset}->count // 0;
    $c->stash->{found_msg} = $c->stash->{estimate_count} . " estimates found.";
    $c->stash->{template}  = 'Estimates/list.tt2';
}

#
##
####------ List Estimates By Customer Last Name
##
#

=head2 list_by_last_name
    List estimates
    That have a customer last name like the entered name
=cut

sub list_by_last_name : Chained('base') : PathPart('list_by_last_name') :
  Args(1) {
    my ( $self, $c, $l_name ) = @_;
    DEBUG "*** INSIDE list_by_last_name. Last name is: $l_name";

    #----- Get the estimates for this shipper
    $c->stash->{resultset} =
      $c->stash->{resultset}
      ->search( { last_name => { 'like' => "%$l_name%" } },
        { join => 'estimator', } );

    # Ensure user has permission to see this resultset
    $c->detach('/error_noperms')
      unless $c->stash->{resultset}->viewing_permission( $c->user->get_object );

    # Set the template
    $c->stash->{estimate_count} = $c->stash->{resultset}->count // 0;
    $c->stash->{found_msg} = $c->stash->{estimate_count} . " estimates found.";
    $c->stash->{template}  = 'Estimates/list.tt2';
}

#
##
####------ List Estimates By Customer First Name
##
#

=head2 list_by_first_name
    List estimates
    That have a customer first name like the entered name
=cut

sub list_by_first_name : Chained('base') : PathPart('list_by_first_name') :
  Args(1) {
    my ( $self, $c, $f_name ) = @_;
    DEBUG "*** INSIDE list_by_first_name.  name is: $f_name";

    #----- Get the estimates for this shipper
    $c->stash->{resultset} =
      $c->stash->{resultset}
      ->search( { first_name => { 'like' => "%$f_name%" } },
        { join => 'estimator', } );

    # Ensure user has permission to see this resultset
    $c->detach('/error_noperms')
      unless $c->stash->{resultset}->viewing_permission( $c->user->get_object );

    # Set the template
    $c->stash->{estimate_count} = $c->stash->{resultset}->count // 0;
    $c->stash->{found_msg} = $c->stash->{estimate_count} . " estimates found.";
    $c->stash->{template}  = 'Estimates/list.tt2';
}

#
##
####------ List Estimates By Estimator First And Last Name
##
#

=head2 list_by_employee_name
    List estimates
    By Employees Matching Passed first and last names
=cut

sub list_by_employee_name : Chained('base') :
  PathPart('list_by_employee_name') : Args(1) {
    my ( $self, $c, $first_last_name ) = @_;
    DEBUG "*** INSIDE list_by_employee_name. Name is: $first_last_name";
    my @wanted_name = split( ' ', $first_last_name );

    #----- Get the estimates by this estimator
    $c->stash->{resultset} = $c->stash->{resultset}->search(
        -and => [
            'estimator.first_name' => lc( $wanted_name[0] ),
            'estimator.last_name'  => lc( $wanted_name[1] )
        ],
        { join => 'estimator' }
    );

    # Ensure user has permission to see this resultset.
    $c->detach('/error_noperms')
      unless $c->stash->{resultset}->viewing_permission( $c->user->get_object );

    # Set the template
    $c->stash->{estimate_count} = $c->stash->{resultset}->count // 0;
    $c->stash->{found_msg} = $c->stash->{estimate_count} . " estimates found.";
    $c->stash->{template}  = 'Estimates/list.tt2';
}

#
##
####------ List Estimates By Multiple Names
##
#

=head2 list_by_multiple_names
    List estimates
    That have a customer first or last  name like the entered names
    Pass an array ref of names
=cut

sub list_by_multiple_names : Chained('base') :
  PathPart('list_by_multiple_names') : Args(1) {
    my ( $self, $c, $names ) = @_;
    my @wanted_names = split( ' ', $names );

    # Ensure user has permission to see this resultset.
    $c->detach('/error_noperms')
      unless $c->stash->{object}->display_allowed_by( $c->user->get_object );
    DEBUG " Searching for names " . Dumper(@wanted_names);
    my (@like_names);
    for my $name (@wanted_names) {
        push @like_names, '%' . $name . '%';
    }

    #----- Get the estimate details for this shipper
    $c->stash->{resultset} = $c->stash->{resultset}->search(
        -or => [
            first_name => { 'like' => \@like_names },
            last_name  => { 'like' => \@like_names }
        ],
        { join => 'estimator' }
    );

    # Set the template
    $c->stash->{estimate_count} = $c->stash->{resultset}->count // 0;
    $c->stash->{found_msg} = $c->stash->{estimate_count} . " estimates found.";

    # Ensure user has permission to see this resultset.
    $c->detach('/error_noperms')
      unless $c->stash->{resultset}->viewing_permission( $c->user->get_object );
    $c->stash->{template} = 'Estimates/list.tt2';
}

#
##
####------ List Estimates For Today
##
#

=head2 list_for_today
    List estimates scheduled for Today 
 
=cut

sub list_for_today : Chained('base') : PathPart('list_for_today') : Args(0) {
    my ( $self, $c ) = @_;
    DEBUG "*** Inside list_for_today";
    my $today =
      DateTime->now( time_zone => 'local' )->set_time_zone('floating');
    $c->stash->{resultset} = $c->stash->{resultset}->scheduled_on_date($today);

    # Ensure user has permission to see this resultset.
    $c->detach('/error_noperms')
      unless $c->stash->{resultset}->viewing_permission( $c->user->get_object );
    $c->stash->{estimate_count} = $c->stash->{resultset}->count // 0;
    $c->stash->{found_msg} =
      $c->stash->{estimate_count} . " estimates found for today";

    #------ Set up the previous and next day links
    #
    $self->create_previous_next_day_tags( $c, $today );
    $c->stash->{'sub_heading'} =
      'Estimates scheduled for Today, ' . $today->day_name;
    $c->stash->{time_period} = $today->mdy('/');

    #------ Also adds JS validation and datepicker
    $self->add_multiple_date_miniforms_to_stash($c);

    #    $self->add_date_entry_miniform_to_stash($c);
    $c->stash->{template} = 'Estimates/daily_schedule.tt2';
}

#
##
####------ List Estimates For This Week
##
#

=head2 list_for_this_week
    List estimates scheduled for This Week 
=cut

sub list_for_this_week : Chained('base') : PathPart('list_for_this_week') :
  Args() {
    my ( $self, $c ) = @_;
    DEBUG "*** Inside list_for_this_week";
    my ($week) = 0;
    my ( $start_date, $end_date ) =
      MyDate->convert_relative_week_number_to_date_range( $week, $MAX_WEEKS );
    DEBUG ' This weeks start date is Monday '
      . $start_date->mdy('/') . ' to '
      . $end_date->mdy('/');
    $c->stash->{resultset} =
      $c->stash->{resultset}->scheduled_between_dates( $start_date, $end_date );

    # Ensure user has permission to see this resultset.
    $c->detach('/error_noperms')
      unless $c->stash->{resultset}->viewing_permission( $c->user->get_object );
    $c->stash->{'sub_heading'} =
        'Estimates scheduled for this week starting on Monday  '
      . $start_date->mdy('/')
      . ' to Sunday '
      . $end_date->mdy('/');
    $c->stash->{estimate_count} = $c->stash->{resultset}->count // 0;
    $c->stash->{found_msg} =
      $c->stash->{estimate_count} . " estimates found for this week";

    #------ previous week is this week '-1'. The next week is '+1'
    my ( $prev, $next ) =
      MyDate->move_move_back_or_forward_by_time_period( $week, $MAX_WEEKS );
    DEBUG "Requested week is $week and previous week is $prev ";
    DEBUG "Next week is $next";
    $c->stash->{'prev'} =
      $c->uri_for( $self->action_for('list_by_week'), $prev );
    $c->stash->{'prev_label'} = "Previous Week";
    $c->stash->{'next'} =
      $c->uri_for( $self->action_for('list_by_week'), $next );
    $c->stash->{'next_label'} = "Next Week";
    $c->stash->{estimate_count} = $c->stash->{resultset}->count // 0;
    $c->stash->{found_msg} =
      $c->stash->{estimate_count} . " estimates found for this week";

    #------ Also adds JS validation and datepicker
    $self->add_multiple_date_miniforms_to_stash($c);

    $c->stash->{template} = 'Estimates/list.tt2';
}

#
##
####------ List Estimates For This Month
##
#

=head2 list_for_this_month
    List estimates scheduled for This Month 
=cut

sub list_for_this_month : Chained('base') : PathPart('list_for_this_month') :
  Args() {
    my ( $self, $c ) = @_;
    DEBUG "*** Inside list_for_this_month";
    my $current_month = DateTime->now->month;
    my ( $start_date, $end_date ) =
      MyDate->convert_month_number_to_start_end_date(0);
    if ( ( not defined $start_date ) || ( not defined $end_date ) ) {
        DEBUG "*** Invalid month picked ";
        $c->detach('/error_other');
    }
    DEBUG ' The month start date  '
      . $start_date->mdy('/') . ' to '
      . $end_date->mdy('/');
    $c->stash->{resultset} =
      $c->stash->{resultset}->scheduled_between_dates( $start_date, $end_date );

    # Ensure user has permission to see this resultset.
    $c->detach('/error_noperms')
      unless $c->stash->{resultset}->viewing_permission( $c->user->get_object );

    #------ previous month is this month '-1'. The next month is '+1'
    $c->stash->{estimate_count} = $c->stash->{resultset}->count // 0;
    $c->stash->{found_msg} =
        $c->stash->{estimate_count}
      . " estimates found for "
      . $start_date->month_name;

    #------ Set up the previous and next month links
    #       can only go from months 1 to 12 in the current year
    my $prev = ( $start_date->month > 1 )  ? ( $start_date->month - 1 ) : undef;
    my $next = ( $start_date->month < 12 ) ? ( $start_date->month + 1 ) : undef;
    DEBUG "Requested month is $current_month and previous month is $prev ";
    DEBUG "Next month is $next";
    if ( defined $prev ) {
        $c->stash->{'prev'} =
          $c->uri_for( $self->action_for('list_by_month'), $prev );
        $c->stash->{'prev_label'} = "Previous Month";
    }
    if ( defined $next ) {
        $c->stash->{'next'} =
          $c->uri_for( $self->action_for('list_by_month'), $next );
        $c->stash->{'next_label'} = "Next Month";
    }
    $c->stash->{'sub_heading'} =
      'Estimates scheduled for the month of ' . $start_date->month_name;
    $c->stash->{time_period} =
      $start_date->mdy('/') . ' to ' . $end_date->mdy('/');

    #------ Also adds JS validation and datepicker
    $self->add_multiple_date_miniforms_to_stash($c);

    $c->stash->{template} = 'Estimates/list.tt2';
}

#
##
####------ List Estimates For One day This week
##
#

=head2 list_by_day_of_week_post
    List estimates scheduled for a specific day 
    in this current week
    Monday = 1.............. Sunday = 7
    Convert the day number to an actual date
    Information is passed via POST Body Param
=cut

sub list_by_day_of_week_post : Chained('base') :
  PathPart('list_by_day_of_week') : Args(0) {
    my ( $self, $c, $day ) = @_;
    my ( $err, $date_time ) = undef;
    DEBUG "*** Inside list_by_day_of_week. Requested day is: $day";
    $date_time = $self->validate_day_of_week_miniform($c);
    if ( defined $date_time ) {

        #------ Get the Info
        $c->stash->{resultset} =
          $c->stash->{resultset}->scheduled_on_date($date_time);

        # Ensure user has permission to see this resultset.
        $c->detach('/error_noperms')
          unless $c->stash->{resultset}
          ->viewing_permission( $c->user->get_object );
        $c->stash->{estimate_count} = $c->stash->{resultset}->count // 0;
        $c->stash->{found_msg} =
            $c->stash->{estimate_count}
          . " estimates found for "
          . $date_time->day_name;

        #------ Set up the previous and next day links
        #
        $self->create_previous_next_day_tags( $c, $date_time );
        $c->stash->{'sub_heading'} =
          'Estimates scheduled for ' . $date_time->day_name;
        $c->stash->{time_period} = $date_time->mdy('/');
    }
    else {

        #------ No form or invalid form submitted
        $c->stash->{resultset} = $c->stash->{estimate_count} = undef;
        $c->stash->{'sub_heading'} =
          "See scheduled estimates for your selected day.";
    }

    #------ Add little Date Selector Form To Top
    #       Also adds JS validation and datepicker
    $self->add_multiple_date_miniforms_to_stash($c);
    $c->stash->{template} = 'Estimates/daily_schedule.tt2';
}

=head2 list_by_day_of_week
    List estimates scheduled for a specific day 
    in this current week
    Monday = 1.............. Sunday = 7
    Convert the day number to an actual date
    
=cut

sub list_by_day_of_week : Chained('base') : PathPart('list_by_day_of_week') :
  Args(1) {
    my ( $self, $c, $day ) = @_;
    my $err = undef;
    DEBUG "*** Inside list_by_day_of_week. Requested day is: $day";
    if ( MyValid->is_it_numeric($day) && MyValid->is_it_between( $day, 1, 7 ) )
    {
        MyValid->is_it_between( $day, 1, 7 );
    }
    $day = MyValid->is_it_numeric($day) || ( $err = $TRUE );
    ( MyValid->is_it_between( $day, 1, 7 ) || ( $err = $TRUE ) )
      if ( defined $day );
    my $req_date = MyDate->convert_week_day_number_to_date($day)
      if ( $err == $FALSE );
    if ( ( not defined $req_date ) || ( $err == $TRUE ) ) {
        DEBUG "*** Invalid day picked ";
        $c->stash->{error_msg_1} = "Invalid day picked!";
        $c->detach('/error_other');
    }

    #------ Get the Info
    $c->stash->{resultset} =
      $c->stash->{resultset}->scheduled_on_date($req_date);

    # Ensure user has permission to see this resultset.
    $c->detach('/error_noperms')
      unless $c->stash->{resultset}->viewing_permission( $c->user->get_object );
    $c->stash->{estimate_count} = $c->stash->{resultset}->count // 0;
    $c->stash->{found_msg} =
        $c->stash->{estimate_count}
      . " estimates found for "
      . $req_date->day_name;

    #------ Add little Date Selector Form To Top
    #       Also adds JS validation and datepicker
    $self->add_multiple_date_miniforms_to_stash($c);

    #------ Set up the previous and next day links
    #
    $self->create_previous_next_day_tags( $c, $req_date );
    $c->stash->{'sub_heading'} =
      'Estimates scheduled for ' . $req_date->day_name;
    $c->stash->{time_period} = $req_date->mdy('/');

    #------ Also adds JS validation and datepicker
    $self->add_multiple_date_miniforms_to_stash($c);

    $c->stash->{template} = 'Estimates/daily_schedule.tt2';
}

#
##
####------ List Estimates For One Week
##
#

=head2 list_by_week
    List estimates scheduled for a specific week 
    0 is the current week
    -1 is last week +1 is next week.
    Maximum is 52 weks in either direction
    Convert the week number to an actual start and end date
    
=cut

sub list_by_week : Chained('base') : PathPart('list_by_week') : Args(1) {
    my ( $self, $c, $week ) = @_;
    DEBUG
"*** Inside list_by_week. Requested week is $week weeks before or after now";
    my ( $start_date, $end_date ) =
      MyDate->convert_relative_week_number_to_date_range( $week, $MAX_WEEKS );
    if ( ( not defined $start_date ) || ( not defined $end_date ) ) {
        DEBUG "*** Invalid week picked ";
        $c->detach('/error_other');
    }
    DEBUG ' The week start date is Monday '
      . $start_date->mdy('/') . ' to '
      . $end_date->mdy('/');
    $c->stash->{resultset} =
      $c->stash->{resultset}->scheduled_between_dates( $start_date, $end_date );

    # Ensure user has permission to see this resultset.
    $c->detach('/error_noperms')
      unless $c->stash->{resultset}->viewing_permission( $c->user->get_object );
    $c->stash->{'sub_heading'} =
      'Estimates scheduled for the week starting on Monday';
    $c->stash->{time_period} =
      $start_date->mdy('/') . ' to Sunday ' . $end_date->mdy('/');
    $c->stash->{estimate_count} = $c->stash->{resultset}->count // 0;
    $c->stash->{found_msg} =
      $c->stash->{estimate_count} . " estimates found for the week";

    #------ previous week is this week '-1'. The next week is '+1'
    my ( $prev, $next ) =
      MyDate->move_move_back_or_forward_by_time_period( $week, $MAX_WEEKS );
    DEBUG "Requested week is $week and previous week is $prev ";
    DEBUG "Next week is $next";
    $c->stash->{'prev'} =
      $c->uri_for( $self->action_for('list_by_week'), $prev );
    $c->stash->{'prev_label'} = "Previous Week";
    $c->stash->{'next'} =
      $c->uri_for( $self->action_for('list_by_week'), $next );
    $c->stash->{'next_label'} = "Next Week";
    $c->stash->{estimate_count} = $c->stash->{resultset}->count // 0;
    $c->stash->{found_msg} =
      $c->stash->{estimate_count} . " estimates found for the week";

    #------ Also adds JS validation and datepicker
    $self->add_multiple_date_miniforms_to_stash($c);

    $c->stash->{template} = 'Estimates/list.tt2';
}

#
##
####------ List Estimates For One Month
##
#

=head2 list_by_month_post
    List estimates scheduled for a specific month 
    1 = Janurary to 12 = December of this current year
    Convert the month number to an actual start and end date
    (First of month to Last date of month)
    Uses POST Body parameter
=cut

sub list_by_month_post : Chained('base') : PathPart('list_by_month') : Args(0) {
    my ( $self, $c ) = @_;
    DEBUG "*** Inside list_by_month.";
    my ( $start_date, $end_date ) = $self->validate_month_of_year_miniform($c);
    if ( ( defined $start_date ) && ( defined $end_date ) ) {
        DEBUG ' The month start date  '
          . $start_date->mdy('/') . ' to '
          . $end_date->mdy('/');
        $c->stash->{resultset} =
          $c->stash->{resultset}
          ->scheduled_between_dates( $start_date, $end_date );

        # Ensure user has permission to see this resultset.
        $c->detach('/error_noperms')
          unless $c->stash->{resultset}
          ->viewing_permission( $c->user->get_object );

        #------ previous month is this month '-1'. The next month is '+1'
        my $current_month = DateTime->now->month;
        $c->stash->{estimate_count} = $c->stash->{resultset}->count // 0;
        $c->stash->{found_msg} =
            $c->stash->{estimate_count}
          . " estimates found for "
          . $start_date->month_name;

        #------ Set up the previous and next month links
        #       can only go from months 1 to 12 in the current year
        my $prev =
          ( $start_date->month > 1 ) ? ( $start_date->month - 1 ) : undef;
        my $next =
          ( $start_date->month < 12 ) ? ( $start_date->month + 1 ) : undef;
        DEBUG 'Requested month is '
          . $c->form->valid('month_of_year')
          . " and previous month is $prev ";
        DEBUG "Next month is $next";
        if ( defined $prev ) {
            $c->stash->{'prev'} =
              $c->uri_for( $self->action_for('list_by_month'), $prev );
            $c->stash->{'prev_label'} = "Previous Month";
        }
        if ( defined $next ) {
            $c->stash->{'next'} =
              $c->uri_for( $self->action_for('list_by_month'), $next );
            $c->stash->{'next_label'} = "Next Month";
        }
        $c->stash->{'sub_heading'} =
          'Estimates scheduled for the month of ' . $start_date->month_name;
        $c->stash->{time_period} =
          $start_date->mdy('/') . ' to ' . $end_date->mdy('/');
    }
    else {

        #------ No Mini Form or Invalid Miniform
        $c->stash->{'sub_heading'} =
          "See scheduled estimates for your selected month.";
    }

    #------ Add little Date Selector Form To Top
    #       Also adds JS validation and datepicker
    $self->add_multiple_date_miniforms_to_stash($c);

    $c->stash->{template} = 'Estimates/list.tt2';
}

=head2 list_by_month
    List estimates scheduled for a specific month 
    1 = Janurary to 12 = December of this current year
    Convert the month number to an actual start and end date
    (First of month to Last date of month)

=cut

sub list_by_month : Chained('base') : PathPart('list_by_month') : Args(1) {
    my ( $self, $c, $month ) = @_;
    DEBUG "*** Inside list_by_month. Requested month number is $month";
    my ( $start_date, $end_date ) =
      MyDate->convert_month_number_to_start_end_date($month);
    if ( ( not defined $start_date ) || ( not defined $end_date ) ) {
        DEBUG "*** Invalid month picked ";
        $c->detach('/error_other');
    }
    DEBUG ' The month start date  '
      . $start_date->mdy('/') . ' to '
      . $end_date->mdy('/');
    $c->stash->{resultset} =
      $c->stash->{resultset}->scheduled_between_dates( $start_date, $end_date );

    # Ensure user has permission to see this resultset.
    $c->detach('/error_noperms')
      unless $c->stash->{resultset}->viewing_permission( $c->user->get_object );

    #------ previous month is this month '-1'. The next month is '+1'
    my $current_month = DateTime->now->month;
    $c->stash->{estimate_count} = $c->stash->{resultset}->count // 0;
    $c->stash->{found_msg} =
        $c->stash->{estimate_count}
      . " estimates found for "
      . $start_date->month_name;

    #------ Set up the previous and next month links
    #       can only go from months 1 to 12 in the current year
    my $prev = ( $start_date->month > 1 )  ? ( $start_date->month - 1 ) : undef;
    my $next = ( $start_date->month < 12 ) ? ( $start_date->month + 1 ) : undef;
    DEBUG "Requested month is $month and previous month is $prev ";
    DEBUG "Next month is $next";
    if ( defined $prev ) {
        $c->stash->{'prev'} =
          $c->uri_for( $self->action_for('list_by_month'), $prev );
        $c->stash->{'prev_label'} = "Previous Month";
    }
    if ( defined $next ) {
        $c->stash->{'next'} =
          $c->uri_for( $self->action_for('list_by_month'), $next );
        $c->stash->{'next_label'} = "Next Month";
    }

    #------ Also adds JS validation and datepicker
    $self->add_multiple_date_miniforms_to_stash($c);

    $c->stash->{'sub_heading'} =
      'Estimates scheduled for the month of ' . $start_date->month_name;
    $c->stash->{time_period} =
      $start_date->mdy('/') . ' to ' . $end_date->mdy('/');
    $c->stash->{template} = 'Estimates/list.tt2';
}

#
##
####------ List Estimates Scheduled for a particular date (Post)
####       And Get versions
##
#

=head2 list_by_date_post
    List estimates scheduled for a specific date
    Using Post
    Passed a date string ymd or ISO 8061
=cut

sub list_by_date_post : Chained('base') : PathPart('list_by_date') : Args(0) {
    my ( $self, $c ) = @_;
    my ( $req_date, $date_time );
    DEBUG "*** Inside list_by_date_post.";

    #------ FormValidator checks if there was a form sent
    $date_time = $self->validate_one_date_miniform($c)
      if $c->request->param('submit_date');
    if ( defined $date_time ) {

        #------ Get estimates for this date
        $c->stash->{resultset} =
          $c->stash->{resultset}->scheduled_on_date($date_time);

        # Ensure user has permission to see this resultset.
        $c->detach('/error_noperms')
          unless $c->stash->{resultset}
          ->viewing_permission( $c->user->get_object );
        $c->stash->{estimate_count} = $c->stash->{resultset}->count // 0;
        $c->stash->{found_msg} =
            ( $c->stash->{estimate_count} // 0 )
          . ' estimate'
          . ( $c->stash->{estimate_count} != 1 ? 's' : '' )
          . ' found for '
          . $date_time->mdy('/');
        $self->create_previous_next_day_tags( $c, $date_time );
        $c->stash->{'sub_heading'} =
          'Estimates scheduled for ' . $date_time->day_name;

        #------ For Display
        $c->stash->{time_period} =
            $date_time->month_name . ' '
          . $date_time->day . ', '
          . $date_time->year;
    }
    else {

        #------ No Mini Form or Invalid Miniform
        $c->stash->{'sub_heading'} =
          "See scheduled estimates for your selected date.";
        $c->stash->{resultset} = undef;

   #------ Ensure One Date Entry Form Tab Is Opened (Bootstrap active attribute)
        $c->stash->{'tab_class_od'}       = 'class="active"';
        $c->stash->{'tab_active_flag_od'} = 'active';
    }

    #------ Add little Date Selector Form To Top
    #       Also adds JS validation and datepicker
    $self->add_multiple_date_miniforms_to_stash($c);
    $c->stash->{template} = 'Estimates/daily_schedule.tt2';
}

=head2 list_by_date
    List estimates scheduled for a specific date
    Passed a date string yyyy-mm-dd or ISO 8061
=cut

sub list_by_date : Chained('base') : PathPart('list_by_date') : Args(1) {
    my ( $self, $c, $req_date ) = @_;
    DEBUG '*** Inside list_by_date.***' . $req_date;
    DEBUG '*** Inside list_by_date.Request Args Are ***'
      . Dumper( $c->req->args );
    my ($date_time);
    if ( not defined $req_date ) {
        DEBUG "*** Undefined Request Date ";
        $c->stash->{error_msg_1} = "No Date Requested.";
        $c->detach('/error_other');
    }

    #------ Format the Date string into DateTime object
    $date_time = $self->get_date_time_my_way( $c, $req_date )
      if ( not defined $date_time );
    if ( not defined $date_time ) {
        DEBUG "*** Requested Date Could not be converted to DateTime format: "
          . Dumper($req_date);
        $c->stash->{error_msg_1} = "Invalid Date Format.";
        $c->detach('/error_other');
    }
    $c->stash->{resultset} =
      $c->stash->{resultset}->scheduled_on_date($date_time);

    # Ensure user has permission to see this resultset.
    $c->detach('/error_noperms')
      unless $c->stash->{resultset}->viewing_permission( $c->user->get_object );
    $c->stash->{estimate_count} = $c->stash->{resultset}->count // 0;
    $c->stash->{found_msg} =
        $c->stash->{estimate_count}
      . " estimates found for "
      . $date_time->mdy('/');

    #------ Add little Date Selector Form To Top
    #       Also adds JS validation and datepicker
    #    $self->add_date_entry_miniform_to_stash($c);
    $self->add_multiple_date_miniforms_to_stash($c);

    #------ Set up the previous and next day links
    #
    $self->create_previous_next_day_tags( $c, $date_time );
    $c->stash->{'sub_heading'} =
      'Estimates scheduled for ' . $date_time->day_name;
    $c->stash->{time_period} =
      $date_time->month_name . ' ' . $date_time->day . ', ' . $date_time->year;
    $c->stash->{template} = 'Estimates/daily_schedule.tt2';
}

#
##
####------ List Estimates Scheduled Between Dates 'Post'
####       And 'Get' Subroutines
##
#

=head2 list_date_range
    List estimates scheduled between specific dates
    Using Post
    Passed 2 date strings ymd or ISO 8061
=cut

sub list_date_range : Chained('base') : PathPart('list_date_range') : Args(0) {
    my ( $self, $c ) = @_;
    my ( $date_time_start, $date_time_end );

    DEBUG "**** Inside list_date_range Request Data.";

    #------ If processing date range miniform -- Validate it
    ( $date_time_start, $date_time_end ) =
      $self->validate_date_range_miniform($c)
      if ( exists $c->request->params->{submit_range} );
    if ( ( defined $date_time_start ) && ( defined $date_time_end ) ) {

        #------ Get estimates for this date
        $c->stash->{resultset} =
          $c->stash->{resultset}
          ->scheduled_between_dates( $date_time_start, $date_time_end );

#------ Ensure user has permission to see this resultset. and create page headings
        $c->detach('/error_noperms')
          unless $c->stash->{resultset}
          ->viewing_permission( $c->user->get_object );
        $c->stash->{estimate_count} = $c->stash->{resultset}->count // 0;
        DEBUG '*** Found '
          . $c->stash->{estimate_count}
          . ' estimates for time period.';
        $c->stash->{found_msg} =
            ( $c->stash->{estimate_count} // 0 )
          . ' estimate'
          . ( $c->stash->{estimate_count} != 1 ? 's' : '' )
          . ' found for '
          . $date_time_start->mdy('/') . ' to '
          . $date_time_end->mdy('/');
        $c->stash->{'sub_heading'} =
            'Estimates scheduled for '
          . $date_time_start->day_name . ' to '
          . $date_time_end->day_name;

        #------ For Display
        $c->stash->{time_period} =
            $date_time_start->month_name . ' '
          . $date_time_start->day . ', '
          . $date_time_start->year . ' to '
          . $date_time_end->month_name . ' '
          . $date_time_end->day . ', '
          . $date_time_end->year;
    }
    else {

        #------ No Miniform or Invalid Miniform
        $c->stash->{'sub_heading'} =
          "See scheduled estimates for your selected date range.";
        $c->stash->{resultset} = undef;

       #------ Ensure Date Range Form Tab Is Opened (Bootstrap active attribute)
        $c->stash->{'tab_class_dr'}       = 'class="active"';
        $c->stash->{'tab_active_flag_dr'} = 'active';
    }

    #------ Add little Date Selector Form To Top
    #       Also adds JS validation and datepicker
    $self->add_multiple_date_miniforms_to_stash($c);
    $c->stash->{template} = 'Estimates/list.tt2';
}

=head2 list_date_range
    List estimates scheduled between specific dates
    If only a starting date is given, then it lists all 
    scheduled estimates after that start date
    Passed 2 date strings ymd or ISO 8061
=cut

sub list_date_range_bkp : Chained('base') : PathPart('list_date_range_bkp') :
  Args(2) {
    my ( $self, $c, $start_date, $end_date ) = @_;
    DEBUG '*** Inside list_date_range.***' . Dumper($start_date);

    #------ Format the Date string into DateTime object
    if ( ( not defined $start_date ) or ( not defined $end_date ) ) {
        DEBUG "*** Undefined Start Date or undefined End Date ";
        $c->stash->{error_msg_1} = "Missing a start or an end date.";
        $c->detach('/error_other');
    }
    my $start_date_time =
      MyDate->create_date_time_ymd($start_date);    #try ymd string first

    #    $start_date_time = MyDate->create_date_time_ISO8601($start_date)
    #        if not defined $start_date_time;
    if ( not defined $start_date_time ) {
        DEBUG "*** Start date is not in recognised string format "
          . Dumper($start_date);
        $c->stash->{error_msg_1} =
          "Invalid Date Format for the start date, $start_date";
        $c->detach('/error_other');
    }
    my $end_date_time =
      MyDate->create_date_time_ymd($end_date);    #try ymd string first

    #    $end_date_time = MyDate->create_date_time_ISO8601($end_date)
    #        if not defined $end_date_time;
    if ( not defined $end_date_time ) {
        DEBUG "*** End date is not in recognised string date format"
          . Dumper($end_date);
        $c->stash->{error_msg_1} =
          "Invalid Date Format for the end date, $end_date";
        $c->detach('/error_other');
    }
    $c->stash->{resultset} =
      $c->stash->{resultset}
      ->scheduled_between_dates( $start_date_time, $end_date_time );

    # Ensure user has permission to see this resultset.
    $c->detach('/error_noperms')
      unless $c->stash->{resultset}->viewing_permission( $c->user->get_object );
    $c->stash->{estimate_count} = $c->stash->{resultset}->count // 0;
    $c->stash->{found_msg} =
        $c->stash->{estimate_count}
      . " estimates found for days between "
      . $start_date_time->mdy('/') . ' and '
      . $end_date_time->mdy('/');

    #------ Add little Date Selector Form To Top
    #    $self->add_date_range_miniform_to_stash($c);
    $self->add_multiple_date_miniforms_to_stash($c);

#     DEBUG "Including the miniform ". $c->stash->{mini_form};
#------ Add js to bottom template  (jQ Datepicker And Date Validation to JS array)
#      $c->stash(
#        bottom_js        => 'js/bottom_js.tt2',
#        js_array      => [ $self->datepicker_activation_js($c),
#                              $self->date_validation_js($c) ],
#        );
    $c->stash->{'sub_heading'} =
      'Estimates scheduled between ' . $start_date->month_name;
    $c->stash->{time_period} =
        $start_date_time->month_name . ' '
      . $start_date_time->day . ', '
      . $start_date_time->year . ' to '
      . $end_date_time->month_name . ' '
      . $end_date_time->day . ', '
      . $end_date_time->year;
    $c->stash->{template} = 'Estimates/daily_schedule.tt2';
}
###############################################################################
#------ Estimate Details
###############################################################################
#
##
####------ Estimate Details
##
#

=head2 display_estimate_details
    One page estimate detail display
=cut

sub display_estimate_details : Chained('object') :
  PathPart('display_estimate_details') : Args(0) {
    my ( $self, $c ) = @_;
    DEBUG "*** INSIDE display_estimate_details." . $c->stash->{object}->id;

    # Ensure user has permission to see this resultset.
    $c->detach('/error_noperms')
      unless $c->stash->{object}->display_allowed_by( $c->user->get_object );

    #------ Print Updated By/Date only if it has been updated
    $c->stash->{updated} = DateTime->compare( $c->stash->{object}->created,
        $c->stash->{object}->updated );

    DEBUG '*** The Created date is .' . Dumper ($c->stash->{object}->created);
    DEBUG '*** The Updated  date is .' . Dumper ($c->stash->{object}->updated);
    
    $c->stash->{template} = 'Estimates/display_estimate_details.tt2';
}

#---- Create an estimate using passed args
sub url_create : Chained('base') : PathPart('url_create') : Args(3) {
    my ( $self, $c, $estimate_id, $cust_last_name, $cust_addr_1, $estimator_id )
      = @_;
    my ($estimate);

    # Does the user have permission to view this estimate.
    $c->detach('/error_noperms')
      unless $c->stash->{object}->create_allowed_by( $c->user->get_object );
    $estimate = $c->model('DB::Estimate')->create(
        {
            id        => $estimate_id,
            last_name => $cust_last_name,
            address_1 => $cust_addr_1,
        }
    );

    # Join table
    $estimate->add_to_estimate_estimators(
        {
            estimate_id  => $estimate_id,
            estimator_id => $estimator_id,
        }
    );

    #------ Assign the Estimate object to the stash for display and set template
    $c->stash(
        new_estimate => $estimate,
        template     => 'Estimates/create_est.tmpl',
        return_url   => $c->uri_for('/estimates/list')
    );
    $self->create_estimate_entry( $c, $estimate );

    #----- Disable caching for this page
    $c->response->header( 'Cache-Control' => 'no-cache' );
}

=head2 list_recent
    View estimates created after a specific number of 
    minutes.
=cut

sub list_recent : Chained('base') : PathPart('list_recent') : Args(1) {
    my ( $self, $c, $mins ) = @_;
    $c->stash( template => 'Estimates/estimates.tmpl' );

# Retrieve all of the estimate records as estimate model objects and store in the
# stash where they can be accessed by the template, but only
# the estimates created after the specified number of minutes.

    # Does the user have permission to view this estimate.
    $c->detach('/error_noperms')
      unless $c->stash->{object}->create_allowed_by( $c->user->get_object );
    my @estimates =
      $c->model('DB::Estimate')
      ->created_after( DateTime::Tiny->now->subtract( minutes => $mins ),
        $YES );
    $c->log->debug(
        '*** INSIDE list_recent METHOD  recent is ' . $mins . ' mins***' );
    $c->stash->{ALL_ESTS} = $self->create_template_rows( $c, \@estimates );

}

=head2 list_recent_name
    List recently created estimates
    That have a customer last name like the entered name
=cut

#------ LIST RECENT SCHEDULED ESTIMATES FOR PARTICULAR NAME
sub list_recent_name : Chained('base') : PathPart('list_recent_name') :
  Args(2) {
    my ( $self, $c, $mins, $l_name ) = @_;

# Retrieve all of the estimate records as estimate model objects and store in the
# stash where they can be accessed
# retrieve estimates created within the last $min number of minutes
# AND that have a last name of  $l_name in

    # Does the user have permission to view this estimate.
    $c->detach('/error_noperms')
      unless $c->stash->{object}->create_allowed_by( $c->user->get_object );

    $c->stash( template => 'Estimates/estimates.tmpl' );
    $c->log->debug(
        '*** INSIDE list_recent_name recent is ' . $mins . ' mins***' );

    #    $c->log->debug( '*** Loking for last name like  ' . $l_name );
    my @estimates =
      $c->model('DB::Estimate')
      ->created_after( DateTime::Tiny->now->subtract( minutes => $mins ), $YES )
      ->last_name_like($l_name);
    my $tmpl_arr = $self->create_template_rows( $c, \@estimates );
    $c->stash->{ALL_ESTS} = $tmpl_arr;
}

=head2 list_one_day_old
    List estimates scheduled for a specific day
=cut

#----- LIST ESTIMATES SCHEDULED OR COMPLETED FOR SPECIFIED DAY
sub list_one_day_old : Chained('base') : PathPart('list_one_day') : Args(1) {
    my ( $self, $c, $date ) = @_;

    # Does the user have permission to view this estimate.
    $c->detach('/error_noperms')
      unless $c->stash->{object}->create_allowed_by( $c->user->get_object );

    $c->stash( template => 'Estimates/estimates.tmpl' );

    #------ yyyy-mm-dd  ... 1998-04-07
    my ( $yyyy, $mm, $dd ) = split( '-', $date );
    my $dt = DateTime::Tiny->new(
        year  => $yyyy,
        month => $mm,
        day   => $dd,
    );
    my @estimates = $c->model('DB::Estimate')->on_date( $dt, $c, $YES );
    $c->log->debug(
        '*** INSIDE list_one_day METHOD  list_one_day ' . $date . ' day ***' );
    $c->stash->{ALL_ESTS} = $self->create_template_rows( $c, \@estimates );
}

#------ LIST ESTIMATES FOR ONE DAY FOR SPECIFIC NAME

=head2 list_one_day_name
    List recently created estimates
    That have a customer last name like the entered name
=cut

#------ LIST ESTIMATES FOR ONE DAY FOR PARTICULAR NAME
sub list_one_day_name : Chained('base') : PathPart('list_one_day_name') :
  Args(2) {
    my ( $self, $c, $mins, $l_name ) = @_;

    # Does the user have permission to view this estimate.
    $c->detach('/error_noperms')
      unless $c->stash->{object}->create_allowed_by( $c->user->get_object );

    # retrieve estimates created within the last $min number of minutes
    # AND that have a last name of  $l_name in
    $c->stash( template => 'Estimates/estimates.tmpl' );
    $c->log->debug(
        '*** INSIDE list_recent_name recent is ' . $mins . ' mins***' );

    #    $c->log->debug( '*** Loking for last name like  ' . $l_name );
    my @estimates =
      $c->model('DB::Estimate')
      ->created_after( DateTime::Tiny->now->subtract( minutes => $mins ), $YES )
      ->last_name_like($l_name);
    my $tmpl_arr = $self->create_template_rows( $c, \@estimates );
    $c->stash->{ALL_ESTS} = $tmpl_arr;

    #    $c->forward( $c->view('HTML::Template') );
}


#-------------------------------------------------------------------------------
#  Delete
#  Delete an estimate.
#-------------------------------------------------------------------------------
=head2 delete
    Delete an estimate
=cut
sub delete : Chained('object') : PathPart('delete') : Args(0) {
    my ( $self, $c ) = @_;
    $c->log->debug( '*** INSIDE delete . User is ' . $c->user->id . ' ***' );

    # Ensure the user has permission to delete estimates
#    $c->detach('/error_noperms')
#      unless $c->stash->{object}->delete_allowed_by( $c->user->get_object );

# Uses  'Catalyst::Plugin::Authorization::Roles' to ensure this user 
# has permission to Delete an estimate
    $c->detach('/error_noperms')
          unless $c->check_user_roles('can_delete_estimate');

    # Saved the PK id for status_msg below
    my $id = $c->stash->{object}->id;

    # Use the estimate object saved by 'object' and delete it along
    # with related 'estimateEstimators' entries
    $c->stash->{object}->delete;
    $c->log->debug( '*** INSIDE delete . Id to delete is ' . $id . ' ***' );

    # Redirect the user back to the list page
    $c->response->redirect(
        $c->uri_for(
            $self->action_for('list'),
            { mid => $c->set_status_msg("Deleted estimate $id") }
        )
    );
}

#
##
###------ Forms
##
#

=head2 formfu_create
    Use HTML::FormFu to create a new estimate
=cut

#------ CREATE AN ESTIMATE
sub schedule_estimate : Chained('base') : PathPart('schedule_estimate' ) :
  Args(0) : FormConfig('estimates/schedule_estimate.yml') {
    my ( $self, $c ) = @_;
    $c->log->debug("*** INSIDE $SCHEDULE_ESTIMATE ***");

    # Does the user have permission to create estimates
#    $c->detach('/error_noperms')
#      unless $c->model('DB::Estimate')->create_allowed_by( $c->user );

# Uses  'Catalyst::Plugin::Authorization::Roles' to ensure this user 
# has permission to Schedule an estimate
    $c->detach('/error_noperms')
          unless $c->check_user_roles('can_create_estimate');

    # Get the form that the :FormConfig attribute saved in the stash
    my $form = $c->stash->{form};

    # is shorthand for "$form->submitted && !$form->has_errors"
    if ( $form->submitted_and_valid ) {
        my ( $customer, $city_state, $city, $state, $zip );

        #------ Create a new customer with an estimate
        #todo find_or_create instead of new_result
        $customer =
          $c->model('DB::Customer')
          ->new_result( { 'created_by' => $c->user->id } );
        $form->model->update($customer);

#       $c->log->debug('*** INSIDE schedule_estimate customer:  *** '. $customer->last_name );
        my $estimate = $c->model('DB::Estimate')->new_result(
            {
                'customer_id' => $customer->id,
                'created_by'  => $c->user->id,
            }
        );
        $form->model->update($estimate);

        # Set a status message for the user & View the Estimate Details
        $c->response->redirect(
            $c->uri_for(

                #                           $self->action_for('list'),
                $self->action_for('display_estimate_details'),
                [ $estimate->id ],
                { mid => $c->set_status_msg("Estimate scheduled") }
            )
        );
        $c->detach;
    }
    else {

        # Create an options list of estimators
        $self->create_estimator_list( $c, $form );
    }

#------ Add js to bottom template  (jQ Datepicker And Form Validation to JS array)
    $c->stash(
        bottom_js => 'js/bottom_js.tt2',
        js_array  => [
            $self->datepicker_activation_js($c),
            $self->estimate_form_valid_js($c),
            $self->city_state_zip_js($c),
            $self->city_state_zip_copy_js($c),
        ],
    );

    $c->stash->{template} = "$ESTIMATES_PATH$SCHEDULE_ESTIMATE.tt2";
    $c->forward( $c->view('HTML') );
}

=head2 update_estimate
       Use HTML::FormFu to update an existing estimate
=cut

#------ UPDATE AN ESTIMATE
sub update_estimate : Chained('object') : PathPart('update_estimate') :
  Args(0) : FormConfig('estimates/update_estimate.yml') {
    my ( $self, $c ) = @_;
    my ( $est_cust_rs, $customer );
    DEBUG "*** Just Inside Update Estimate ***";

#    # Check permissions
#    $c->detach('/error_noperms')
#      unless $c->stash->{object}->update_allowed_by( $c->user->get_object );

# Uses  'Catalyst::Plugin::Authorization::Roles' to ensure this user 
# has permission to Update an estimate
    $c->detach('/error_noperms')
          unless $c->check_user_roles('can_update_estimate');

# Get the specified estimate/customer result set already saved by the 'object' method
    $est_cust_rs = $c->stash->{object};

    # Make sure we were able to get a estimate
    if ( not $est_cust_rs ) {

        # Set an error message for the user & return to estimates list
        $c->response->redirect(
            $c->uri_for(
                $self->action_for('list'),
                {
                    mid =>
                      $c->set_error_msg("Invalid estimate id ;-- Cannot edit")
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

        #------ Update the customer estimate info
        $customer = $c->model('DB::Customer')->update_or_new(
            {
                'id'         => $est_cust_rs->customer_id,
                'updated_by' => $c->user->id
            },
            { key => 'primary' }
        );

        #----- update the estimate
        my $estimate = $c->model('DB::Estimate')->update_or_new(
            {
                'id'          => $est_cust_rs->id,
                'updated_by'  => $c->user->id,
                'customer_id' => $est_cust_rs->customer_id,

#                                                 'estimator_id'  => $est_cust_rs->customer_id,
            },
            { key => 'primary' }
        );

        # Save the form data for the estimate
        $form->model->update($customer);
        $form->model->update($estimate);

        # Set a status message for the user
        # Set a status message for the user & return to estimates list
        $c->response->redirect(
            $c->uri_for(
                $self->action_for('display_estimate_details'),
                [ $estimate->id ],
                { mid => $c->set_status_msg("Estimate updated") }
            )
        );
        $c->detach;
    }
    else {

        # Create an options list of estimators
        $self->create_estimator_list( $c, $form );

        #------ Set the time value to the time from the database
        DEBUG "***  Original Estimate time is " . $est_cust_rs->estimate_time;
        my $schedule_time = $form->get_field(
            {
                name => 'estimate_time',
                type => 'Select',
            }
        );

      #------ Get the stored estimate time and convert it to select field format
        MyDate->convert_time_to_form_select_field_option(
            $est_cust_rs->estimate_time, $form );

        #------ Change from submit to Update
        my $submit_el = $form->get_field(
            {
                name => 'submit',
                type => 'Submit',
            }
        );
        $submit_el->value('Update Estimate');
        $submit_el->id('update');

        #------ Populate the form with existing values from DB
        $form->model->default_values( $est_cust_rs->customer );
        $form->model->default_values($est_cust_rs);
        DEBUG " The New Submit Element is $submit_el";
    }

#------ Add js to bottom template  (jQ Datepicker And Form Validation to JS array)
    $c->stash(
        bottom_js => 'js/bottom_js.tt2',
        js_array  => [
            $self->datepicker_activation_js($c),
            $self->estimate_form_valid_js($c),
            $self->city_state_zip_js($c),
            $self->city_state_zip_copy_js($c),
        ],
    );

    $c->stash->{new_heading} = "Edit Schedule Details And Press Submit";
    $c->stash->{template}    = "$ESTIMATES_PATH$SCHEDULE_ESTIMATE.tt2";
    $c->stash->{updating}    = 1;
    $c->forward( $c->view('HTML') );
}

#
##
### ------ Select date form
##
#

#
###
#######--------------------------- Private Methods
###
#
#
##
### ------ JQuery Datepicker JS
##
#

=head2 datepicker_activation_js
    pass $c
    Returns Javascript to activate jQuery Datepicker
=cut

sub datepicker_activation_js {
    my ( $self, $c ) = @_;
    my $js = $c->uri_for('/') . $DATE_PICKER_JS;
    return <<END_JS;
    <script type="text/javascript" 
    src="$js">
    </script>
END_JS
}

#
##
### ------ JQuery Date Validation JS
##
#

=head2 date_validation_js
    Javascript to validate input date (Client Side)
        pass $c
=cut

sub date_validation_js {
    my ( $self, $c ) = @_;
    my $js = $c->uri_for('/') . $DATE_VALIDATION_JS;
    return <<END_JS;
    <script type="text/javascript" 
    src="$js">
    </script>
END_JS
}
#
##
### ------ JQuery  Create/Update Form Validation
##
#

=head2 estimate_form_valid_js
    Javascript to validate input data (Client Side)
    For Create/Update Estimate Form(s)
    pass $c
=cut

sub estimate_form_valid_js {
    my ( $self, $c ) = @_;
    my $js = $c->uri_for('/') . $ESTIMATE_FORM_VALIDATION_JS;
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

=d2 add_date_entry_miniform_to_stash
    Pass the $c object
    Create a small date entry form to add to results page
    Also add the JS datepicker and validation scripts to bottom of page
    Adds the form and JS to the stash
    Returns Undef if unsuccessful. 1 if ok. 
=cut

sub add_date_entry_miniform_to_stash : Private {
    my ( $self, $c ) = @_;
    return undef if not defined $c;

    #------ Add little Date Selector Form To Top
    $c->stash(
        mini_form_one_date => 'input_date_form.tt2',
        input_date         => 1,
        input_date_range   => undef,
        form_action        => $c->uri_for('/estimates/list_by_date'),
        form_id            => 'inputDateForm',
        field_id           => 'input_date',
        label              => 'When?',
        value              => ( $c->request->param('input_date') // '' ),
        place              => 'yyyy-mm-dd',
        button_label       => 'Find Estimates',
        title              => 'Find Estimates For Specified Dates',
    );

#------ Add js to bottom template  (jQ Datepicker And Date Validation to JS array)
    $c->stash(
        bottom_js => 'js/bottom_js.tt2',
        js_array  => [
            $self->datepicker_activation_js($c), $self->date_validation_js($c)
        ],
    );
    1;
}

=d2 add_date_range_miniform_to_stash
    Pass the $c object
    Create a small dates entry form to add to results page
    that will allow the input of a time span specified by dates
    Also add the JS datepicker and validation scripts to bottom of page
    Adds the form and JS to the stash
    Returns Undef if unsuccessful. 1 if ok. 
=cut

sub add_date_range_miniform_to_stash : Private {
    my ( $self, $c ) = @_;
    return undef if not defined $c;

    #------ Add little Date Selector Form To Top
    $c->stash(
        mini_form_date_range => 'input_date_range_form.tt2',
        input_date           => undef,
        input_date_range     => 1,
        form_action          => $c->uri_for('/estimates/list_date_range'),
        form_id              => 'inputDateForm',
        field_id_1           => 'start_date',
        field_id_2           => 'end_date',
        label                => 'Date Range',
        value_1              => ( $c->request->param('start_date') // '' ),
        value_2              => ( $c->request->param('end_date') // '' ),
        place                => 'yyyy-mm-dd',
        button_label         => 'Find Estimates',
        title                => 'Find Estimates Within Date Range',
    );

#------ Add js to bottom template  (jQ Datepicker And Date Validation to JS array)
    $c->stash(
        bottom_js => 'js/bottom_js.tt2',
        js_array  => [
            $self->datepicker_activation_js($c), $self->date_validation_js($c)
        ],
    );
    1;
}

=d2 add_multiple_date_miniforms_to_stash
    Pass the $c object
    Create a small date entry forms to add to results page
    Also add the JS datepicker and validation scripts to bottom of page
    Adds the forms and JS to the stash
    Returns Undef if unsuccessful. 1 if ok. 
=cut

sub add_multiple_date_miniforms_to_stash : Private {
    my ( $self, $c ) = @_;
    return undef if not defined $c;

    #------ Add little Single Date and Date Range Selector Forms
    #       Includes a flag for each form that you would like to
    #       Have appear on the Estimate Pages
    $c->stash(
        using_miniforms     => 1,
        input_one_date_form => {
            mini_form_one_date => 'input_date_form.tt2',
            input_date         => 1,
            input_date_range   => 1,
            day_of_week        => 1,
            month              => 1,
            form_action        => $c->uri_for('/estimates/list_by_date'),
            form_id            => 'inputDateForm',
            field_id           => 'input_date',
            label              => 'When?',
            value              => ( $c->request->param('input_date') // '' ),
            place              => 'yyyy-mm-dd',
            button_label       => 'Find Estimates',
            title              => 'Find Estimates For Specified Dates',
        },
        input_date_range_form => {
            mini_form_date_range => 'input_date_range_form.tt2',
            input_date           => 1,
            input_date_range     => 1,
            day_of_week          => 1,
            month_of_year        => 1,
            form_action          => $c->uri_for('/estimates/list_date_range'),
            form_id              => 'inputDateRangeForm',
            field_id_1           => 'start_date',
            field_id_2           => 'end_date',
            label                => 'Date Range',
            value_1              => ( $c->request->param('start_date') // '' ),
            value_2              => ( $c->request->param('end_date') // '' ),
            place                => 'yyyy-mm-dd',
            button_label         => 'Find Estimates',
            title                => 'Find Estimates Within Date Range',
        },
        input_day_of_week_form => {
            mini_form_day_of_week => 'input_day_of_week_form.tt2',
            input_date            => 1,
            input_date_range      => 1,
            day_of_week           => 1,
            month_of_year         => 1,
            form_action => $c->uri_for('/estimates/list_by_day_of_week'),
            form_id     => 'inputDayOfWeekForm',
            field_id    => 'day_of_week',
            label       => 'Which Day This Week',
            value       => ( $c->request->param('day_of_week') // '' ),

            #            place        => '',
            button_label => 'Find Estimates',
            title        => 'Find Estimates For Any Day This Week',
        },
        input_month_form => {
            mini_form_month  => 'input_month_form.tt2',
            input_date       => 1,
            input_date_range => 1,
            day_of_week      => 1,
            month_of_year    => 1,
            form_action      => $c->uri_for('/estimates/list_by_month'),
            form_id          => 'inputMonthForm',
            field_id         => 'month_of_year',
            label            => 'Which Month This Year',
            value            => ( $c->request->param('month_of_year') // '' ),

            #            place        => '',
            button_label => 'Find Estimates',
            title        => 'Find Estimates For Any Month This Year',
        },
    );

#------ Add js to bottom template  (jQ Datepicker And Date Validation to JS array)
    $c->stash(
        bottom_js => 'js/bottom_js.tt2',
        js_array  => [
            $self->datepicker_activation_js($c), $self->date_validation_js($c)
        ],
    );
    1;
}

=d2 validate_day_of_week_miniform
    Pass the $c object
    Validates the input_date_form FormValidator::Simple plugin
    If unsuccesful, the results set is cleared
        Debug messages printed, Returns Undef
    If succesful, returns validated ISO DateTime date
    corresponding to the Day OF Week selected
=cut

sub validate_day_of_week_miniform : Private {
    my ( $self, $c ) = @_;
    return undef if not defined $c;

    #------ FormValidator checks
    $c->form(
        day_of_week => [
            qw/NOT_BLANK UINT/,
            [qw/LENGTH 1/],
            [ 'BETWEEN', 1, 7 ],

            #                             [ 'DATETIME_STRPTIME', '%Y-%m-%d' ],
        ]
    );

    #------ Bad Form Data. Render Page With Form Again
    if ( $c->form->has_error ) {
        DEBUG "*** Bad Day Of Week Form  data ... " if $c->form->has_error;
        DEBUG "*** Bad form is  ... " . Dumper( $c->form );
        DEBUG "*** Missing  ... " . Dumper( $c->form->missing );
        DEBUG "*** Invalid  ... " . Dumper( $c->form->invalid );
        DEBUG "*** error  ... " . Dumper( $c->form->error );
        $c->stash->{resultset} = undef;

        #-- To make the tab selector active
        $c->stash->{'tab_class_dow'}       = 'class="active"';
        $c->stash->{'tab_active_flag_dow'} = 'active';
        return undef;
    }

    #    DEBUG "*** Good form is  ... " . Dumper($c->form);
    my $date_time_date =
      MyDate->convert_week_day_number_to_date( $c->form->valid('day_of_week') );
    $date_time_date || return undef;
    $c->stash->{'tab_class_dow'}       = undef;
    $c->stash->{'tab_active_flag_dow'} = undef;
    DEBUG "*** Validated Date is :  $date_time_date ";
    return $date_time_date;
}

=d2 validate_month_of_year_miniform
    Pass the $c object
    Validates month number using the  FormValidator::Simple plugin
    If unsuccesful, the results set is cleared
        Debug messages printed, Returns Undef
    If succesful, returns validated ISO DateTime date range
    corresponding to the Month Of Year Selected (month Start Mont End)
=cut

sub validate_month_of_year_miniform : Private {
    my ( $self, $c ) = @_;
    return undef if not defined $c;

    #------ FormValidator checks
    $c->form( month_of_year =>
          [ qw/NOT_BLANK UINT/, [ 'LENGTH', 1, 2 ], [ 'BETWEEN', 1, '12' ], ] );

    #------ Bad Form Data. Render Page With Form Again
    if ( $c->form->has_error ) {
        DEBUG "*** Bad Month Of Year Form  data ... " if $c->form->has_error;
        DEBUG "*** Bad form is  ... " . Dumper( $c->form );
        DEBUG "*** Missing  ... " . Dumper( $c->form->missing );
        DEBUG "*** Invalid  ... " . Dumper( $c->form->invalid );
        DEBUG "*** error  ... " . Dumper( $c->form->error );
        $c->stash->{resultset} = undef;

        #-- To make the tab selector active for this form
        $c->stash->{'tab_class_mm'}       = 'class="active"';
        $c->stash->{'tab_active_flag_mm'} = 'active';
        return undef;
    }
    my ( $month_begin, $month_end ) =
      MyDate->convert_month_number_to_start_end_date(
        $c->form->valid('month_of_year') );
    $month_begin || return undef;
    $month_end   || return undef;
    $c->stash->{'tab_class_mm'}       = undef;
    $c->stash->{'tab_active_flag_mm'} = undef;
    DEBUG '*** Validated Month Range is : '
      . $month_begin->mdy('/') . ' to '
      . $month_end->mdy('/');
    return ( $month_begin, $month_end );
}

=d2 validate_one_date_miniform
    Pass the $c object
    Validates the input_date_form FormValidator::Simple plugin
    If unsuccesful, the results set is cleared
        Debug messages printed, Returns Undef
    If succesful, returns validated dates $input_date
    Which is in ISO DateTime format
=cut

sub validate_one_date_miniform : Private {
    my ( $self, $c ) = @_;
    return undef if not defined $c;

    #------ FormValidator checks
    $c->form(
        input_date => [
            qw/NOT_BLANK ASCII/,
            [qw/LENGTH 0 10/],
            [ 'DATETIME_STRPTIME', '%Y-%m-%d' ],
        ]
    );

    #------ Bad Form Data. Render Page With Form Again
    if ( $c->form->has_error ) {
        DEBUG "*** Bad form data ... " if $c->form->has_error;
        DEBUG "*** Bad form is  ... " . Dumper( $c->form );
        DEBUG "*** Missing  ... " . Dumper( $c->form->missing );
        DEBUG "*** Invalid  ... " . Dumper( $c->form->invalid );
        DEBUG "*** error  ... " . Dumper( $c->form->error );
        $c->stash->{resultset}            = undef;
        $c->stash->{'tab_class_od'}       = 'class="active"';
        $c->stash->{'tab_active_flag_od'} = 'active';
        return undef;
    }
    $c->stash->{'tab_class_od'}       = undef;
    $c->stash->{'tab_active_flag_od'} = undef;
    my $date_time_date = $c->form->valid('input_date') || return undef;
    DEBUG "*** Validated Date is :  $date_time_date ";
    return $date_time_date;
}

=d2 validate_date_range_miniform
    Pass the $c object
    Validates the Between_dates miniform using FormValidator::Simple plugin
    If unsuccesful, the results set is cleared
        Debug messages printed, Returns Undef
    If succesful, returns validated dates ($date_time_start, $date_time_end)
    Which are in ISO DateTime format
=cut

sub validate_date_range_miniform : Private {
    my ( $self, $c ) = @_;
    return undef if not defined $c;

    #------ FormValidator checks
    $c->form(
        start_date => [
            qw/NOT_BLANK ASCII/,
            [qw/LENGTH 0 10/],
            [ 'DATETIME_STRPTIME', '%Y-%m-%d' ],
        ],
        end_date => [
            qw/NOT_BLANK ASCII/,
            [qw/LENGTH 0 10/],
            [ 'DATETIME_STRPTIME', '%Y-%m-%d' ],
        ]
    );

    #------ Bad Form Data. Render Page With Form Again
    if ( $c->form->has_error ) {
        DEBUG "*** Bad form data ... " if $c->form->has_error;
        DEBUG "*** Bad form is  ... " . Dumper( $c->form );
        DEBUG "*** Missing  ... " . Dumper( $c->form->missing );
        DEBUG "*** Invalid  ... " . Dumper( $c->form->invalid );
        DEBUG "*** error  ... " . Dumper( $c->form->error );
        $c->stash->{resultset}            = undef;
        $c->stash->{'tab_class_dr'}       = 'class="active"';
        $c->stash->{'tab_active_flag_dr'} = 'active';
        return undef;
    }
    $c->stash->{'tab_class_dr'}       = undef;
    $c->stash->{'tab_active_flag_dr'} = undef;
    my $date_time_start = $c->form->valid('start_date') || return undef;
    my $date_time_end   = $c->form->valid('end_date')   || return undef;
    DEBUG "*** Validated Date is (start): $date_time_start";
    DEBUG "*** Validated Date is (end): $date_time_end";
    return ( $date_time_start, $date_time_end );
}

=d2 create_previous_next_day_tags
    Pass the $c object and DateTime Object
    Create buttons to direct user to previous day or next day selection
    Add them to the Stash
    Returns Undef if unsuccessful. 1 if ok. 
=cut

sub create_previous_next_day_tags : Private {
    my ( $self, $c, $today ) = @_;
    return undef if not defined $c;

    #------ Set up the previous and next day links
    #
    my $prev = $today->clone->subtract( days => 1 );
    my $next = $today->clone->add( days => 1 );
    return undef if ( ( not defined $prev ) or ( not defined $next ) );
    $c->stash->{'prev'} =
      $c->uri_for( $self->action_for('list_by_date'), $prev );
    $c->stash->{'prev_label'} = "Previous Day";
    $c->stash->{'next'} =
      $c->uri_for( $self->action_for('list_by_date'), $next );
    $c->stash->{'next_label'} = "Next Day";
    1;
}

=d2 get_date_time_my_way
    Pass the $c object and a date string
    Tries Various Mehods in MyDate.pm to Convert this Date to DateTime Format
    Returns a DateTime Object if successful
    Renders error Page if unsuccessful
=cut

sub get_date_time_my_way : Private {
    my ( $self, $c, $input_date ) = @_;
    return undef unless defined $input_date;
    my ($date_time);
    DEBUG "*** Using MyDate ";
    eval {
        $date_time = MyDate->convert_date_string_to_date_time($input_date); };
    return $date_time if ( defined $date_time );

    #------ Still not working.....
    DEBUG "Eval output: $@ " if $@;
    $c->stash->{error_msg_1} =
      "Requested Date Could not be converted to DateTime format.";
    $c->detach('/error_other');
}

=d2 list
Populate the stash with one estimate
=cut

sub create_estimate_entry : Private {
    my ( $self, $c, $est_obj ) = @_;
    my ( $est_date, $est_time );

    #----- Parse the Date Time from Timestamp;
    if ( $est_obj->estimate_date =~ /\A(.*)T(\d\d:\d\d):.*\Z/ ) {
        $est_date = $1;
        $est_time = $2;
    }

    #    $c->stash->{ESTIMATE_ID}  = $est_obj->id  // undef;
    #    $c->stash->{ESTIMATOR} = $est_obj->belongs_to // undef;
    $c->stash->{L_NAME}        = $est_obj->last_name              // undef;
    $c->stash->{SUFFIX}        = $est_obj->suffix                 // undef;
    $c->stash->{PREFIX}        = $est_obj->prefix                 // undef;
    $c->stash->{F_NAME}        = $est_obj->first_name             // undef;
    $c->stash->{ADR_1}         = $est_obj->address_1              // undef;
    $c->stash->{ADR_2}         = $est_obj->address_2              // undef;
    $c->stash->{CITY}          = $est_obj->city                   // undef;
    $c->stash->{STATE}         = $est_obj->state                  // undef;
    $c->stash->{PHONE_1}       = $est_obj->phone_1                // undef;
    $c->stash->{PHONE_2}       = $est_obj->phone_2                // undef;
    $c->stash->{PHONE_3}       = $est_obj->phone_3                // undef;
    $c->stash->{EMAIL_1}       = $est_obj->email_1                // undef;
    $c->stash->{EMAIL_2}       = $est_obj->email_2                // undef;
    $c->stash->{SCHEDULE_DATE} = $est_obj->estimate_date          // undef;
    $c->stash->{SCHEDULE_TIME} = '</br>' . $est_time              // undef;
    $c->stash->{ESTIMATOR}     = $est_obj->belongs_to->first_name // undef;
    $c->stash->{REC_BY}        = $est_obj->recommended_by         // undef;
    $c->stash->{REP_CUST}      = $est_obj->repeat_cust            // undef;

#    $c->stash->{ESTIMATOR}      = $est_obj->belongs_to->first_name    // undef;
}

#-----------------  FILTERING AND VALIDATION AREA

#
#----------------- END OF FILTERING AND VALIDATION AREA
#-----
#------ Set up the estimators
#-----

=d2 create_estimator_list
Set up the options list for all the available estimators.
At the moment, it includes all employees.
But the designagted estimators should get preference
=cut

sub create_estimator_list : Private {
    my ( $self, $c, $form ) = @_;
    my @estimator_objs = $c->model("DB::Employee")->all();

#    my @estimator_objs = $c->model("DB::Employee")->search({department => {'<' => 60}});
# Create an array of arrayrefs where each arrayref is an estimator
    my @estimators;
    foreach (
        sort {
                 $a->first_name cmp $b->first_name
              || $a->alias cmp $b->alias
              || $a->last_name cmp $b->last_name;
        } @estimator_objs
      )
    {
        push( @estimators, [ $_->id, ( $_->alias // $_->first_name ) ] );
    }
    my $select = $form->get_field( { name => 'estimator_id', } );

    #    unshift @estimators,[0,'-w/a-'];
    $select->options( \@estimators );
}

#------------------------------------------------------------------------------

=head1 AUTHOR

austin,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

#####################################################################################################
__PACKAGE__->meta->make_immutable;
1;
