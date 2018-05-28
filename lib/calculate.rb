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

  def initialize(stats, options = nil)
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

    (length / 2).times do |i|
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
    count_of_rows = length > 100 ? 10 : 5 + length / 20 

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
    # 64 ticks, put length for full correlation
    default_length = length > 64 ? 64 : length
    default_length.times do |i|
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

  def periodgramma(dlina, smechenie, dlinabpf, vidokna)
    number_of_items = stats.count
    puts number_of_items
    number_of_periods = number_of_items / dlina
    periodogram = Array.new(dlina / 2) { 0 }
    label = Array.new(dlina / 2) { |i| i + 1 }

    if vidokna == "rectangle"
      local_stats = stats.each_with_index.map { |x, i| i < number_of_items ? x * number_of_items : x }
    elsif vidokna == "triangle"
      cos = Math.cos(45 * Math::PI / 180)
      local_stats = stats[0..number_of_items / 2 - 1].each_with_index.map { |x, i| x * i / cos }
      local_stats.concat(stats[number_of_items / 2..number_of_items].each_with_index.map { |x, i| x * (number_of_items / 2 + i) / cos })
    end
    local_stats ||= stats

    number_of_periods.times do |i|
      j = 0
      from = smechenie + number_of_items * i / number_of_periods
      to = smechenie + number_of_items * (i + 1) / number_of_periods - 1
        
      total_array = local_stats[from..to]
      (dlina - total_array.count).times { total_array << 0 } if total_array.count < dlina

      xx = Mysignal.fft(total_array, dlina)

      (dlina / 2).times do |i|
        periodogram[j] += xx[i].abs.round(5).to_f / number_of_periods 
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
    last_point = local_stats.count # сторона - половина длины набора

    return 
  end

  def triangle
    local_stats = stats.dup
    last_point = local_stats.count # катет - полная длины набора (равнобедренный треугольник)
    cos = Math.cos(45 * Math::PI / 180)

    return spectrum_and_graph()
  end
end