// accordion
var acc = document.getElementsByClassName("accordion");
var i;

for (i = 0; i < acc.length; i++) {
  acc[i].addEventListener("click", function() {
      /* Toggle between adding and removing the "active" class,
      to highlight the button that controls the panel */
      this.classList.toggle("active");

      /* Toggle between hiding and showing the active panel */
      var panel = this.nextElementSibling;
      if (panel.style.display === "block") {
          panel.style.display = "none";
      } else {
          panel.style.display = "block";
      }
  });
}

// simulateur

var btn = document.getElementsByClassName('btn-action');
btn[0].addEventListener("click", function(){
  var nb_slots = parseInt($("#name").val());
  length =  go_through * nb_slots * tree_covered + storing * nb_slots;
  $(".result").html(Math.round(length, 6) + " seconds");
})

// tableau des 15

google.charts.load('current', {'packages':['table']});
google.charts.setOnLoadCallback(drawTable);

function drawTable() {
  var data = new google.visualization.DataTable();

  data.addColumn('number', 'ComputeSolution ID');
  data.addColumn('number', 'Planing Week');
  data.addColumn('number', 'Temps total (sec)');
  data.addColumn('number', 'Succès? (1 : oui, 0 : non');
  data.addColumn('number', 'Nombre de slots');
  data.addColumn('number', 'Nombre de users');
  data.addColumn('number', 'Nombre d\'itérations');
  data.addColumn('number', '%tree covered');
  data.addRows(rows_table);

  var table = new google.visualization.Table(document.getElementById('table_div'));

  table.draw(data, {showRowNumber: true, width: '100%', height: '100%'});
}

// bar chart

google.charts.load("current", {packages:['corechart']});
google.charts.setOnLoadCallback(drawChart);
function drawChart() {
  rows_chart[0] = ["week number", "number of calculations"];
  var data = google.visualization.arrayToDataTable(rows_chart);
  var view = new google.visualization.DataView(data);
  var options = {
    title: "Nombre de calculs lancés",
    width: 600,
    height: 400,
    bar: {groupWidth: "95%"},
    legend: { position: "none" },
  };
  var chart = new google.visualization.ColumnChart(document.getElementById("columnchart_values"));
  chart.draw(view, options);
}
