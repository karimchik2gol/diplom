# coding: UTF-8
require 'wavefile'
require 'cmath'

class Calculate
  DATA_ATTRIBUTE_NAMES =
  	[:mean, :median, :mode, :min, :max, :variance, :standard_deviation, :relative_standard_deviation, :skewness, :kurtosis]

  DATA_ATTRIBUTE_LABEL_NAMES = {
	   mean: 'Среднее значение',
	   median: 'Медиана', 
	   mode: 'Мода',
	   min: 'Минимальное значение',
	   max: 'Максимальное', 
	   variance: 'Дисперсия', 
	   standard_deviation: 'Стандартное отклонение',
	   relative_standard_deviation: 'Относительное стандартное отклонение', 
	   skewness: 'Асимметрия', 
	   kurtosis: 'Коэффициент эксцесса'
  }
 
  ROUND_BY = 5
  NUMBER_OF_HISTOGRAM_BARS = 10
  SAMPLES = 64

  attr_accessor :stats, :options

  def initialize(stats, options)
  	self.stats = DescriptiveStatistics::Stats.new(stats)
  	self.options = options
  end

  def calculate
  	result = {}
  	options.each do |option|
  		res = @stats.send(option)
  		res = res.round(ROUND_BY) if res
  		result[option] = res
  	end
  	result
  end

  def generate_random_numbers
    f = 0.2 # random frequency
    n = 64 # random n
    stats = []
    n.times do |x|
      stats << Math.sin(2 * Math::PI * f * x)
    end
    stats
  end

  def spectrum_and_graph(dynamic_stat = nil)
    spectrum, labels = [], []
    data = (dynamic_stat || stats).clone
    #puts data
    length = data.count
    xx = Mysignal.fft(data, length)

    length.times do |i|
      spectrum << xx[i].abs.round(5)
      labels << i + 1 unless dynamic_stat
    end

    #puts spectrum
    return spectrum, labels
  end


  def histograma
    numbers, labels = [], []
    min = stats.min
    max = stats.max
    raznica = max - min
    length = stats.count
    count_of_rows =  length > 100 ? 10 : 5 + length / 20 

    count_of_rows.times do |current_row|
      condition_down = min + raznica * current_row / count_of_rows
      condition_up = min + raznica * (current_row + 1) / count_of_rows
      numbers << (stats.select { |x| x if x >= condition_down && (x < condition_up || current_row == count_of_rows - 1) }).count # check if last then automatically add everything that higher that down condition
      labels << "#{condition_down} - #{condition_up}"
    end

    return numbers, labels
  end


  def correlation
    correlation, label = [], []
    length = stats.count
    length.times do |i|
      if i < length - 1 # don't add last element
        sum = 0
        length.times do |j|
          if j > i
            up_array = stats[j]
            down_array = stats[j - i - 1] # starting from the bottom
            sum += up_array * down_array
          end
        end

        correlation << (sum.to_f / stats.count)
        label << i + 1
      end
    end

    return correlation, label
  end

  def periodgramma
    number_of_items = stats.count
    number_of_periods = 4
    items_in_section = number_of_items / number_of_periods
    periodogram = Array.new(items_in_section) { 0 }
    label = Array.new(items_in_section) { |i| i + 1 }

    number_of_periods.times do |i|
      j = 0
      from =  number_of_items * i / number_of_periods
      to = number_of_items * (i + 1) / number_of_periods - 1
  
      spectrum_and_graph(stats[from..to])[0].each do |l|
        periodogram[j] += l.to_f / number_of_periods # average value
        j += 1
      end
    end

    return periodogram, label
  end

  def mixed_spectre
    return {rectangle: rectangle[0], triangle: triangle[0], sinusoid: sinusoid[0]}
  end

  private
  def rectangle
    local_stats = stats.dup
    last_point = local_stats.count / 2 # сторона - половина длины набора

    return spectrum_and_graph(local_stats.each_with_index.map { |x, i| i < last_point ? x * last_point : x })
  end

  def triangle
    local_stats = stats.dup
    last_point = local_stats.count # катет - полная длины набора (равнобедренный треугольник)
    cos = Math.cos(45 * Math::PI / 180)

    return spectrum_and_graph(local_stats.each_with_index.map { |x, i| x * i * cos })
  end

  def sinusoid
    local_stats = stats.dup
    last_point = local_stats.count # синусоида - 1 такт

    return spectrum_and_graph(local_stats.each_with_index.map { |x, i| x * Math.sin((i.to_f / last_point) * i * Math::PI) })
  end
end