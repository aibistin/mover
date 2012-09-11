//http://jquery.bassistance.de/validate/demo/   
//
// VALIDATE THE CUSTOMER INPUT FORM
//

$().ready(function() {

// 
// validate Estimates form on keyup and submit
$("#custForm").validate({
    rules: {
        //first_name: "required",
        first_name: {
          required: true,
         rangelength: [1,50]
        },
        last_name: {
          required: true,
          rangelength: [1,50]
        },
        address_1: {
          required: true,
          rangelength: [1,50]
        },
        city: {
          required: true,
          minlength: 2,
          rangelength: [1,50]
        },
        state: {
          required: true,
          minlength: 2,
          rangelength: [2,50]
        },
        zip: {
         required: false,
         //digits: true
         rangelength: [2,16]
        },
        phone_1: {
            required: true,
            phoneUS: true,
            
        },
        phone_2: {
            required: false,
            phoneUS: true
        },
        phone_3: {
            required: false,
            phoneUS: false,
            rangelength: [2,40]
        },
        email_1: {
            required: false,
            email: true
        },
        email_2: {
            required: false,
            email: true
        },

        comments: {
            required: false,
            maxlength: 600
        },
        
        //agree: "required"
    },
    
	    //highlight: function(label) {
	    //	$(label).closest('.control-group').addClass('error');
	    //},
	    //success: function(label) {
	    //	label
	    //		.text('OK!').addClass('valid')
	    //		.closest('.control-group').addClass('success');
	    //}    
    messages: {
        first_name: "Please enter a firstname",
        last_name: "Please enter a lastname",
        address_1: "Need a street address",
        city: "What city?",
        state: "What state",
        phone_1: "Need a proper phone number",
        phone_2: "Not a recognized us phone number format",
        recommended_by: "Who recommended us",
        email_1: "Hey Dufus! Enter a proper email address!",
        email_2: "Hey Dufus! Enter a proper email address!",

        //agree: "Please accept our policy"
    }
});



});
