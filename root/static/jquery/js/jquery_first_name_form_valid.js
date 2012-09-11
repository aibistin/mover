//http://jquery.bassistance.de/validate/demo/   
//
// VALIDATE FIRST NAME
//

$().ready(function() {

// 
// validate :form on keyup and submit
$("#first_name").validate({
    rules: {

        first_name: {
          required: true,
          rangelength: [1,40],
        },

    },
    

    messages: {

        first_name: "Please enter a real first name",
    }
});

0

});
