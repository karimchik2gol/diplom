class Calculate
  DATA_ATTRIBUTE_NAMES =
  	[:mean, :median, :mode, :min, :max, :variance, :standard_deviation, :relative_standard_deviation, :skewness, :kurtosis]

  DATA_ATTRIBUTE_LABEL_NAMES = {
	   mean: 'Среднее число',
	   median: 'Медианна', 
	   mode: 'Мода',
	   min: 'Минимальное значение',
	   max: 'Максимальное', 
	   variance: 'Дисперсия', 
	   standard_deviation: 'Стандартное отклонение',
	   relative_standard_deviation: 'Относительное стандартное отклонение', 
	   skewness: 'Ассиметрия', 
	   kurtosis: 'Коэффициент эксцесса'
  }
 
  ROUND_BY = 5


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
end