
filename = ARGV.shift                   # get a filename from the command line arguments

unless filename                         # we can't work without a filename
  puts "no filename specified!"
  exit
end

lines = 0                               # a humble line counter
firstSkipped = false					# has the first line been skipped
unique_users = {}		                # a hash of unique users
unique_pages = {}                		# a hash of unique pages
most_active_day = {}             		# a hash to keep track of the amount of activity per day
most_active_user = {}             		# a hash to keep track of the number of unique users
most_active_page = {}		            # a hash to keep track of the amount of activity on each page

open(filename).each do |m|              # loop over every line of the file
    if(!firstSkipped)
        firstSkipped = true				# the first line has been skipped
    else
      m.chomp!                              # remove the trailing newline
      values = m.split(",")                 # split comma-separated fields into a values array
    
      if(!unique_users.has_key?(values[1]))	# if the user is not in unique_users
      	unique_users[values[1]] = values[1]	# add the user to the hash
  	  end
  	  
  	  if(!unique_pages.has_key?(values[2])) #if the page is not in unique_pages
  	  	unique_pages[values[2]] = values[2] # add the page to the hash
  	  end
  	  
  	  if(most_active_day.has_key?(values[0])) # if the day already exists in most_active_day
  	  	most_active_day[values[0]] += 1		# add one to it's value
  	  else
  	  	most_active_day[values[0]] = 1		# otherwise add it to the hash and make the value one
  	  end	
  	  
  	  if(most_active_user.has_key?(values[1])) # if the user already exists in most_active_user
  	  	most_active_user[values[1]] += 1		# add one to it's value
  	  else
  	  	most_active_user[values[1]] = 1		# otherwise add it to the hash and make the value one
  	  end
  	  
  	  if(most_active_page.has_key?(values[2])) # if the page already exists in most_active_page
  	  	most_active_page[values[2]] += 1		# add one to it's value
  	  else
  	  	most_active_page[values[2]] = 1		# otherwise add it to the hash and make the value one
  	  end

      lines += 1                            # bump the counter
    end
end

puts "total lines: #{lines}"                  # output stats
puts "unique users: #{unique_users.length}"   # get the number of unique users in unique_users
puts "unique pages: #{unique_pages.length}"   # get the nubmer of unique pages in unique_pages
puts "most active day: #{most_active_day.sort_by { |day, count| count }.last.first}"   
# sort the most active day hash by the values and get the key with the highest value
puts "most active user: #{most_active_user.sort_by{ |user, count| count}.last.first}"  
# sort the most active user hash by the values and get the key with the highest value
puts "most active page: #{most_active_page.sort_by{ |page, count| count}.last.first}"  
# sort the most active page hash by the values and get the key with the highest value