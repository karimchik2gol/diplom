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
    n = (1 + 3.322 * Math.log(length)).to_i
    interval = raznica.to_f / n
    n.times do |current_row|
      condition_down = min + current_row * interval
      condition_up = min + (current_row + 1) * interval
      numbers << (stats.select { |x| x if x >= condition_down && (x < condition_up || current_row == n - 1) }).count # check if last then automatically add everything that higher that down condition
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
    number_of_periods = number_of_items / dlina
    periodogram = Array.new(dlina / 2) { 0 }
    label = Array.new(dlina / 2) { |i| i + 1 }

    local_stats = send(vidokna.to_sym, stats, number_of_items) if vidokna && !vidokna.empty?
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
  def rectangle(stats, number_of_items)
    return stats.map { |x| x * 1 }
  end

  def triangle(stats, number_of_items)
    return stats.each_with_index.map { |x, i| x * barlet_function(i, number_of_items) }
  end

  def hamming(stats, number_of_items)
    return stats.each_with_index.map { |x, i| x * hamming_function(i, number_of_items)  }
  end

  def blackman(stats, number_of_items)
    return stats.each_with_index.map { |x, i| x * blackman_function(i, number_of_items)  }
  end

  def hamming_function(i, n)
    return 0.53836 - 0.46164 * Math.cos(2 * Math::PI * i / (n - 1))
  end

  def barlet_function(i, n)
    a = (n - 1) / 2
    return 1 - ((n.to_f / a) - 1).abs
  end

  def blackman_function(i, n)
    alpha = 0.16
    a0 = (1 - alpha) / 2
    a1 = 1 / 2
    a2 = alpha / 2
    return a0 - a1 * Math.cos(2 * Math::PI * i / (n - 1)) + a2 * Math.cos(4 * Math::PI * i / (n - 1))
  end
end