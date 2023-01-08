# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

# API error responses
class ApiError
  attr_reader :response, :request

  def initialize(request, response)
    @request = request
    @response = response
  end

  def response_body
    @response.body
  end

  def parsed_response_body
    JSON.parse(response_body)
  end

  def code
    @response.code
  end
end
