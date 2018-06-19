#coding: UTF-8
class MainController < ApplicationController
  before_action {
  	@attributes = Calculate::DATA_ATTRIBUTE_NAMES
  	@attribute_labels = Calculate::DATA_ATTRIBUTE_LABEL_NAMES
  }

  before_action :convert_file_to_numbers, only: [:create, :statistic, :graphic, :spectre, :histograma, :correlation, :periodogramma, :mmp]
  before_action :set_calculate, only: [:spectre, :histograma, :correlation, :periodogramma, :mmp]


  def validate_file
    path = params["file-0"].path
    if path.include?('.') && path.split('.')[-1] == 'txt'
      @file = File.open(params["file-0"].path).read.strip
      @txt = @file
      return true if @file.match(/^([\-\+]?[0-9]*(\.[0-9]+)?+,)+[\-\+]?[0-9]*(\.[0-9]+)?$/)
    end
    return false
  end

  def convert_file_to_numbers
    if validate_file
      @input_numbers = @file.split(',').map { |obj| obj.to_f }
    else
      error_message = 'Ваш текущий файл имеет не правильный формат или расширение.'
      render json: error_message.to_json, status: 404
    end
  end

  def set_calculate
    @calc = Calculate.new(@input_numbers.dup, nil)
  end

  def index
  end

  def signal
  end

  def create

    @mixed_spectre = calc.mixed_spectre

  	render partial: "statistic"
  end

  def statistic
    @l, @r = [], []
    perm_par = permitted_params.to_h.delete_if { |key, value| value == "0" }.map {|k,v| k}
    calc = Calculate.new(@input_numbers.dup, perm_par)
    @results = calc.calculate # Calculate statistic
    res = @results.to_a
    res.each {|x| res.index(x).even? ? @l << x : @r << x}
    render partial: "statistic"
  end

  def graphic
    calc = Calculate.new(@input_numbers.dup, ["mean", "standard_deviation"])
    @input_labels = Array.new(@input_numbers.count) { |i| i + 1 } # Chart js. srtar from 1
    @results = calc.calculate # Calculate statistic
    @mean = @results["mean"]
    @standard_deviation = @results["standard_deviation"]
    @up_standard_deviation = 2 * @mean - @standard_deviation
    
    render partial: "graphic"
  end

  def spectre
    @spectrum, @spectrum_label = @calc.spectrum_and_graph
    render partial: "spectre"
  end

  def histograma
    @histograma, @histograma_label = @calc.histograma
    render partial: "histograma"
  end

  def correlation
    @correlation, @correlation_label = @calc.correlation
    render partial: "correlation"
  end

  def periodogramma
    data = params[:data]
    @periodgramma, @periodgramma_label = @calc.periodgramma(data[:dlina].to_i, data[:smechenie].to_i, data[:dlinabpf].to_i, data[:vidokna])
    render partial: "periodgramma"
  end

  def mmp
    
  end

  def parse_signal
    file = params["file-0"]
    time = 1
    histogram_frequency = 200
    signal = Mysignal.new(file, time, histogram_frequency)
    @graphic = signal.draw_graphic
    render partial: "signal_graphic"
  end


  def generate_file
    length = (params[:length] || 1024).to_i # if user set lengt in params
    nums = []
    length.times do
      nums << rand(0..50)
    end

    text = nums.join(', ')

    File.open("numbers.txt", "w+") do |f|
      f.write(text)
    end

    redirect_to root_url
  end

  def permitted_params
  	params.require(:attr).permit(@attributes)
  end
end