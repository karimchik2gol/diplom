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
  	@input_numbers = params[:data][:input].split(',').map { |obj| obj.to_i }
    perm_par = permitted_params.to_h.delete_if { |key, value| value == "0" }.map {|k,v| k}
    perm_par << "mean" << "standard_deviation" # Added by default!!
    calc = Calculate.new(@input_numbers, perm_par)

  	el_count = @input_numbers.count # Element count for graphic CHART JS
  	@results = calc.calculate # Calculate statistic
  	@input_labels = Array.new(el_count) { |i| i } # Chart js labels
  	@mean = @results["mean"]
  	@standard_deviation = @results["standard_deviation"]
    @up_standard_deviation = 2 * @mean - @standard_deviation
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

  def permitted_params
  	params.require(:attr).permit(@attributes)
  end
end