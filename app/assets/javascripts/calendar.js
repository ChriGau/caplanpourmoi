$(document).ready(function() {
  // make roles draggable
  $("input:checkbox").click(function(){
    $(this).parent().parent().toggleClass("checked");
  });

  $('#my-draggable').draggable({
    revert: true,      // immediately snap back to original position
    revertDuration: 0  //
  });
  // assign default event data to draggable elements
  $('.draggable').data('duration', '03:00');
  // when clicking on its 'Cancel' button
  $(".cancel-button").click(function(){
    $(".modal_events").modal('hide');
    // 1. get border thickness of Event back to normal
    $(".fc-time-grid-event").css('border-width', '0px','box-shadow', '0px 0px 3.5px -1px white inset', 'padding', '2px' , 'padding-top', '7px','padding', '3px');
    // 2. reload page
    $('#calendar').fullCalendar( 'refetchEvents' );
  });

});
