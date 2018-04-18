$(document).ready(function() {
  var modal = $(".modal-events");

  // make roles draggable
  $("input:checkbox.user-select").click(function(){
    $(this).parent().parent().toggleClass("checked");
  });


  $("input:checkbox.role-checkbox").click(function() {
    $(this).next().toggleClass("checked");
  })


  $(".modal-content").draggable({
    handle: ".modal-header"
  });

  $('#my-draggable').draggable({
    revert: true,      // immediately snap back to original position
    revertDuration: 0  //
  });

  // assign default event data to draggable elements
  $('.draggable').data('duration', '03:00');
  // when clicking on its 'Cancel' button
  $(".cancel-button").click(function(){
    modal.modal('hide');
  });

  //lorsqu'une modale se ferme la border se désélectionne
  modal.on('hide.bs.modal', () => {
    $(".fc-time-grid-event").css('border-width', '');
  });



});
