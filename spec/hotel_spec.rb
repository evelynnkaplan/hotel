require_relative "spec_helper"
require_relative "../lib/hotel.rb"

describe "hotel class" do
  before do
    @hotel = HotelSystem::Hotel.new(20)
  end

  describe "hotel instantiation" do
    it "will create a new hotel" do
      expect(@hotel).must_be_kind_of HotelSystem::Hotel
    end

    it "hotel will have an array of rooms and reservations" do
      expect(@hotel.rooms).must_be_kind_of Array
      expect(@hotel.reservations).must_be_kind_of Array
    end

    it "hotel will have an array of unique rooms" do
      expect(@hotel.rooms[0]).must_be_kind_of HotelSystem::Room
      expect(@hotel.rooms[0].room_number).must_equal 1
      expect(@hotel.rooms.length).must_equal 20
      expect(@hotel.rooms[0].object_id).wont_equal @hotel.rooms[1].object_id
    end
  end

  describe "add_rooms method" do
    it "will raise an ArgumentError for bad arguments" do
      expect {
        @hotel.add_rooms("cat")
      }.must_raise ArgumentError
    end

    it "will add rooms to the hotel" do
      @hotel.add_rooms(3)

      expect(@hotel.rooms.length).must_equal 23
    end
  end

  describe "valid_date_entry? method" do
    it "will raise an error if date is invalid" do
      expect {
        @hotel.valid_date_entry?(2019, 1, 32)
      }.must_raise ArgumentError
    end
  end

  describe "create_date_list method" do
    before do
      @dates = @hotel.create_date_list(start_year: 2019, start_month: 11, start_day: 15, num_nights: 5)
    end

    it "returns a DateRange" do
      expect(@dates).must_be_kind_of HotelSystem::DateRange
    end
  end

  describe "find_room method" do
    it "returns an instance of a room" do
      room = @hotel.find_room(19)

      expect(room).must_be_kind_of HotelSystem::Room
    end

    it "returns nil if a matching room isn't found" do
      room = @hotel.find_room(25)

      expect(room).must_be_nil
    end

    it "raises an ArgumentError if a bad room number is given" do
      expect {
        @hotel.find_room("cat")
      }.must_raise ArgumentError
    end
  end

  describe "room_reserved? method" do
    before do
      3.times do
        @hotel.reserve_room(start_year: 2019, start_month: 12, start_day: 5, num_nights: 4)
      end

      @dates = @hotel.create_date_list(start_year: 2019, start_month: 12, start_day: 5, num_nights: 4)
    end

    it "will return false if the room is not reserved" do
      status = @hotel.room_reserved?(room_number: 19, year: 2019, month: 12, day: 5)

      expect(status).must_equal false
    end

    it "will return true if the room is reserved" do
      status = @hotel.room_reserved?(room_number: 1, year: 2019, month: 12, day: 7)

      expect(status).must_equal true
    end

    it "will return false if the date entered is the checkout day of a reservation" do
      status = @hotel.room_reserved?(room_number: 1, year: 2019, month: 12, day: 9)

      expect(status).must_equal false
    end
  end

  describe "find_available_room method" do
    before do
      @res_dates = @hotel.create_date_list(start_year: 2019, start_month: 1, start_day: 2)
      @room = @hotel.find_available_room(start_year: 2019, start_month: 1, start_day: 2)
    end
    it "will return a room if a room is available" do
      expect(@room).must_be_kind_of HotelSystem::Room
    end

    it "will return the first available room" do
      expect(@room.room_number).must_equal 1
    end

    it "will raise an error if no room is available for a start day of 20 reservations" do
      20.times do
        @hotel.reserve_room(start_year: 2019, start_month: 7, start_day: 4, num_nights: 5)
      end

      expect {
        @hotel.find_available_room(start_year: 2019, start_month: 7, start_day: 4)
      }.must_raise NotImplementedError
    end

    it "will raise an error if no room is available for a middle day of 20 reservations" do
      20.times do
        @hotel.reserve_room(start_year: 2019, start_month: 7, start_day: 4, num_nights: 5)
      end

      expect {
        @hotel.find_available_room(start_year: 2019, start_month: 7, start_day: 6)
      }.must_raise NotImplementedError
    end

    it "will return a room when it is requested on the checkout day of other reservations" do
      20.times do
        @hotel.reserve_room(start_year: 2019, start_month: 7, start_day: 4, num_nights: 5)
      end

      room = @hotel.find_available_room(start_year: 2019, start_month: 7, start_day: 9)
      expect(room.room_number).must_equal 1
    end
  end

  describe "create_reservation_id method" do
    it "will return 1 if the hotel has no reservations yet" do
      res_id = @hotel.create_reservation_id

      expect(res_id).must_equal 1
    end

    it "will return the correct number if the hotel has reservations" do
      3.times do
        @hotel.reserve_room(start_year: 2019, start_month: 12, start_day: 5, num_nights: 4)
      end

      res_id = @hotel.create_reservation_id

      expect(res_id).must_equal 4
    end
  end

  describe "reserve_room method" do
    before do
      3.times do
        @hotel.reserve_room(start_year: 2019, start_month: 12, start_day: 5, num_nights: 4)
      end
    end

    it "will add a reservation to the hotel's list of reservations" do
      expect(@hotel.reservations.length).must_equal 3
      expect(@hotel.reservations[0]).must_be_kind_of HotelSystem::Reservation
    end

    it "will correctly assign a reservation id" do
      expect(@hotel.reservations[0].id).must_equal 1
      expect(@hotel.reservations[1].id).must_equal 2
      expect(@hotel.reservations[2].id).must_equal 3
    end

    it "will raise an error if there are no available rooms" do
      17.times do
        @hotel.reserve_room(start_year: 2019, start_month: 12, start_day: 5, num_nights: 4)
      end

      expect {
        @hotel.reserve_room(start_year: 2019, start_month: 12, start_day: 5, num_nights: 4)
      }.must_raise NotImplementedError
    end

    it "will correctly assign a room if checkout day of another reservation is requested" do
      17.times do
        @hotel.reserve_room(start_year: 2019, start_month: 12, start_day: 5, num_nights: 4)
      end

      @hotel.reserve_room(start_year: 2019, start_month: 12, start_day: 9, num_nights: 2)

      status = @hotel.room_reserved?(room_number: 1, year: 2019, month: 12, day: 10)

      expect(status).must_equal true
    end

    describe "reservations_by_date method" do
      before do
        3.times do
          @hotel.reserve_room(start_year: 2019, start_month: 12, start_day: 5, num_nights: 4)
        end
      end

      it "will return an array" do
        reservations = @hotel.reservations_by_date(year: 2019, month: 12, day: 5)
        
        expect(reservations).must_be_kind_of Array
      end

      it "each index in the returned array will hold a hash with the reservation information" do
        reservations = @hotel.reservations_by_date(year: 2019, month: 12, day: 5)
        
        expect(reservations[0]).must_be_kind_of HotelSystem::Reservation
      end

      it "will raise ArgumentError for invalid date entry" do
        expect{
          @hotel.reservations_by_date(year: 2019, month: 2, day: 30)
        }.must_raise ArgumentError
      end

    
    end
  end
end
