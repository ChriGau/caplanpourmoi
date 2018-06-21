// Load the Visualization API and the corechart package.
      google.charts.load('current', {'packages':['corechart']});

      // Set a callback to run when the Google Visualization API is loaded.
      google.charts.setOnLoadCallback(drawChart);

      // Callback that creates and populates a data table,
      // instantiates the pie chart, passes in the data and
      // draws it.
      function drawChart() {

        // Create the data table.
        var data = new google.visualization.DataTable();
        data.addColumn('string', 'T');
        data.addColumn('number', 'Length');
        data.addRows([
          ['T1-create ComputeSolution', t1],
          ['T2-start CreateSlotgroupsService',t2],
          ['T3-end CreateSlotgroupsService', t3],
          ['T4-start GoFindSolutionsService', t4],
          ['T5-start pick_best_solution', t5],
          ['T6-start SaveSolutionsAndSolutionSlotsService', t6],
          ['T7-end SaveSolutionsAndSolutionSlotsService', t7]
        ]);

        // Set chart options
        var options = {'title':'ALGO - Responses Times',
                       'width':400,
                       'height':300};

        // Instantiate and draw our chart, passing in some options.
        var chart = new google.visualization.PieChart(document.getElementById('chart'));
        chart.draw(data, options);
      }

      google.charts.load('current', {'packages':['table']});
      google.charts.setOnLoadCallback(drawTable);

      function drawTable() {
        var data = new google.visualization.DataTable();
        data.addColumn('string', 'when');
        data.addColumn('string', 'what');
        data.addColumn('string', 'Timestamp');
        data.addColumn('number', 'Length(sec)');
        data.addColumn('number', 'Length//start (sec)');
        data.addColumn('number', '% of total length');
        data.addRows([
          row1, row2, row3, row4, row5, row6, row7
        ]);

        var table = new google.visualization.Table(document.getElementById('table_div'));

        table.draw(data, {showRowNumber: true, width: '100%', height: '100%'});
      }
