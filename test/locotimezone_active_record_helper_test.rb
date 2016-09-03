require 'test_helper'

class Record < Struct.new(:latitude, :longitude, :timezone_id)
  include Locotimezone::ActiveRecordHelper

  def save(options)
    locotime options
  end
end

class LocotimezoneActiveRecordHelperTest < Minitest::Test

  describe 'sets location and timezone attributes' do 
    it 'sets latitude' do
      Locotimezone.stub :locotime, full_results do
        record = Record.new
        record.save({ address: address })

        refute_nil record.latitude
      end
    end

    it 'sets longitude' do
      Locotimezone.stub :locotime, full_results do
        record = Record.new
        record.save({ address: address })

        refute_nil record.longitude
      end
    end

    it 'sets timezone_id' do
      Locotimezone.stub :locotime, full_results do
        record = Record.new
        record.save({ address: address })

        refute_nil record.timezone_id
      end
    end
  end

  describe 'sets location and skips timezone' do
    it 'sets latitude' do
      stub_any_instance(Locotimezone::Geolocate, :get_geo, get_geo_results) do
        record = Record.new
        record.save({ address: address, skip: :timezone })

        refute_nil record.latitude
      end
    end

    it 'sets longitude' do
      stub_any_instance(Locotimezone::Geolocate, :get_geo, get_geo_results) do
        record = Record.new
        record.save({ address: address, skip: :timezone })

        refute_nil record.longitude
      end
    end

    it 'does not set timezone_id' do
      stub_any_instance(Locotimezone::Geolocate, :get_geo, get_geo_results) do
        record = Record.new
        record.save({ address: address, skip: :timezone })

        assert_nil record.timezone_id
      end
    end

  end

  describe 'sets timezone based on coordinates' do
    it 'does not set latitude' do
      stub_any_instance(Locotimezone::Timezone, 
                        :timezone, 
                        get_timezone_results) do
        record = Record.new
        record.save({ location: lat_lng })

        assert_nil record.latitude
      end
    end

    it 'does not set longitude' do
      stub_any_instance(Locotimezone::Timezone, 
                        :timezone, 
                        get_timezone_results) do
        record = Record.new
        record.save({ location: lat_lng })

        assert_nil record.longitude
      end
    end

    it 'sets timezone_id' do
      stub_any_instance(Locotimezone::Timezone, 
                        :timezone, 
                        get_timezone_results) do
        record = Record.new
        record.save({ location: lat_lng })

        refute_nil record.timezone_id
      end
    end
  end
end
