//http://jquery.bassistance.de/validate/demo/   
//
// VALIDATE PHONE NUBER
//

$().ready(function() {

// 
// validate Phone Number form on keyup and submit
$("#phone_no").validate({
    rules: {

        phone_no: {
          required: true,
          digits: true,
          phoneUS: true,
        },

    },
    

    messages: {

        phone_no: "Please enter a valid USA phone number",
    }
});

0

});
