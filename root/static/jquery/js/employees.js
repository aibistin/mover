//
//        $(function() {
//        
//
//        $( "#employee_name" ).autocomplete({
//            source: "[% employee_ids_names %]", minLength: 2,
//        });
//    }); 
//   
//----------------------------------------------------------------
//       Add Employee Name and Id to Employee Autocomplete
//----------------------------------------------------------------

$( function(){

    function log( message ) {
        $( "<div/>" ).text( message ).prependTo( "#employee_name" );
        $( "#employee_name" ).scrollTop( 0 );
    }
    
    

        $( "#employee_name" ).autocomplete({
            source:[% employee_ids_names %],
            minLength: 1,
            //appendTo: "#employee_name"
            select: function( event, ui ) {
            log( ui.item ?
        ui.item.value :
        this.value );
        }
    });
});
