# CHARTS
# Input Data Chart
@idc = (inputLabels, inputNumbers, mean, standart_deviation, up_standart_deviation) ->
  ctx = document.getElementById('inputData').getContext('2d')
  numberOfPointsRadiusSize = 3 - Math.log10(inputNumbers.length)
  chart = new Chart(ctx,
   type: 'line'
   data:
    labels: inputLabels
    datasets: [{
      label: 'Входные данные'
      backgroundColor: 'rgba(255, 255, 255, 0)'
      borderColor: 'rgb(255, 99, 132)'
      borderWidth: numberOfPointsRadiusSize < 1 ? 1 : numberOfPointsRadiusSize
      data: inputNumbers
    } ]
  	options: {
     elements: {
      point: {
       radius: numberOfPointsRadiusSize
      }
     }
     scales: {
      xAxes: [{
       ticks:
         autoSkip: true
         maxTicksLimit: 24
      }]
     }
     annotation: {
      annotations: [{
        type: 'line'
        mode: 'horizontal'
        scaleID: 'y-axis-0'
        value: mean
        borderColor: 'rgb(75, 192, 192)'
        borderWidth: 1
        borderDash: [20, 10]
        label: {
          backgroundColor: 'rgba(0,0,0,0)'
          fontColor: 'rgba(0,0,0,1)'
          enabled: true
          cornerRadius: 0
          yAdjust: -14
          content: 'Среднее значение'
        }
      }
      {
        type: 'line'
        mode: 'horizontal'
        scaleID: 'y-axis-0'
        value: standart_deviation
        borderColor: 'rgb(0, 190, 20)'
        borderWidth: 1
        borderDash: [20, 10]
        label: {
          backgroundColor: 'rgba(0,0,0,0)'
          fontColor: 'rgba(0,0,0,1)'
          enabled: true
          cornerRadius: 0
          yAdjust: 14
          content: 'Стандартное отклонение'
        }
      }
      {
        type: 'line'
        mode: 'horizontal'
        scaleID: 'y-axis-0'
        value: up_standart_deviation
        borderColor: 'rgb(0, 190, 20)'
        borderWidth: 1
        borderDash: [20, 10]
        label: {
          backgroundColor: 'rgba(0,0,0,0)'
          fontColor: 'rgba(0,0,0,1)'
          enabled: false
          cornerRadius: 0
          yAdjust: -14
          content: 'Стандартное отклонение'
        }
      } 
      ]
     }
    })


# Input Data Spectre
@ids = (inputLabels, inputNumbers) ->
  ctx = document.getElementById('spectre').getContext('2d')
  numberOfPointsRadiusSize = 3 - Math.log10(inputNumbers.length)
  chart = new Chart(ctx,
   type: 'bar'
   data:
    labels: inputLabels
    datasets: [{
      label: 'Входные данные'
      backgroundColor: 'rgba(65, 118, 164, 1)'
      data: inputNumbers
    } ]
   options: {
     scales: {
      xAxes: [{
       barThickness: 1
       ticks:
         autoSkip: true
         maxTicksLimit: 24
      }]
     }
     pan: {
      enabled: true
      mode: 'xy'
     }
     zoom: {
      enabled: true
      mode: 'xy'
     }
    })

# Input Data Histogramm
@idh = (inputLabels, inputNumbers) ->
  ctx = document.getElementById('historgram').getContext('2d')
  chart = new Chart(ctx,
   type: 'bar'
   data:
    labels: inputLabels
    datasets: [{
      label: 'Входные данные'
      backgroundColor: 'rgba(65, 168, 114, 1)'
      data: inputNumbers
    } ]
   options: {
     scales: {
      xAxes: [{
       barThickness: 15
       ticks:
         autoSkip: true
         maxTicksLimit: 24
      }]
     }
     pan: {
      enabled: true
      mode: 'xy'
     }
     zoom: {
      enabled: true
      mode: 'xy'
     }
    })


# FILE PARSE
@handleFiles = (files) ->
  file = files[0];

  reader = new FileReader
  reader.onload = do (reader) ->
   ->
    document.getElementById('hidden-data').value = reader.result
    $('.input-data-form').submit();
    return
  reader.readAsText file


# END OF CHARTS
# --------------------


$(document).ready ->
  # SUBMIT FORM
  $(".input-data-form").on("ajax:success", (e, data, status, xhr) ->
    $('.tab-statistic, .tab-graphic, .tab-spectre, .tab-histogram').remove()
    $('.tabs-content').append(xhr.responseText)
    $('.active-tab-content').removeClass('active-tab-content')
    $('.' + $('.tabs .btn-primary').data('tab-name')).addClass 'active-tab-content'
    $('#input').val('')
  ).on "ajax:error", (e, xhr, status, error) ->
    $('.statistic-results').empty()
    $('.statistic-results').append(error)

  # SUBMIT BUTTON
  $('.submit-form-button').click (e) ->
    e.preventDefault()
    $('.input-data-form').submit()
    return


  # TAB CLICK
  $('.tabs .btn-secondary').click (e) ->
    e.preventDefault()
    $('.tabs .btn-primary').removeClass('btn-primary')
    $(this).addClass 'btn-primary'
    $('.active-tab-content').removeClass 'active-tab-content'
    $('.' + $(this).data('tab-name')).addClass 'active-tab-content'
    return

  # CHECKOBOX CHANGED
  $('.input-data-form input').change ->
    $('.input-data-form').submit();