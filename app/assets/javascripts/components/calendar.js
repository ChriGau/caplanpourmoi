
var displayCalendar = function(events, defaultDate) {

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
      minTime: "07:00:00", // starting time, even when scrolled all the way up
      maxTime: "22:00:00",
      defaultView: "agendaWeek",
      hiddenDays: [ 0], // hider dimanche
      height: "auto", // implique pas de scroll à l'intérieur du calendrier
      aspectRatio: 4,
      defaultDate: defaultDate,
      events: events
    });
};


var modifyCalendar = function(events, defaultDate) {
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

      $(".slot_form").show();
      $('.create_slot').prop('disabled', false);
      // get form to create a new slot
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
      $('input:checkbox').each(function(){
        $(this)[0].disabled= false;
        $(this)[0].checked= false;
      });
      $('.daysbox').removeClass('checked unselectable');
      var date = (new Date(end.format()).getDay());
      $('input:checkbox[value='+date+']')[0].disabled= true;
      $('input:checkbox[value='+date+']').parent().parent().addClass('unselectable');


    },
    eventClick: function( calEvent, jsEvent, view) {
      $(this).css('border-color', 'red');
      $(this).css('border-width', 'thick');
      $(".slot_form").show();
      // disable 'Valider' button
      $('.create_slot').prop('disabled', true);
      // get variables
      var planning_id = calEvent.planning_id;
      var slot_id = calEvent.id;
      var role_id = calEvent.role_id;
      var start_date = new Date(calEvent.start.format());
      var start_date = new Date(start_date.setHours(start_date.getHours() -2));
      var end_date = new Date(calEvent.end.format());
      var end_date = new Date(end_date.setHours(end_date.getHours() -2));
      // set default values to the form
      $('#datetimepicker1 .form-control').val(start_date.toLocaleDateString('fr-FR', {timezone: 'UTC', hour: '2-digit', minute: '2-digit'}));
      $("#datetimepicker1").datetimepicker({
        locale: 'FR'
      });
      $('#datetimepicker2 .form-control').val(end_date.toLocaleDateString('fr-FR', {timezone: 'UTC', hour: '2-digit', minute: '2-digit'}));
      $("#datetimepicker2").datetimepicker({
        locale: 'FR'
      });
      $('#slot_role_id').val(role_id);
      // Ajax request to delete a slot
      var build_url = "/plannings/" + planning_id + "/slots/" + slot_id;
      $(".delete_slot").click( function (){
        $.ajax({
          type: "DELETE",
          url: build_url,
          format: 'js',
          success: function(data) {
            console.log(Event);
            // recharger la page
            location.reload();
          },
          error: function(jqXHR) {
            console.log("ajax echec");
            console.log(jqXHR.responseText);
            location.reload();
          }
        });
      });
    }
  });
}
