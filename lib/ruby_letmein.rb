# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

# Main class
class RubyLetmein
  attr_reader :app_token, :base_url, :uri
  attr_accessor :auth_token, :auth_token_expiry, :api_error

  def initialize(base_url, app_token)
    URI.parse(base_url)
    @base_url = base_url
    @app_token = app_token
  end

  def sign_in(email, password)
    uri = URI.parse("#{base_url}/api/v1/app/session/sign_in")
    header = { 'Content-Type': 'application/json', AppToken: @app_token }

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.instance_of? URI::HTTPS
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.body = { email: email, password: password }.to_json

    response = http.request(request)
    return false unless success?(request, response)

    define_auth_token_and_expiry!(response)
  end

  def sign_out
    uri = URI.parse("#{base_url}/api/v1/app/session/sign_out")
    header = { 'Content-Type': 'application/json', AppToken: @app_token, Authorization: "Bearer #{@auth_token}" }

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.instance_of? URI::HTTPS
    request = Net::HTTP::Delete.new(uri.request_uri, header)

    response = http.request(request)
    return false unless success?(request, response)

    nullify_token_and_expiry
    true
  end

  def signed_in?
    uri = URI.parse("#{base_url}/api/v1/app/session/signed_in")
    header = { 'Content-Type': 'application/json', AppToken: @app_token, Authorization: "Bearer #{@auth_token}" }

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.instance_of? URI::HTTPS
    request = Net::HTTP::Get.new(uri.request_uri, header)

    response = http.request(request)
    success?(request, response)
  end

  def current_user
    @current_user ||= retrieve_current_user
  end

  def refresh_current_user
    @current_user = nil
    current_user
  end

  private

  def retrieve_current_user
    uri = URI.parse("#{base_url}/api/v1/app/session/current_user")
    header = { 'Content-Type': 'application/json', AppToken: @app_token, Authorization: "Bearer #{@auth_token}" }

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.instance_of? URI::HTTPS
    request = Net::HTTP::Get.new(uri.request_uri, header)

    response = http.request(request)
    return nil unless success?(request, response)

    JSON.parse(response.body)
  end

  def error?(request, response)
    @api_error = (response.code == '200' ? nil : ApiError.new(request, response))
    !@api_error.nil?
  end

  def success?(request, response)
    !error?(request, response)
  end

  def define_auth_token_and_expiry!(response)
    parsed_body = JSON.parse(response.body)

    @auth_token = parsed_body['auth_token']
    @auth_token_expiry = Time.at(parsed_body['expiry'].to_i)
    true
  rescue StandardError
    false
  end

  def nullify_token_and_expiry
    @auth_token = nil
    @auth_token_expiry = nil
  end
end
