#!/usr/bin/env ruby
#The above line tells the shell to run this using ruby instead of as a normal shell script.
#Chmod this file +x to run it from the command line.

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
  month_width = 20
  ret_month = []
  month_names = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
  month_name = month_names[month - 1]#Months will be one-indexed, same as with weeks up above.
  if (year != nil)
    month_name += " " + year.to_s
  end
  month_name = month_name.center(month_width)
  ret_month.push(month_name)
  ret_month.push("Su Mo Tu We Th Fr Sa")#Barring a major change to the Gregorian calendar, the names of the days of the week will always be the same.
  weeks.each do |week|
    ret_month.push(week)
  end
  while (ret_month.length < 8)
    #Unix cal automatically pads months out to eight lines each, no matter how short they are.
    ret_month.push("".ljust(month_width))
  end
  return ret_month
end

def make_year(months, year, rows, columns)
  line_length = columns * 22
  ret_year = []
  ret_year.push(year.to_s.center(line_length - year.to_s.length))
  ret_year.push("".ljust(line_length)) #Unix cal puts an extra line between the year and the first month
  ranges = []
  total_months = rows * columns
  current_month = 1 #start at January...
  row = []
  (total_months + 1).times do
    if (row.length == columns)
      ranges.push(row)
      row = []
    end
    if (current_month > 12)
      #The calendar is only ever going to have 12 months, maximum. This is in case the user specifies something wild, like rows = 10 and columns = 33.
      break
    end
    row.push(current_month)
    current_month += 1
  end

  ranges.each do |range|
    selected_line = 0
    current_line = ""
    while (selected_line < 8) #eight lines in each month, no matter how long the month actually is
      range.each do |selected_month|
        current_line += months[selected_month - 1][0][selected_line]
        if (selected_month % columns != 0) #if it's not the last month in the range
          current_line += "  "
        end
      end
      ret_year.push(current_line)
      current_line = ""
      selected_line += 1
    end
  end
  return ret_year
end

use_error_message = ["Usage: \"cal.rb <year>\", or \"cal.rb <month number> <year>\"", "If you are using a single year, you may specify --rows=X and --columns=Y to further format the display."]

if (ARGV.length < 1 || ARGV.length > 3)
  puts use_error_message
else
  rows = 4    #default rows and columns that Unix cal uses
  columns = 3
  month = year = 0
  ARGV.each do |arg|
    if arg[0..6] == "--rows="
      rows = arg[7..arg.length - 1].to_i
    elsif arg[0..9] == "--columns="
      columns = arg[10..arg.length - 1].to_i
    else
      value = arg.to_i
      if (value < 13)
        month = value
      else
        year = value
      end
    end
  end

  if (month > 12 || month < 0)
    puts "Invalid month."
  elsif (year > 3000 || year < 1800)
    puts "Invalid year (years must be between 1800 and 3000)."
  else #run the rest of the program
    if (month == 0)
      months = (1..12).to_a
    else
      months = [month]
    end
    leap = is_leap_year(year)
    rendered_months = []
    months.each do |selected_month|
      day_of_week_index = zeller(1, selected_month, year)
      day_offset = 7 - (day_of_week_index - 1)
      calendar = []
      days = days_in_month[selected_month - 1]
      if (leap && selected_month == 2)
        days += 1
      end
      calendar.push(make_week(1, day_of_week_index, selected_month, leap))
      while true
        if (day_offset > days)
          break
        end
        calendar.push(make_week(day_offset, 0, selected_month,  leap)) #additional weeks always start on Sunday
        day_offset += 7
      end
      if (months.length > 1)
        calendar = make_month(calendar, selected_month, nil) #nil specifies that the year will not appear next to the month
      else
        calendar = make_month(calendar, selected_month, year)
      end
      rendered_months.push([calendar])
    end
    if (rendered_months.length == 1)
      calendar = rendered_months[0][0]
      calendar.each do |line|
        puts line.to_s.rstrip
      end
    else
      year = make_year(rendered_months, year, rows, columns)
      year.each do |line|
        puts line.to_s.rstrip
      end
    end
  end
end
