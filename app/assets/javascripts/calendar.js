$(document).ready(function() {
  // hide slot form
  $(".slot_form").hide();
  // make roles draggable
  $('#my-draggable').draggable({
    revert: true,      // immediately snap back to original position
    revertDuration: 0  //
  });
  // assign default event data to draggable elements
  $('.draggable').data('duration', '03:00');
  // hide slot_form + reload page when clicking on the 'Valider' button
  $('.create_slot').click(function(){
    $(".slot_form").hide();
    location.reload();
  });
  // when clicking on its 'Cancel' button
  $(".cancel-button").click(function(){
    $(".slot_form").hide();
    // 1. get border thickness of Event back to normal
    $(".fc-time-grid-event").css('border-width', '0px','box-shadow', '0px 0px 3.5px -1px white inset', 'padding', '2px' , 'padding-top', '7px','padding', '3px');
    // 2. reload page
    $('#calendar').fullCalendar( 'refetchEvents' );
    // location.reload();
  });
});
