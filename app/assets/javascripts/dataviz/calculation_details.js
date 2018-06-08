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
