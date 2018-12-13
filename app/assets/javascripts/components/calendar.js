


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
      maxTime: "20:00:00",
      defaultView: "agendaWeek",
      hiddenDays: [ 0], // hider dimanche
      height: "auto", // implique pas de scroll à l'intérieur du calendrier
      aspectRatio: 4,
      defaultDate: defaultDate,
      events: events
    });
};

var modifyCalendar = function(events, defaultDate) {

  var modalContent = document.querySelector(".modal-content");
  var modalPosition = function(modal, position) {
    modal.style.setProperty('--postop', position -300 + "px");
  }

  $("input:checkbox").click(function(){
    $(this).parent().parent().toggleClass("checked");
  });
  var mySlider = $("input#nb-employees").bootstrapSlider();


  $('#calendar').fullCalendar({
    //calendar attributes
    header: {
      center: '', //title
      left: 'prev, next',
      right: 'agendaWeek,agendaDay',
    },
    themeSystem: 'bootstrap3',
    allDaySlot: false,
    locale: "fr",
    editable: true, // events on the calendar can be modified
    droppable: true, // allows things to be dropped onto the calendar
    selectable: true,
    minTime: "07:00:00", // starting time, even when scrolled all the way up
    maxTime: "20:00:00",
    defaultView: "agendaWeek",
    hiddenDays: [ 0], // hider dimanche
    height: "auto", // implique pas de scroll à l'intérieur du calendrier
    aspectRatio: 4,
    defaultDate: defaultDate,
    events: events,
    // what happens when we select a time period on the calendar
    select: function( start, end, jsEvent, view ) {
      modalPosition(modalContent, jsEvent.clientY);
      $('.errors').hide();
      $('.create_slot').hide();
      $(".modal-events").modal('show');
      $('.create_slot').show();
      $('.update_slot').hide();
      $('.delete_slot').hide();
      $('.nb-employees-range').show();
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

      $('input:checkbox').each(function(){
        $(this)[0].disabled= false;
        $(this)[0].checked= false;
      });
      $('.daysbox').removeClass('checked unselectable');
      var date = (new Date(end.format()).getDay());
      $('input:checkbox[value='+date+']')[0].disabled= true;
      $('input:checkbox[value='+date+']').parent().parent().addClass('unselectable');
    },

    eventDrop: function(event, delat, revertFunc){
      var planning_id = event.planning_id ;
      var slot_id = event.id;
      var build_url = "/plannings/" + planning_id + "/slots/" + slot_id;
      var slot_role_name = event.title;
       event_data = {
        slot: {
            id: slot_id,
            role_id: event.role_id,
            start: event.start.format(),
            end: event.end.format(),
            start_at: event.start.format(),
            end_at: event.end.format()
          }
      };
      $.ajax({
        url: build_url,
        data: event_data,
        format: 'js',
        type: 'PATCH',
        success: function(data) {
          console.log(Event);
          console.log("sucess - PATCH de eventDrop");
        },
        error: function(jqXHR) {
          console.log("ajax echec - PATCH de eventDrop");
          console.log(jqXHR.responseText);
        }
      });
    }, // fin eventDrop

    eventResize: function( event, delta, revertFunc, jsEvent, ui, view ) {
      var planning_id = event.planning_id;
      var slot_id = event.id;
      var build_url = "/plannings/" + planning_id + "/slots/" + slot_id;
       event_data = {
        slot: {
            id: slot_id,
            role_id: event.role_id,
            start: event.start.format(),
            end: event.end.format(),
            start_at: event.start.format(),
            end_at: event.end.format()
          }
      };
      $.ajax({
        url: build_url,
        data: event_data,
        format: 'js',
        type: 'PATCH',
        success: function(data) {
          console.log(event);
          console.log("requete PATCH reSize Event effectuée");
        },
        error: function(jqXHR) {
          console.log("ajax echec - PATCH de eventResize");
          console.log(event_data);
          console.log(jqXHR.responseText);
        }
      });
     },

    eventClick: function( calEvent, jsEvent, view) {
      $('.update_slot').unbind();
      $('.delete_slot').unbind();
      modalPosition(modalContent, jsEvent.clientY);
      $(this).css('border-color', 'red');
      $(this).css('border-width', 'thick');
      $(".modal-events").modal('show');
      $('.create_slot').hide();
      $('.update_slot').show();
      $('.delete_slot').show();
      $('.nb-employees-range').hide();
      $('.days-list').hide();
      // get variables
      var planning_id = calEvent.planning_id;
      var slot_id = calEvent.id;
      var role_id = calEvent.role_id;
      var start_date = new Date(calEvent.start.format());
      var start_date = new Date(start_date.setHours(start_date.getHours() ));
      var end_date = new Date(calEvent.end.format());
      var end_date = new Date(end_date.setHours(end_date.getHours() ));
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

      $('.update_slot').off('click', function() {
      });

      // when clicking on update_slot
      $(".update_slot").click( function (){
        var start_chosen = $("#datetimepicker1").find("input").val();
        var end_chosen = $("#datetimepicker2").find("input").val();
        var role_id = Number($("#slot_role_id").val());
        event_data_bis = {
              slot: {
                  id: calEvent.id,
                  role_id: role_id,
                  start: start_chosen,
                  end: end_chosen,
                  start_at: start_chosen,
                  end_at: end_chosen
                }
            };
        $.ajax({
          url: build_url,
          data: event_data_bis,
          format: 'js',
          type: 'PATCH',
          success: function(data) {
            console.log(Event);
            $('.update_slot').unbind();
            $('.delete_slot').unbind();
          },
          error: function(jqXHR) {
            console.log("ajax echec - PATCH de .update_slot");
            console.log(jqXHR.responseText);

            $('#calendar').fullCalendar( 'refetchEvents' );
          }
        }); // fin ajax request
      }); // fin de update_slot

      // Ajax request to delete a slot
      var build_url = "/plannings/" + planning_id + "/slots/" + slot_id;
      $(".delete_slot").click( function (data){
        event_data = {
          slot: {
              id: calEvent.id,
              role_id: role_id,
              start: start_date,
              end: end_date,
              start_at: start_date,
              end_at: end_date
            }
        };
        $.ajax({
          url: build_url,
          data: event_data,
          format: 'js',
          type: "DELETE",
          success: function(data) {
            console.log(Event);
            $('.delete_slot').unbind();
          },
          error: function(jqXHR) {
            console.log("ajax echec");
            console.log(jqXHR.responseText);
          }
        });
      });
    } // fin de eventClick
  });
}
