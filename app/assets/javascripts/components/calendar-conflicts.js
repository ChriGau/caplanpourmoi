
var modifyCalendar = function(events, defaultDate) {

  var modalContent = document.querySelector(".modal-content");
  var modalPosition = function(modal, position) {
    modal.style.setProperty('--postop', position -300 + "px");
  }

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

        eventClick: function( calEvent, jsEvent, view) {
          modalPosition(modalContent, jsEvent.clientY);
          $('.reassign-solution_slot').unbind();
          $(this).css('border-color', 'red');
          $(this).css('border-width', 'thick');

          // refectch events when modal is closed => no more red border-color
          $(".modal-reassignment").on("hidden.bs.modal", function () {
            $('#calendar').fullCalendar( 'refetchEvents' );
          });

          var solution_slot_id = calEvent.solution_slot_id.id;
          // get variables
          var planning_id = calEvent.planning_id;
          console.log("planning id = " + planning_id);

          //when clicking on a slot, ajax request to solution_slots#edit
          var build_url = "/plannings/" + planning_id + "/solution_slots/" + solution_slot_id + "/edit";
              // requete vers edit du solution slot
          $.ajax({
            url: build_url,
            // data: solution_slot_data,
            format: 'js',
            type: 'GET',
            success: function(data) {
               $('.modal-body').html(data);
               $(".modal-reassignment").modal('show');
               $('.reassign-solution_slot').unbind();
            },
            error: function(jqXHR) {
              console.log("ajax echec - GET de edit solution_slot");
              console.log(jqXHR.responseText);
            }
          }); // fin ajax request

        }, // fin de eventClick


        eventRender: function(event, element) {
          element.find('.fc-title').html("<img src= "+event.picture+" alt='' style='border-radius:60px; height: 3em' >");
        },

        eventAfterAllRender: function(view) {
          const slots = Array.from(document.querySelectorAll('.fc-event-container > a'));
          slots.forEach(slot => {
            const upperSlots = slots.filter(upperSlot =>
              parseInt(slot.style.zIndex) < parseInt(upperSlot.style.zIndex)
            );
            const overlap = upperSlots.some(upperSlot =>
              (slot.getBoundingClientRect().x + slot.offsetWidth - 40 > upperSlot.getBoundingClientRect().x)
            )
            overlap ? slot.firstElementChild.style.display = "block" : "" ;
          })
        }


      }); // fin fullcalendar

    function show_image(src, width, height, alt) {
        var img = document.createElement("img");
        img.src = src;
        img.width = width;
        img.height = height;
        img.alt = alt;
      };


}

