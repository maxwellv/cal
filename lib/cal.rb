days_in_month = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
day_of_week_names = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

def is_leap_year(year)
  if (year % 4 == 0 && year % 100 != 0)
    return true
  elsif (year % 100 == 0 && year % 400 == 0)
    return true
  else #any year that gets here either isn't divisible by 4 or is divisible by 100 BUT NOT 400
    return false
  end
end

def zeller(day, month, year)
  q = day
  m = month
  y = year
  if (m < 3)
    m += 12 #January and February (1 and 2) are handled as 13 and 14
    y -= 1
  end
  day_of_week = (q + (((m + 1) * 26) / 10) + y + (y / 4) + (6 * (y / 100)) + (y / 400)) % 7
  #the default implementation of Zeller's congruence has Saturday as 0, but since cal will render Sunday as the first day of the month, we'll 
  day_of_week = ((day_of_week + 6) % 7)
  return day_of_week
end

def make_week(day, day_of_week, month, leap)
  days_in_month = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
  week = ""
  blank_day = "   " #Three spaces are used for each spot on the calendar where a day isn't.
  #Note that day_of_week is the day of the week to start on. In most cases, this'll be Sunday.
  if (day_of_week > 0)
    day_of_week.times do
      week += blank_day
    end
  end
  total_days = days_in_month[month - 1] #The month, coming into make_week, is going to be one-indexed.
  if (month == 2 && leap) #Is it February and a leap year?
    total_days += 1
  end
  days_to_add = total_days - (day - 1)
  7.times do #7 days in a week
    if (day_of_week >= 7)
      #do nothing
    elsif (days_to_add < 1)
      week += blank_day
    else
      day_str = day.to_s
      if (day < 10) #Each day on the calendar takes up two characters, even if it's 1-9.
        day_str = " " + day_str
      end
      day += 1
      day_of_week += 1
      days_to_add -= 1
      day_str += " " unless (day_of_week > 6 || days_to_add < 1)
      week += day_str
    end
  end
  return week
end

def make_month(weeks, month, year = nil)
  ret_month = []
  month_names = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
  month_name = month_names[month - 1]#Months will be one-indexed, same as with weeks up above.
  if (year != nil)
    month_name += " " + year.to_s
  end
  month_name = month_name.center(20)
  ret_month.push(month_name)
  ret_month.push("Su Mo Tu We Th Fr Sa")#Barring a major change to the Gregorian calendar, the names of the days of the week will always be the same.
  weeks.each do |week|
    ret_month.push(week)
  end
  return ret_month
end

if (ARGV.length < 1 || ARGV.length > 2)
  puts "Usage: \"cal.rb <year>\", or \"cal.rb <month number> <year>\""
else
  if (ARGV.length == 1)
    #displaying an entire year is as yet unimplemented, so for right now we'll assume the user wanted January
    month = 0
    year = ARGV[0].to_i
  else
    month = ARGV[0].to_i
    year = ARGV[1].to_i
  end

  if (month > 12 || month < 1)
    puts "Invalid month."
  elsif (year > 3000 || year < 1800)
    puts "Invalid year (years must be between 1800 and 3000)."
  else #run the rest of the program
    #We only need to compute the day of the week once. After that, we can just increment it.
    day_of_week_index = zeller(1, month, year)
    day_offset = 7 - (day_of_week_index - 1)
    calendar = []
    days = days_in_month[month - 1]
    leap = is_leap_year(year)
    if (leap && month == 2)
      days += 1
    end
    calendar.push(make_week(1, day_of_week_index, month, leap))
    while true
      if (day_offset > days)
        break
      end
      calendar.push(make_week(day_offset, 0, month,  leap)) #additional weeks always start on Sunday
      day_offset += 7
    end
    calendar = make_month(calendar, month, year)
    calendar.each do |line|
      puts line
    end
    #cal puts out one extra line of whitespace, so let's reproduce it here
    puts ""
  end
end
