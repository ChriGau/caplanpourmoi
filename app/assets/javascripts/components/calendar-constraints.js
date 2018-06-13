var modifyCalendar = function(events, defaultDate) {

  var modalContent = document.querySelector(".modal-content");
  var modalPosition = function(modal, position) {
    modal.style.setProperty('--postop', position -300 + "px");
  }

  var mySlider = $("input#nb-employees").bootstrapSlider();

  // comportement lors de la sélection d'une catégorie
  $('.category').click( function (data){
    var a = '#' + data.toElement.value;
    $('#0').toggleClass("checked");
    $('#1').removeClass("checked");
    $('#2').removeClass("checked");
    $(a).addClass("checked");
  });

  // Ajout de roles au user
  $('.fa-plus').click(function(data){
    $(".modal-role-user").modal('show');
  });
    $('.metier').click( function (data){
    var a = '#' + data.toElement.value;
    $(a).toggleClass("checked");
  });

  // Suppression de roles au user
  $('.delete-role').click(function(data){
    var role_id = data.toElement.id;
    var list_of_classes = data.toElement.classList;
    var user_id = list_of_classes[2].substring(4);
    var roleuser_id = list_of_classes[3].substring(8);
    var role_id = list_of_classes[4].substring(4);

    var role_user_data = {
      role_user: {
        id: roleuser_id,
        role_id: role_id,
        user_id: user_id
                }
      };
    var build_url = "/users/" + user_id + "/role_users/" + roleuser_id;
    console.log("URL => " + build_url);

      $.ajax({
        url: build_url,
        data: role_user_data,
        format: 'js',
        type: "DELETE",
        success: function(data) {
          console.log(Event);
        },
        error: function(jqXHR) {
          console.log("ajax echec");
          console.log(jqXHR.responseText);
        }
    });
  });

  // edit de working_hours
  $('.modify-working-hours').click(function(data){
    $(".modal-edit-working-hours").modal('show');
  });

  $('#calendar').fullCalendar({
    //calendar attributes
    header: {
      left: 'prev, next',
      center: '', //title
      right: 'agendaWeek,agendaDay',
    },
    themeSystem: 'bootstrap3',
    allDaySlot: false,
    locale: "fr",
    editable: true, // events on the calendar can be modified
    droppable: true, // allows things to be dropped onto the calendar
    selectable: true,
    minTime: "07:00:00", // starting time, even when scrolled all the way up
    maxTime: "22:00:00",
    defaultView: "agendaWeek",
    hiddenDays: [ 0], // hider dimanche
    height: "auto", // implique pas de scroll à l'intérieur du calendrier
    aspectRatio: 4,
    defaultDate: defaultDate,
    events: events,
    // what happens when we select a time period on the calendar
    select: function( start, end, jsEvent, view ) {
      modalPosition(modalContent, jsEvent.clientY);
      $(".modal-constraint").modal('show');
      $('.constraint_form').show();
      $('.update_constraint').hide();
      $('.delete_constraint').hide();
      $('.days-list').show();
      // set default value of the date inputs (inside simple form)
      $('#datetimepicker1 .form-control').val(new Date(start.format()).toLocaleDateString('fr-FR', {timezone: 'UTC', hour: '2-digit', minute: '2-digit'}));
      $('#datetimepicker1').datetimepicker({
        locale: 'FR'
       });
      $('#datetimepicker2 .form-control').val(new Date(end.format()).toLocaleDateString('fr-FR', {timezone: 'UTC', hour: '2-digit', minute: '2-digit'}));
      $('#datetimepicker2').datetimepicker({
        locale: 'FR'
       });
      //behavior of days sélection
      $("input:checkbox").click(function(){
        $(this).parent().parent().toggleClass("checked");
      });
      $('input:checkbox').each(function(){
        $(this)[0].disabled= false;
        $(this)[0].checked= false;
      });
      $('.daysbox').removeClass('checked unselectable');
      var date = (new Date(end.format()).getDay());
      $('input:checkbox[value='+date+']')[0].disabled= true;
      $('input:checkbox[value='+date+']').parent().parent().addClass('unselectable');
    }, // fin select


  });
}
