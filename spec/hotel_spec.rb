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

  describe "create_date_range method" do
    before do
      @dates = @hotel.create_date_range(start_year: 2019, start_month: 11, start_day: 15, num_nights: 5)
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

      @dates = @hotel.create_date_range(start_year: 2019, start_month: 12, start_day: 5, num_nights: 4)
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
      @res_dates = @hotel.create_date_range(start_year: 2019, start_month: 1, start_day: 2)
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

    it "will not return a room that is in a block" do
      @hotel.create_block(start_year: 2019, start_month: 03, start_day: 17, num_nights: 17, room_nums: [1, 2, 3], block_rate: 150)

      avail_room = @hotel.find_available_room(start_year: 2019, start_month: 03, start_day: 17)
      expect(avail_room.room_number).must_equal 4
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

    it "will not reserve a room that is set aside for a block on the same day" do
      @hotel.create_block(start_year: 2019, start_month: 3, start_day: 16, num_nights: 5, room_nums:[1,2,3], block_rate: 150)

      @hotel.reserve_room(start_year: 2019, start_month: 3, start_day: 16, num_nights: 5)
      march16res = @hotel.reservations_by_date(year: 2019, month: 3, day: 17)

      expect(march16res.length).must_equal 1
      expect(march16res[0].room_number).must_equal 4
    end

    it "will reserve a room that is set aside for a block if the given date is the block's checkout day" do
      @hotel.create_block(start_year: 2019, start_month: 3, start_day: 16, num_nights: 5, room_nums:[1,2,3], block_rate: 150)

      @hotel.reserve_room(start_year: 2019, start_month: 3, start_day: 21, num_nights: 3)
      march21res = @hotel.reservations_by_date(year: 2019, month: 3, day: 21)

      expect(march21res.length).must_equal 1
      expect(march21res[0].room_number).must_equal 1
    end 
  end

  describe "reservations_by_date method" do
    before do
      3.times do
        @hotel.reserve_room(start_year: 2019, start_month: 12, start_day: 5, num_nights: 4)
      end
      @reservations = @hotel.reservations_by_date(year: 2019, month: 12, day: 5)
    end

    it "will return an array" do   
      expect(@reservations).must_be_kind_of Array
    end

    it "each index in the returned array will hold an instance of Reservation" do
      expect(@reservations[0]).must_be_kind_of HotelSystem::Reservation
    end

    it "will raise ArgumentError for invalid date entry" do
      expect{
        @hotel.reservations_by_date(year: 2019, month: 2, day: 30)
      }.must_raise ArgumentError
    end

    it "will return a reservation made from a hotel block" do
      @hotel.create_block(start_year: 2019, start_month: 12, start_day: 5, num_nights: 4, room_nums: [11, 12], block_rate: 100)
      @hotel.reserve_block_room(room_num: 11, block_id: 1)
      block_res = @hotel.reservations.last
      reservations = @hotel.reservations_by_date(year: 2019, month: 12, day: 5)

      expect(reservations).must_include block_res
      expect(reservations.length).must_equal 4
    end
  end

  describe "available_rooms_by_date method" do
    before do
      @avail_rooms = @hotel.available_rooms_by_date(year: 2019, month: 6, day: 15)
    end
      
    it "will return an array if there are available rooms" do
      expect(@avail_rooms).must_be_kind_of Array
    end

    it "will return an array of Room instances" do
      expect(@avail_rooms[0]).must_be_kind_of HotelSystem::Room
    end

    it "will return an array of all the rooms in the hotel if all rooms are available" do
     expect(@avail_rooms.length).must_equal 20
    end

    it "will not include a room if it gets booked for a date range including the given day" do
      @hotel.reserve_room(start_year: 2019, start_month: 6, start_day: 14, num_nights: 3)
      avail_rooms = @hotel.available_rooms_by_date(year: 2019, month: 6, day: 15)

      room1 = @hotel.rooms[0]
      status = avail_rooms.include?(room1)
      expect(status).must_equal false
    end
  end

  describe "create_block method" do
    before do
      @hotel.reserve_room(start_year: 2019, start_month: 9, start_day: 20, num_nights: 5)
      @hotel.create_block(start_year: 2019, start_month: 4, start_day: 20, num_nights: 5, room_nums: [4, 5, 6], block_rate: 150)
    end
      
    it "will create a new HotelBlock and add it to the hotel's blocks array" do
      expect(@hotel.blocks[0]).must_be_kind_of HotelSystem::HotelBlock
      expect(@hotel.blocks.length).must_equal 1
    end

    it "will raise an exception if at least 1 room is unavailable for given date range" do
      expect{
        @hotel.create_block(start_year: 2019, start_month: 9, start_day: 22, num_nights: 1, room_nums: [1, 2, 3], block_rate: 150)
      }.must_raise NotImplementedError
    end

    it "will not raise an exception if the block starts on the checkout day of another reservation" do
      @hotel.create_block(start_year: 2019, start_month: 9, start_day: 25, num_nights: 1, room_nums: [1, 2, 3], block_rate: 150)
        
      expect(@hotel.blocks[1]).wont_be_nil
    end

    it "will add the block dates range to the room's block_date_ranges array" do
      status = @hotel.blocks[0].rooms[0].in_block?(year: 2019, month: 4, day: 22)
        
      expect(status).must_equal true
    end

    it "will raise an exception if the given dates overlap with a block that already exists for that room" do
      expect{
        @hotel.create_block(start_year: 2019, start_month: 4, start_day: 23, num_nights: 5, room_nums: [4, 5], block_rate: 150)
      }.must_raise NotImplementedError
    end

    it "will raise an ArgumentError if more than 5 rooms are passed in" do
      expect{
        @hotel.create_block(start_year: 2019, start_month: 4, start_day: 23, num_nights: 5, room_nums: [4, 5, 6, 7, 8, 9], block_rate: 150)
      }.must_raise ArgumentError
    end
  end

  describe "reserve_block_room method" do
    before do
      @hotel.create_block(start_year: 2019, start_month: 4, start_day: 20, num_nights: 5, room_nums: [4, 5, 6], block_rate: 150)
      @hotel.reserve_block_room(room_num: 4, block_id: 1)
      @block1 = @hotel.blocks[0]
      @room4 = @hotel.rooms[3]
    end

    it "will remove the given room from the block's list of available rooms" do
      expect(@block1.available_rooms.length).must_equal 2
      expect(@block1.available_rooms).wont_include @room4
    end

    it "will raise an error if that room is already reserved" do
      expect{
        @hotel.reserve_block_room(room_num: 4, block_id: 1)
      }.must_raise NotImplementedError
    end

    it "will raise an error if that roomm isn't part of the block" do
      expect{
        @hotel.reserve_block_room(room_num: 9, block_id: 1)
      }.must_raise NotImplementedError
    end
  
  end 
end
