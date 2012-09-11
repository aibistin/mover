//http://jquery.bassistance.de/validate/demo/   

$().ready(function() {

// 
// validate Estimates form on keyup and submit
$("#estForm").validate({
    rules: {
        //first_name: "required",
        first_name: {
          required: true,
          minlength: 2
        },
        last_name: {
          required: true,
          minlength: 2
        },
        address_1: {
          required: true,
          minlength: 2
        },
        city: {
          required: true,
          minlength: 2
        },
        state: {
          required: true,
          minlength: 2
        },
        zip: {
         required: false,
         //digits: true
         minlength: 2
        },
        phone_1: {
            required: true,
            phoneUS: true,
            
        },
        phone_2: {
            required: false,
            phoneUS: true
        },
        email_1: {
            required: false,
            email: true
        },
        email_2: {
            required: false,
            email: true
        },
        estimate_date: {
            required: true,
            dateISO: true
        },
        comments: {
            required: false,
            maxlength: 200
        },
        
        //agree: "required"
    },
    messages: {
        first_name: "Please enter a firstname",
        last_name: "Please enter a lastname",
        address_1: "An address would make this customer easier to find",
        city: "A city would make this customer easier to find",
        state: "A state code would make this customer easier to find",
        phone_1: "Would be nice to have a proper phone number",
        phone_2: "Not a recognized phone number format",
        recommended_by: "What genius recommended us",
        email_1: "Hey Dufus! Enter a proper email address!",
        email_2: "Hey Dufus! Enter a proper email address!",
        estimate_date: "When would be a good time to do an estimate?",
        estimate_time: "When would be a good time to do an estimate?",
        //agree: "Please accept our policy"
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