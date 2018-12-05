$(document).ready(function() {
  var modal = $(".modal-events");

  // Highlight selected user on click
  $("input:checkbox.user-select").click(function(){
    $(this).parent().parent().parent().toggleClass("checked");
  });

  // ?????? sert problablement à rien
  $("input:checkbox.role-checkbox").click(function() {
    alert("22 nov 18 je crois que ça sert // enlever si ça apparait");
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

  var modalContent = document.querySelector(".this");
    var modalPosition = function(modal, position) {
    modal.style.setProperty('--postop', position -100 + "px");
  }

    $(".use_template").click(function(jsEvent){
      modalPosition(modalContent, jsEvent.clientY);
      $(".modal-use-template").modal('show');
    });

});
