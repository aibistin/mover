//http://jquery.bassistance.de/validate/demo/   
//
// VALIDATE LAST NAME
//

$().ready(function() {

// 
// validate Estimates form on keyup and submit
$("#last_name").validate({
    rules: {

        last_name: {
          required: true,
          rangelength: [1,50],
        },

    },
    

    messages: {

        last_name: "Please enter a real lastname",
    }
});

0

});
