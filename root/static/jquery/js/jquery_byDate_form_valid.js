//http://jquery.bassistance.de/validate/demo/   

$().ready(function() {

// 
// validate Estimates form on keyup and submit
$("#estByDateForm").validate({
    rules: {
        schedule_date: {
            required: false,
            dateISO: true
        },
        starting_date: {
            required: false,
            dateISO: true
        },
        ending_date: {
            required: false,
            dateISO: true
        },
    },
    messages: {
        schedule_date: "Improper Schedule Date?",
        starting_date: "Improper Starting Date?",
        ending_date: "Improper Ending Date?",
    }
});

// Search by customer last_name form
$("#last_name_form").validate({
    rules: {
        //flast_name: "required",
        last_name: {
          required: true,
          minlength: 1,
          maxlength: 40
        },
        messages: {
        last_name: "Please enter a valid last name. Maximum 40 char. ",
        }
    }
}); 
// Search by customer first_name form
$("#first_name_form").validate({
    rules: {
        //first_name: "required",
        first_name: {
          required: true,
          minlength: 1,
          maxlength: 40,
        },
        messages: {
        first_name: "Please enter a valid first name. Maximum 40 char. ",
        }
    }
});  
  
// Search by customer first_name form
$("#search_name_form").validate({
    rules: {
        search_name: {
          required: true,
          minlength: 1,
          maxlength: 40,
        },
        messages: {
        first_name: "Please enter a valid search name. Maximum 40 char.  ",
        }
    }
});  
  


});