require "date"

module HotelSystem
  class DateRange
    attr_reader :start_year, :start_month, :start_day, :num_nights

    def initialize(start_year:, start_month:, start_day:, num_nights: nil)
      self.class.valid_date_entry?(start_year, start_month, start_day)
      @start_year = start_year
      @start_month = start_month
      @start_day = start_day
      @num_nights = num_nights
    end

    def self.valid_date_entry?(year, month, day)
      if year.digits.length != 4
        raise ArgumentError, "Please enter 4 digits for the year."
      elsif !Date.valid_date?(year, month, day)
        raise ArgumentError, "Please enter a valid date with 4 digits for the year and 1 or 2 digits for both the month and day."
      end
    end

    def date_list
      dates_array = []
      start_date = Date.new(start_year, start_month, start_day)
      dates_array << start_date
      if num_nights 
        i = 1
        num_nights.times do
          date = start_date + i
          dates_array << date
          i += 1
        end
      end
      return dates_array
    end

    def checkout
      last = self.date_list.last
      return last
    end

    def include?(date)
      if date.class != Date
        raise ArgumentError, "Please enter an instance of the Date class."
      end
      if (date != self.checkout) && self.date_list.include?(date) 
        return true
      else
        return false
      end
    end

    def overlap?(range)
      if range.class != self.class && range.class != Date
        raise ArgumentError, "Please enter an instance of Date or DateRange."
      end
      if range.class == HotelSystem::DateRange
        range.date_list.each do |date|
          if self.include?(date) && (date != self.checkout)
            return true
          end
        end
      elsif range.class == Date
        if self.include?(range) && (range != self.checkout)
          return true
        end
      end
      return false
    end
    
  end
end
