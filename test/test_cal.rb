require 'cal'

class CalTest < MiniTest::Unit::TestCase
  def test_zeller_tests
    zeller_1 = zeller(01, 01, 2000)
    zeller_2 = zeller(29, 02, 2000)
    zeller_3 = zeller(01, 03, 2000)
    zeller_4 = zeller(28, 02, 1900)
    zeller_5 = zeller(01, 03, 1900)
    refute zeller_1 == 0, "this implementation of Zeller's congruence should have Sundays as 0, not Saturdays"
    assert zeller_1 == 6, "January 1, 2000 is a Saturday"
    assert zeller_2 == 2, "February 29, 2000 is a Tuesday"
    assert zeller_3 == 3, "March 1, 2000 is a Wednesday"
    assert zeller_4 == 3, "February 28, 1900 is a Wednesday"
    assert zeller_5 == 4, "March 1, 1900 is a Thursday"
  end

  def test_leap_years
    year_1 = is_leap_year(2012)
    year_2 = is_leap_year(2014)
    year_3 = is_leap_year(1900)
    year_4 = is_leap_year(2000)
    assert year_1 == true, "2012 is a leap year"
    assert year_2 == false, "2014 is not a leap year"
    assert year_3 == false, "1900 is not a leap year (divisible by 4, but is the start of a century and is not divisble by 100)"
    assert year_4 == true, "2000 is a leap year (divisible by 4, starts a century but is also divisible by 400)"
  end

  def test_make_week
    week_1 = make_week(1, 0, 1, false) #January 1, starting on Sunday
    week_2 = make_week(1, 4, 3, false) #March 1, starting on Thursday
    week_3 = make_week(11, 0, 3, false) #March 11, starting on Sunday
    week_4 = make_week(29, 0, 4, false) #April 29, starting on Sunday
    week_5 = make_week(25, 0, 2, false) #February 25, starting on Sunday, not a leap year
    week_6 = make_week(25, 0, 2, true) #February 25, starting on Sunday, leap year
    week_7 = make_week(27, 0, 5, false) #May 27, starting on Sunday
    assert_equal(" 1  2  3  4  5  6  7", week_1)
    assert_equal("             1  2  3", week_2)
    assert_equal("11 12 13 14 15 16 17", week_3)
    assert_equal("29 30               ", week_4)
    assert_equal("25 26 27 28         ", week_5)
    assert_equal("25 26 27 28 29      ", week_6)
    assert_equal("27 28 29 30 31      ", week_7)
  end

  def test_make_month
    weeks_1 = [" 1  2  3  4  5  6  7", " 8  9 10 11 12 13 14", "15 16 17 18 19 20 21", "22 23 24 25 26 27 28", "29 30 31             "]
    month_1 = make_month(weeks_1, 1, 2012)
    assert_equal("    January 2012    ", month_1[0])
    assert_equal("Su Mo Tu We Th Fr Sa", month_1[1])
    assert_equal(" 1  2  3  4  5  6  7", month_1[2])
  end

  def test_cal_integration
    shell_output = ""
    IO.popen('ruby lib/cal.rb 1 2014', 'r+') do |pipe|
      shell_output = pipe.read
    end
    expected_output = <<EOS
    January 2014    
Su Mo Tu We Th Fr Sa
          1  2  3  4
 5  6  7  8  9 10 11
12 13 14 15 16 17 18
19 20 21 22 23 24 25
26 27 28 29 30 31   
                    
EOS
    assert_equal(expected_output, shell_output)
  end

  def test_cal_year_integration
    shell_output = ""
    IO.popen('ruby lib/cal.rb 2014', 'r+') do |pipe|
      shell_output = pipe.read
    end
    expected_output = <<EOS
                             2014                             
                                                                  
      January               February               March        
Su Mo Tu We Th Fr Sa  Su Mo Tu We Th Fr Sa  Su Mo Tu We Th Fr Sa
          1  2  3  4                     1                     1
 5  6  7  8  9 10 11   2  3  4  5  6  7  8   2  3  4  5  6  7  8
12 13 14 15 16 17 18   9 10 11 12 13 14 15   9 10 11 12 13 14 15
19 20 21 22 23 24 25  16 17 18 19 20 21 22  16 17 18 19 20 21 22
26 27 28 29 30 31     23 24 25 26 27 28     23 24 25 26 27 28 29
                                            30 31               
       April                  May                   June        
Su Mo Tu We Th Fr Sa  Su Mo Tu We Th Fr Sa  Su Mo Tu We Th Fr Sa
       1  2  3  4  5               1  2  3   1  2  3  4  5  6  7
 6  7  8  9 10 11 12   4  5  6  7  8  9 10   8  9 10 11 12 13 14
13 14 15 16 17 18 19  11 12 13 14 15 16 17  15 16 17 18 19 20 21
20 21 22 23 24 25 26  18 19 20 21 22 23 24  22 23 24 25 26 27 28
27 28 29 30           25 26 27 28 29 30 31  29 30               
                                                                
        July                 August              September      
Su Mo Tu We Th Fr Sa  Su Mo Tu We Th Fr Sa  Su Mo Tu We Th Fr Sa
       1  2  3  4  5                  1  2      1  2  3  4  5  6
 6  7  8  9 10 11 12   3  4  5  6  7  8  9   7  8  9 10 11 12 13
13 14 15 16 17 18 19  10 11 12 13 14 15 16  14 15 16 17 18 19 20
20 21 22 23 24 25 26  17 18 19 20 21 22 23  21 22 23 24 25 26 27
27 28 29 30 31        24 25 26 27 28 29 30  28 29 30            
                      31                                        
      October               November              December      
Su Mo Tu We Th Fr Sa  Su Mo Tu We Th Fr Sa  Su Mo Tu We Th Fr Sa
          1  2  3  4                     1      1  2  3  4  5  6
 5  6  7  8  9 10 11   2  3  4  5  6  7  8   7  8  9 10 11 12 13
12 13 14 15 16 17 18   9 10 11 12 13 14 15  14 15 16 17 18 19 20
19 20 21 22 23 24 25  16 17 18 19 20 21 22  21 22 23 24 25 26 27
26 27 28 29 30 31     23 24 25 26 27 28 29  28 29 30 31         
                      30                                        
EOS
    assert_equal(expected_output, shell_output)
  end

end
