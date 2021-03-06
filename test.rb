ENV['RACK_ENV'] = 'test'

require 'simplecov'
SimpleCov.start
require 'test/unit'
require 'shoulda'
require 'rack/test'
require 'geoip_server'

class GeoipServerTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  context "on GET to /" do
    setup {
      get '/'
    }
    should "return ok" do
      assert last_response.ok?
    end
    should "include an example" do
      assert last_response.body =~ /curl/
    end
  end

  context "on GET to /:ip" do
    setup {
      get '/67.161.92.71'
    }
    should "return ok" do
      assert last_response.ok?
    end
    should "return json content-type" do
      assert_equal 'application/json;charset=ascii-8bit', last_response.headers['Content-Type']
    end
  end

  context "on GET to /:ip?variable=myVariableName" do
    setup {
      get '/67.161.92.71?variable=myVariableName'
    }
    should "return ok" do
      assert last_response.ok?
    end
    should "return json content-type" do
      assert_equal 'application/json;charset=ascii-8bit', last_response.headers['Content-Type']
    end
    should "include a variable" do
      assert last_response.body =~ /var myVariableName/
    end
  end

  context "on GET to /:ip?callback=myCallbackFunction" do
    setup {
      get '/67.161.92.71?callback=myCallbackFunction'
    }
    should "return ok" do
      assert last_response.ok?
    end
    should "return json content-type" do
      assert_equal 'application/json;charset=ascii-8bit', last_response.headers['Content-Type']
    end
    should "include a function" do
      assert last_response.body =~ /myCallbackFunction\(\{.*\}\)/
    end
  end

  context "on GET to /:ip?callback=myCallbackFunction&variable=myVariableName" do
    setup {
      get '/67.161.92.71?callback=myCallbackFunction&variable=myVariableName'
    }
    should "return ok" do
      assert last_response.ok?
    end
    should "return json content-type" do
      assert_equal 'application/json;charset=ascii-8bit', last_response.headers['Content-Type']
    end
    should "include a variable" do
      assert last_response.body =~ /var myVariableName/
    end
    should "include a function" do
      assert last_response.body =~ /myCallbackFunction\(myVariableName\);/
    end
  end

  context "converting struct" do
    setup {
      Struct.new(
        "City",
        :request,
        :ip,
        :country_code2,
        :country_code3,
        :country_name,
        :continent_code,
        :region_name,
        :city_name,
        :postal_code,
        :latitude,
        :longitude,
        :dma_code,
        :area_code,
        :timezone
      ) unless defined? Struct::City
      city = Struct::City.new(
        "67.161.92.71",
        "67.161.92.71",
        "US",
        "USA",
        "United States",
        "NA",
        "WA",
        "Seattle",
        "98117",
        47.6847,
        -122.3848,
        819,
        206,
        "America/Los_Angeles"
      )
      @hash = encode(city)
    }
    should "find city" do
      assert_equal 'Seattle', @hash[:city]
    end
    should "find country" do
      assert_equal 'United States', @hash[:country]
    end
    should "find lat" do
      assert_equal 47.6847, @hash[:lat]
    end
    should "find lng" do
      assert_equal -122.3848, @hash[:lng]
    end
  end
end
