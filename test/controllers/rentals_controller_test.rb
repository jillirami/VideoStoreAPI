require "test_helper"

describe RentalsController do
  # it "must be a real test" do
  #   flunk "Need real tests"
  # end

  describe 'checkout' do
    before do 
      @rental_data = {
        customer_id: Customer.first.id, 
        movie_id: Movie.last.id 
      }
    end 

    it "creates a new rental given valid data" do
      expect {
        post checkout_path, params: @rental_data
      }.must_change "Rental.count", +1

      body = JSON.parse(response.body)
      expect(body).must_be_kind_of Hash

      rental = Rental.last

      expect(rental.customer_id).must_equal @rental_data[:customer_id]
      expect(rental.movie_id).must_equal @rental_data[:movie_id]


      must_respond_with :success
    end

    it "returns a JSON with error for invalid rental data" do
      @rental_data["movie_id"] = -1

      expect {
        post checkout_path, params: { rental: @rental_data }
      }.wont_change "Rental.count"

      body = JSON.parse(response.body)

      expect(response.header["Content-Type"]).must_include "json"
      expect(body).must_be_kind_of Hash
      expect(body).must_include "errors"
      
      must_respond_with :bad_request
    end
  end 

  describe 'checkin' do
  end 
end
