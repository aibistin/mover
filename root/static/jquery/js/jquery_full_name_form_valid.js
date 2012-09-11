//http://jquery.bassistance.de/validate/demo/   
//
// VALIDATE FULL NAME
//

$().ready(function() {

// 
// validate Estimates form on keyup and submit
$("#full_name").validate({
    rules: {

        full_name: {
          required: true,
          rangelength: [1,60],
        },

        employee_name: {
          required: true,
          rangelength: [1,60],
        },

    },
    

    messages: {

        last_name: "Please enter a real name",
        last_name: "Please enter a real employee name",
    }
});

0

});
