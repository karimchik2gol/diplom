class MainController < ApplicationController
  before_action {
  	@attributes = Calculate::DATA_ATTRIBUTE_NAMES
  	@attribute_labels = Calculate::DATA_ATTRIBUTE_LABEL_NAMES
  }

  def index
  end

  def signal
  end

  def create
  	@input_numbers = File.open(params["file-0"].path).read.split(',').map { |obj| obj.to_i }
    perm_par = permitted_params.to_h.delete_if { |key, value| value == "0" }.map {|k,v| k}
    perm_par << "mean" << "standard_deviation" # Added by default!!
    calc = Calculate.new(@input_numbers.dup, perm_par)

  	el_count = @input_numbers.count # Element count for graphic CHART JS
  	@results = calc.calculate # Calculate statistic
  	@input_labels = Array.new(el_count) { |i| i + 1 } # Chart js. srtar from 1
  	@mean = @results["mean"]
  	@standard_deviation = @results["standard_deviation"]
    @up_standard_deviation = 2 * @mean - @standard_deviation

    @spectrum, @spectrum_label = calc.spectrum_and_graph
    @histograma, @histograma_label = calc.histograma
    @correlation, @correlation_label = calc.correlation
    @periodgramma, @periodgramma_label = calc.periodgramma

    @mixed_spectre = calc.mixed_spectre

  	render partial: "statistic"
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