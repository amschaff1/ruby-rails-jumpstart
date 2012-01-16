
filename = ARGV.shift                   # get a filename from the command line arguments

unless filename                         # we can't work without a filename
  puts "no filename specified!"
  exit
end

lines = 0                               # a humble line counter
firstSkipped = false					# has the first line been skipped
unique_users = {}		                # a hash of unique users
unique_pages = "unknown"                # someday, this will work
most_active_day = "unknown"             # someday, this will work
most_active_user = "unknown"            # someday, this will work
most_active_page = "unknown"            # someday, this will work

open(filename).each do |m|              # loop over every line of the file
    if(!firstSkipped)
        firstSkipped = true				# the first line has been skipped
    else
      m.chomp!                              # remove the trailing newline
      values = m.split(",")                 # split comma-separated fields into a values array
    
      if(!unique_users.has_key?(values[1]))	# if the user is not in unique_users
      	unique_users[values[1]] = values[1]	# add the user to the hash
  	  end
  	  
      lines += 1                            # bump the counter
    end
end

puts "total lines: #{lines}"                  # output stats
puts "unique users: #{unique_users.length.to_s}" # the number of unique users
puts "unique pages: #{unique_pages}"          # someday, this will work
puts "most active day: #{most_active_day}"    # someday, this will work
puts "most active user: #{most_active_user}"  # someday, this will work
puts "most active page: #{most_active_page}"  # someday, this will work