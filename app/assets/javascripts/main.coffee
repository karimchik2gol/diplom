# CHARTS
# Input Data Chart
@idc = (inputLabels, inputNumbers, mean, standard_deviation) ->
  ctx = document.getElementById('inputData').getContext('2d')
  chart = new Chart(ctx,
   type: 'line'
   data:
    labels: inputLabels
    datasets: [ {
        label: 'Среднее отклонение'
        data: mean
        type: 'line'
        backgroundColor: 'rgba(255, 255, 255, 0)'
        borderColor: 'rgb(54, 162, 235)'
        borderDash: [10, 20]
    }
    {
        label: 'Стандартное отклонение'
        data: standard_deviation
        type: 'line'
        backgroundColor: 'rgba(255, 255, 255, 0)'
        borderColor: 'rgb(12, 202, 28)'
        borderDash: [10, 20]
    }
    {
      label: 'Входные данные'
      backgroundColor: 'rgba(255, 255, 255, 0)'
      borderColor: 'rgb(255, 99, 132)'
      data: inputNumbers
    } ]
  	options: {})

# Input Data Histogramm
colors = []
@idh = (inputLabels, inputNumbers) ->
  ctx = document.getElementById('historgramaInputData').getContext('2d')
  dynamicColors(inputNumbers.length)
  myPieChart = new Chart(ctx,
	  type: 'pie'
	  data: 
	   labels: inputLabels
	   datasets: [{
	    data: inputNumbers
	    backgroundColor: colors
	   }]
	  options: {})


# RANDOM COLOR CHART
dynamicColors = (num) ->
  i = 0
  while i < num
   r = Math.floor(Math.random() * 255)
   g = Math.floor(Math.random() * 255)
   b = Math.floor(Math.random() * 255)
   colors.push('rgb(' + r + ',' + g + ',' + b + ')')
   i++


# END OF CHARTS
# --------------------

# SUBMIT FORM
$(document).ready ->
  $("form[data-remote]").on("ajax:success", (e, data, status, xhr) ->
    $('.statistic-results').empty();
    $('.statistic-results').append(xhr.responseText)
  ).on "ajax:error", (e, xhr, status, error) ->
    $('.statistic-results').empty();
    $('.statistic-results').append(error)


