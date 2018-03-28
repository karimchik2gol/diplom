N = 8
array = Array.new(N) { |x| x }

$T=0

def recurse(array, n, i, odd=nil)
	if n > 1
		i += 1

		recurse(array, n / 2, i, odd)
		recurse(array, n / 2, i, true)
		# N - 2 ** i - YROVEN YGLYBLENIYA V OBRATNOM PORYADKE!
		#
		x = 0 
		x = n if odd
		$T += 1
		# puts "#{N - 2 ** i + x}"
		# puts "#{N - 2 ** i + 1 + x}"
		#array[i] += 10
	end
end

recurse(array, N, 0)

#print array
puts $T