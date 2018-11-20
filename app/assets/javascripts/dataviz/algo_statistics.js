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

// column chart

google.charts.load("current", {packages:['corechart']});
google.charts.setOnLoadCallback(drawColumnChart);
function drawColumnChart() {
  rows_chart[0] = ["week number", "number of calculations"];
  console.log(rows_chart);
  var data = google.visualization.arrayToDataTable(rows_chart);
  var view = new google.visualization.DataView(data);
  var options = {
    title: "Nombre de calculs lancés par semaine",
    width: 600,
    height: 400,
    bar: {groupWidth: "95%"},
    legend: { position: "none" },
  };
  var chart = new google.visualization.ColumnChart(document.getElementById("columnchart_values"));
  chart.draw(view, options);
}

// line chart - evolution total mean time

google.charts.load('current', {'packages':['corechart']});
google.charts.setOnLoadCallback(drawChart);

function drawChart() {
  rows_curve_chart[0] = ["AlgoStat ID", "length (seconds)"];
  var data = google.visualization.arrayToDataTable(
    rows_curve_chart
  );

  var options = {
    title: 'Temps moyen de recherche de solution par slot (par AlgoStat)',
    curveType: 'function',
    legend: { position: 'bottom' },
  };

  var curve_chart = new google.visualization.LineChart(document.getElementById('curve_chart'));

  curve_chart.draw(data, options);
}
