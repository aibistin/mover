//http://jquery.bassistance.de/validate/demo/   
//
// VALIDATE CUSTOMER ID
//

$().ready(function() {

// 
// validate Estimates form on keyup and submit
$("#customer_id").validate({
    rules: {

        customer_id: {
          required: true,
          digits: true,
          range: [1,10000],
        },

    },
    

    messages: {

        customer_id: "Please enter a valid id",
    }
});

0

});
