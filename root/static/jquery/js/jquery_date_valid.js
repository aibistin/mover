//http://jquery.bassistance.de/validate/demo/   

$().ready(function() {

// 
// validate Generic Date form on keyup and submit
$("#inputDateForm").validate({
    rules: {
        schedule_date: {
            required: false,
            dateISO: true
        },
        start_date: {
            required: true,
            dateISO: true
        },
        end_date: {
            required: true,
            dateISO: true
        },
        input_date: {
            required: true,
            dateISO: true
        },
    },
    messages: {
        schedule_date: "Improper Schedule Date?",
        start_date: "Improper Start Date (Need yyyy-mm-dd format",
        end_date: "Improper End Date",
        input_date: "Date must be in yyyy-mm-dd format",
    }
});

});
