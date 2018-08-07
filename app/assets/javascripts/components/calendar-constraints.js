var modifyConstraintsCalendar = function(events, defaultDate) {

var modalContent = document.querySelector(".modal-content");
var modalPosition = function(modal, position) {
  modal.style.setProperty('--postop', position -300 + "px");
}

var mySlider = $("input#nb-employees").bootstrapSlider();

// Ajout de roles au user
$('.fa-plus').click(function(data){
  $(".modal-role-user").modal('show');
  modalPosition(modalContent, data.clientY + 350);
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

// update de la profile picture
$('.edit-profile-picture').click(function(data){
  $(".modal-update-profile-picture").modal('show');
  var modalContent = document.querySelector(".modal-update-profile-picture");
  modalPosition(modalContent, data.clientY + 300);
});

// edit de working_hours
$('.modify-working-hours').click(function(data){
  $(".modal-edit-working-hours").modal('show');
  var modalContent = document.querySelector(".modal-edit-working-hours");
  modalPosition(modalContent, data.clientY + 300);
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
    $('.category').removeClass("checked");
    var modalContent = document.querySelector(".modal-constraint");
    modalPosition(modalContent, jsEvent.clientY);
    $(".modal-constraint").modal('show');
    $('.constraint_form').show();
    $('.update_constraint').hide();
    $('.delete_constraint').hide();
    $('.days-list').show();
    // set default value of the date inputs (inside simple form)
    $('#datetimepicker1').datetimepicker({
      locale: 'FR'
     });
    $('#datetimepicker1 .form-control').val(new Date(start.format()).toLocaleDateString('fr-FR', {timezone: 'UTC', hour: '2-digit', minute: '2-digit'}));
    $('#datetimepicker2 .form-control').val(new Date(end.format()).toLocaleDateString('fr-FR', {timezone: 'UTC', hour: '2-digit', minute: '2-digit'}));
    $('#datetimepicker2').datetimepicker({
      locale: 'FR'
     });
    // comportement lors de la sélection d'une catégorie
    $('.category').click( function (data){
      $('#0').removeClass('checked');
      $('#1').removeClass('checked');
      $('#2').removeClass('checked');
      $(this).toggleClass('checked');
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

  eventResize: function( event, delta, revertFunc, jsEvent, ui, view ) {
    var constraint_id = event.id;
    console.log(event);
    var user_id = event.user_id;
    var build_url = "/users/" + user_id + "/constraints/" + constraint_id;
     constraint_data = {
      constraint: {
          id: constraint_id,
          start_at: event.start.format(),
          end_at: event.end.format(),
          category: event.title
        }
    };
    $.ajax({
      url: build_url,
      data: constraint_data,
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
   }, // fin eventResize

   eventClick: function( calEvent, jsEvent, view) {
      // initializations
      $('.update_constraint').unbind();
      $('.delete_constraint').unbind();
      $('.category').removeClass("checked");
      var modalContent = document.querySelector(".modal-update-constraint");
      modalPosition(modalContent, jsEvent.clientY);
      $(this).css('border-color', 'red');
      $(this).css('border-width', 'thick');
      $(".modal-update-constraint").modal('show');
      $('.create_constraint').hide();
      $('.update_constraint').show();
      $('.delete_constraint').show();
      $('.days-list').hide();
      // get variables
      var constraint_id = calEvent.id;
      var category_initial = calEvent.title;
      $('.'+category_initial).addClass("checked");
      var start_date = new Date(calEvent.start.format());
      var start_date = new Date(start_date.setHours(start_date.getHours() ));
      var end_date = new Date(calEvent.end.format());
      var end_date = new Date(end_date.setHours(end_date.getHours() ));
      // comportement lors de la sélection d'une catégorie
      $('.category').click( function (data){
        $('#0').removeClass("checked");
        $('#1').removeClass("checked");
        $('#2').removeClass("checked");
        $(this).addClass("checked");
      });
      // set default values to the form
      $('#datetimepicker1 .form-control').val(start_date.toLocaleDateString('fr-FR', {timezone: 'UTC', hour: '2-digit', minute: '2-digit'}));
      $("#datetimepicker1").datetimepicker({
        locale: 'FR'
      });
      $('#datetimepicker2 .form-control').val(end_date.toLocaleDateString('fr-FR', {timezone: 'UTC', hour: '2-digit', minute: '2-digit'}));
      $("#datetimepicker2").datetimepicker({
        locale: 'FR'
      });


      $('.update_constraint').off('click', function() {
      });

      // when clicking on update_slot
      $(".update_constraint").click( function (){
        var user_id = calEvent.user_id;
        var constraint_id = calEvent.id;
        var build_url = "/users/" + user_id + "/constraints/" + constraint_id;
        var category_selected = document.getElementsByClassName('category checked')[0].innerText.replace(/ /g,"");
        var start_chosen = $("#datetimepicker1").find("input").val();
        var end_chosen = $("#datetimepicker2").find("input").val();
        constraint_data = {
              constraint: {
                  id: constraint_id,
                  user_id: calEvent.user_id,
                  start_at: start_chosen,
                  end_at: end_chosen,
                  category: category_selected
                }
            };

        $.ajax({
          url: build_url,
          data: constraint_data,
          format: 'js',
          type: 'PATCH',
          success: function(data) {
            location.reload();
          },
          error: function(jqXHR) {
            console.log("ajax echec - PATCH de Constraint");
            console.log(jqXHR.responseText);
          }
        }); // fin ajax request
      }); // fin de update_slot
      $(".delete_constraint").click( function (){
        var user_id = calEvent.user_id;
        var constraint_id = calEvent.id;
        var build_url = "/users/" + user_id + "/constraints/" + constraint_id;
        constraint_data = {
              constraint: {
                  id: constraint_id,
                  user_id: calEvent.user_id
                }
            };

        $.ajax({
          url: build_url,
          data: constraint_data,
          format: 'js',
          type: 'DELETE',
          success: function(data) {
            location.reload();
          },
          error: function(jqXHR) {
            console.log("ajax echec - PATCH de Constraint");
            console.log(jqXHR.responseText);
          }
        }); // fin ajax request
      }); // fin de delete_slot
    }, // fin de eventClick

    eventDrop: function(event, delat, revertFunc){
      var user_id = event.user_id;
      var constraint_id = event.id;
      var build_url = "/users/" + user_id + "/constraints/" + constraint_id;
      var category = event.title;
      var start = event.start;
      var end = event.end;
      constraint_data = {
            constraint: {
                id: constraint_id,
                user_id: user_id,
                start_at: start.format(),
                end_at: end.format(),
                category: category
              }
          };
      $.ajax({
        url: build_url,
        data: constraint_data,
        format: 'js',
        type: 'PATCH',
        success: function(data) {
          console.log(Event);
        },
        error: function(jqXHR) {
          console.log("ajax echec - PATCH de eventDrop");
          console.log(jqXHR.responseText);
        }
      });
    }, // fin eventDrop


  });
}
