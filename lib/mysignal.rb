# coding: UTF-8
require 'wavefile'
require 'cmath'

class Mysignal
	attr_accessor :file, :time, :labels, :samples, :sample_rate, :freq_resolution, :whole_signal_length, :histogram_frequency, :amplitude_frequency, :tau

	def initialize(file, time, histogram_frequency)
		self.tau = 5
		self.file = file
		self.time = time
		self.histogram_frequency = histogram_frequency
		self.samples = 64
		self.sample_rate = samples / time
		self.freq_resolution = sample_rate / samples
		self.whole_signal_length = time * samples
		self.labels = Array.new(samples) { |i| i + 1} #.to_f * time / whole_signal_length.to_f).round(3
		self.amplitude_frequency = []
		read_file
	end

	def draw_graphic
		spectrum_result = spectrum_and_graph
		histrogram_result = histogram
		correlation = correlation_function
		return [labels, spectrum_result[0], spectrum_result[1], histrogram_result[0], histrogram_result[1], correlation]
	end

	private
	def read_file
		text = File.open(file.path).read
		text.each_line do |line|
			splt_l = line.split(" ")
			amplitude = splt_l[0].to_f
			frequency = splt_l[1].to_f

			amplitude_frequency << [amplitude, frequency]
		end
	end

	def sin(i)
		xi = 0
		graphic = 0
		amplitude_frequency.each do |af|
			sin_func = Math.sin(2 * Math::PI * af[1] * i / samples)
			xi +=  sin_func
			graphic += af[0] * sin_func
		end
		return xi, graphic
	end

	#vzaimocorrelyaciya
	def correlation_function 
		correlation = []

		samples.times do |m|
			sum = 0
			samples.times do |n|
				sum += sin(n)[1] * sin(n + m)[1]
			end
			result = (1.0 / samples) * sum

			correlation << result
		end

		correlation
	end

	def histogram
		histogram_res = []
		histogram_labels = []
		histogram_frequency =  1024 # width gonna be 20
		histogram_frequency.times do |i|
			amplitude_frequency.each do |af|
				if (i % 64) == 0
					histogram_res << 0
					sin_func = Math.sin(2 * Math::PI * af[1] * i / histogram_frequency)
					histogram_res[histogram_res.count - 1] += sin_func
					histogram_labels << i + 1
				end
			end
			
			#end
		end
		return histogram_res, histogram_labels
	end

	def spectrum_and_graph
		result = []
		x = []
		xx = []
		graphic = []
		spectrum = []

		samples.times do |i|
			x << Complex(0.0, 0.0)

			xs, gs = sin(i)
			x << xs
			xx << xs

			graphic << gs 
		end

		xx = Mysignal.fft(xx, samples)

		# xy = []
		samples.times do |i|
		 	spectrum << xx[i].abs.round(5)
		# 	#xy << {y: x[i].real.round(3), x: xx[i].abs.round(5) }
		# 	#puts "#{Math.sqrt(xx[i].real ** 2 + xx[i].imaginary ** 2)}"
		# 	#puts "#{x[i].real} - #{xx[i].abs.round(5)}"
		# 	puts "#{180 * Math.atan(xx[i].abs.round(5) / x[i].real) / Math::PI}"
		end


		return graphic, spectrum
	end

	def self.fft(x, n)
		if n > 1 
			Mysignal.separate(x, n)

			Mysignal.fft(x, n / 2)
			x[n/2..n-1] = Mysignal.fft(x[n/2..n-1], n / 2)

			(n / 2).times do |k|
				e = x[k]
				o = x[k + n / 2]
				w = CMath.exp(Complex(0, -2 * Math::PI * k / n))

				x[k] = e + w * o
				x[k + n / 2] = e - w * o
				#puts e + w * o
			end
		end

		return x
	end

	def self.separate(a, n)
		# Сорируем. Вверх - парные элементы. Внизу - непарные
		b = []
		(n / 2).times.each { |i| b << a[i * 2 + 1] }
		(n / 2).times.each { |i| a[i] = a[i * 2] }
		(n / 2).times.each { |i| a[i + n / 2] = b[i] }
	end
end