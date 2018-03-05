class MainController < ApplicationController
  before_action {
  	@attributes = Calculate::DATA_ATTRIBUTE_NAMES
  	@attribute_labels = Calculate::DATA_ATTRIBUTE_LABEL_NAMES
  }

  def index
  end

  def create
  	@input_numbers = params[:data][:input].split(',').map { |obj| obj.to_i }
    calc = Calculate.new(@input_numbers, permitted_params.to_h.map { |key, value| key if value == "1" })

  	el_count = @input_numbers.count
  	@results = calc.calculate
  	@input_labels = Array.new(el_count) { |i| i }
  	@mean = Array.new(el_count) { |i| @results["mean"] } if @results["mean"]
  	@standard_deviation = Array.new(el_count) { |i| @results["standard_deviation"] } if @results["standard_deviation"]
  	render partial: "statistic"
  end

  def permitted_params
  	params.require(:attr).permit(@attributes)
  end
end