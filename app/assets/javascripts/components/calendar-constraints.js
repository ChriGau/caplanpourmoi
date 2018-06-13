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
    console.log(a);
    $(a).toggleClass("checked");
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
