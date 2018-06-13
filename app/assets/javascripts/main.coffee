# CHARTS
# Input Data Chart
@idc = (inputLabels, inputNumbers, id, mean, standart_deviation, up_standart_deviation) ->
  ctx = document.getElementById(id).getContext('2d')
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
@sss = (inputLabels, inputNumbers, id = 'simple_spectrum') ->
  ctx = document.getElementById(id).getContext('2d')
  chart = new Chart(ctx,
   type: 'bar'
   data:
    labels: inputLabels
    datasets: [{
      label: 'Значение'
      backgroundColor: 'rgba(65, 118, 164, 1)'
      data: inputNumbers
    } ]
   options: {
     scales: {
      yAxes: [{
        display: true,
        ticks: {
            suggestedMin: 0
            beginAtZero: true
        }
      }]
      xAxes: [{
       barThickness: 2
       ticks: {
         autoSkip: true
         maxTicksLimit: 24
        }
      }]
     }
     pan: {
      enabled: true
      mode: 'xy'
     }
    })

@ssh = (inputLabels, inputNumbers) ->
  ctx = document.getElementById('simple_histogram').getContext('2d')
  chart = new Chart(ctx,
   type: 'bar'
   data:
    legend: {
      position: 'right'
    }
    labels: inputLabels
    datasets: [{
      label: 'Количество вхождений'
      backgroundColor: 'rgba(65, 118, 164, 1)'
      data: inputNumbers
    } ]
   options: {
     scales: {
      xAxes: [{
       barPercentage: 1.0
       categoryPercentage: 0.9
       ticks:
         autoSkip: true
         maxTicksLimit: 10
      }]
      yAxes: [{
        ticks: {
            beginAtZero: true
        }
      }]
     }
     pan: {
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


# SIGNAL SIMPEL GRAPHIC
@ssg = (inputLabels, inputNumbers) ->
  ctx = document.getElementById('simple_graphic').getContext('2d')
  chart = new Chart(ctx,
    type: 'line'
    data:
      labels: inputLabels
      datasets: [{
        label: 'Входные данные'
        backgroundColor: 'rgba(255, 255, 255, 0)'
        borderColor: 'rgb(255, 99, 132)'
        borderWidth: 2
        data: inputNumbers
      } ]
    options: {
     elements: {
      point: {
       radius: 0
      }
     }
     scales: {
      xAxes: [{
       ticks:
         autoSkip: true
         maxTicksLimit: 24
      }]
     }
    })

# SIGNAL CORRELATION GRAPHIC
@scg = (inputLabels, inputNumbers) ->
  ctx = document.getElementById('simple_correlation').getContext('2d')
  chart = new Chart(ctx,
    type: 'line'
    data:
      labels: inputLabels
      datasets: [{
        label: 'Входные данные'
        backgroundColor: 'rgba(255, 255, 255, 0)'
        borderColor: 'rgb(255, 99, 132)'
        borderWidth: 2
        data: inputNumbers
      } ]
    options: {
     elements: {
      point: {
       radius: 0
      }
     }
     scales: {
      xAxes: [{
       ticks:
         autoSkip: true
         maxTicksLimit: 24
      }]
     }
    })


# STATISTC FILE PARSE
file = null
@showAlert = (clsName) ->
  $(clsName).fadeIn(200)
  setTimeout (->
    $(clsName).fadeOut(200)
    return
  ), 3000

@handleFilesStatistic = (ths) ->
  fl = ths.files[0]
  extension = fl.name.split('.').slice(-1)[0]
  if fl && extension == 'txt'
    showAlert('.file-upload-container .alert-success')
    file = fl
    console.log(file)
    $('.additional').remove();
  else if fl
    showAlert('.file-upload-container .alert-danger')

@tabClick = (ths, url) ->
  if file || $(ths).attr("id")
    ths = $(ths);
    clsName = '.' + ths.data('tab-name')
    $('.tabs .btn-primary').removeClass('btn-primary')
    ths.addClass 'btn-primary'
    $('.active-tab-content').removeClass 'active-tab-content'
    if url && !$(clsName).length
      send_query(url, clsName)
    else
      $(clsName).addClass 'active-tab-content'
  else
    BootstrapDialog.show
      title: 'Предупреждение'
      message: 'Добавьте файл для доступа к данной странице'
      type: 'type-warning'

get_and_delete_names = (name, data) ->
  name.each ->
    data.delete $(this).attr('name')
    return
  return data

clean_unwanted_data = (url, data) ->
  if url != "periodogramma"
    data = get_and_delete_names($(".form-control[name*='data['"), data)
  if url != "statistic"
    data = get_and_delete_names($("input[name*='attr['"), data)

  return data

send_query = (url, clsName) ->
  $("#popup").show(0)
  data = new FormData(document.querySelector('form'))
  data.append 'file-0', file

  data = clean_unwanted_data(url, data)
  
  $.ajax
    url: url
    data: data
    cache: false
    contentType: false
    processData: false
    method: 'POST'
    success: (data) ->
      $('.tabs-content').append(data)
      $(clsName).addClass 'active-tab-content'
    error: (data) ->
      file = null
      $('.upload').val('')
      tabClick($("#main_tab"))
      BootstrapDialog.show
        title: 'Предупреждение'
        message: data.responseJSON
        type: 'type-warning'
    complete: ->
      $("#popup").hide(0)
  return













# SIGNAL FILE PARSE
@handleFilesSignal = (ths) ->
  data = new FormData
  data.append 'file-0', ths.files[0]
  $.ajax
    url: 'parse_signal'
    data: data
    cache: false
    contentType: false
    processData: false
    method: 'POST'
    success: (data) ->
      $('.tab-graphic, .tab-spectre, .tab-histogram').remove
      console.log data
      $('.tabs-content').append data
      $('.active-tab-content').removeClass('active-tab-content')
      $('.' + $('.tabs .btn-primary').data('tab-name')).addClass 'active-tab-content'
      return
    complete: ->
      ths.value = ''
      return
  return

# END OF CHARTS
# --------------------


$(document).ready ->
  # SUBMIT FORM
  $(".input-data-form").on("ajax:success", (e, data, status, xhr) ->
    $('.tab-statistic, .tab-graphic').remove()
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

  # CHECKOBOX CHANGED
  $('.input-data-form input').change ->
    $('.tab-statistic').remove();

  $('.additional-form input').change ->
    $('.tab-periodgramma').remove();


  # MENU ACTIVE
  $('.main-menu li[data-url="' + window.location.pathname + '"').addClass 'active'

  $('.menu-option input').change ->
    data_name = $(this).data('tab-name')
    item = $('.tabs .tab[data-tab-name=\'' + data_name + '\']')
    if $(this).is(':checked')
      item.show()
    else
      item.hide()
    return

  $('.mmp').change ->
    $('.tab-periodgramma').remove();