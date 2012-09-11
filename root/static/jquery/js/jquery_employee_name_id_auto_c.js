//----------------------------------------------------------------
//       Add Employee Name and Id to Employee Autocomplete
//       Include it in a template that has employee selection form
//       Modify this to call Perl module/method to return employees
//       THIS DOSENT WORK NOW
//----------------------------------------------------------------

$( function(){

    function log( message ) {
        $( "<div/>" ).text( message ).prependTo( "#employee_name" );
        $( "#employee_name" ).scrollTop( 0 );
    }
//        var [% emps =  employee_full_names %],  

        $( "#employee_name" ).autocomplete({
            source: emps,  
            minLength: 1,
            //appendTo: "#employee_name"
            select: function( event, ui ) {
            log( ui.item ?
        ui.item.value :
        this.value );
        }
    });

});
   
