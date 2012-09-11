//Copy the State and Zip from the city-state-zip field

$(document).ready(function() {
//Zip
$('#zip').bind('focus', function() {
//if ($(this).val() == '' && $('#city').val() != 'New York') {
if ( $('#city').val() != 'New York') {
  var cityZip = $('#city').val().split('-')[2];
  $(this).val(cityZip);
}
});
// state
$('#state').bind('focus', function() {
//if ($(this).val() == '' && $('#city').val() != 'New York') {
if ( $('#city').val() != 'New York') {
  var cityState = $('#city').val().split('-')[1];
  $(this).val(cityState);
}
});

// city
//$('#city').bind('focus', function() {
//  //if ($(this).val() == '' && $('#city').val() != 'New York') {
//  if ( $('#city').val() != 'New York') {
//    var cityCity= $('#city').val().split('-')[0];
//    $(this).val(cityState);
//  }
//});


});