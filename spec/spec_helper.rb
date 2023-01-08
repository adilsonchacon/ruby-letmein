# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

require 'vcr'
require 'ruby_letmein'
require 'api_error'
require 'pry'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr_cassettes'
  c.hook_into :webmock
end
