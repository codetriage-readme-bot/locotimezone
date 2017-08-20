require 'spec_helper'
require 'active_record'
include ApiResponses

describe Locotimezone::ActiveRecordHelper do
  before(:all) { ActiveRecord::Migration.verbose = false }
  before :each do
    ActiveRecord::Base.establish_connection adapter: 'sqlite3',
                                            database: 'memory'

    ApplicationRecord = Class.new(ActiveRecord::Base) do
      self.abstract_class = true
    end

    User = Class.new(ApplicationRecord) do
      include Locotimezone::ActiveRecordHelper
      after_validation lambda {
        locotime address: '525 NW 1st Ave, Fort Lauderdale, FL 33301'
      }
    end

    stub_request(:get, /maps\/api\/geocode/)
      .to_return(body: valid_geolocation_response)
    stub_request(:get, /maps\/api\/timezone/)
      .to_return(body: valid_timezone_response)
  end

  after :each do
    Object.send(:remove_const, :User)
    Object.send(:remove_const, :ApplicationRecord)
  end

  context 'with default attribute name' do
    before :each do
      ActiveRecord::Schema.define do
        create_table :users, force: true do |t|
          t.string :latitude
          t.string :longitude
          t.string :timezone_id
        end
      end
      User.create
    end

    let(:user) { User.take }

    it 'persists the latitude' do
      expect(user.latitude).to eq '26.1288237'
    end

    it 'persists the longitude' do
      expect(user.longitude).to eq '-80.144976'
    end

    it 'persists the timezone data' do
      expect(user.timezone_id).to eq 'America/New_York'
    end
  end

  context 'with overridden attribute name' do
    before :each do
      ActiveRecord::Schema.define do
        create_table :users, force: true do |t|
          t.string :lat
          t.string :lng
          t.string :tz_id
        end
      end

      Locotimezone.configure do |config|
        config.attributes = {
          latitude: :lat,
          longitude: :lng,
          timezone_id: :tz_id
        }
      end
      User.create
    end

    let(:user) { User.take }

    it 'persists the latitude' do
      expect(user.lat).to eq '26.1288237'
    end

    it 'persists the longitude' do
      expect(user.lng).to eq '-80.144976'
    end

    it 'persists the timezone data' do
      expect(user.tz_id).to eq 'America/New_York'
    end
  end
end
