# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

# Main class
class RubyLetmein
  attr_accessor :auth_token, :app_token, :url

  def initialize(url, app_token)
    @url = url
    @app_token = app_token
  end

  def sign_in(email, password)
    uri = URI.parse("#{url}/api/v1/app/session/sign_in")
    header = { 'Content-Type': 'application/json', AppToken: @app_token }

    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.body = { email: email, password: password }.to_json

    response = http.request(request)
    paserd_body = JSON.parse(response.body)
    @auth_token = paserd_body['auth_token']

    response.code == '200'
  end

  def sign_out
    uri = URI.parse("#{url}/api/v1/app/session/sign_out")
    header = { 'Content-Type': 'application/json', AppToken: @app_token, Authorization: "Bearer #{@auth_token}" }

    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Delete.new(uri.request_uri, header)

    response = http.request(request)
    return false unless response.code == '200'

    @auth_token = nil
    true
  end

  def signed_in?
    uri = URI.parse("#{url}/api/v1/app/session/signed_in")
    header = { 'Content-Type': 'application/json', AppToken: @app_token, Authorization: "Bearer #{@auth_token}" }

    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri, header)

    response = http.request(request)
    response.code == '200'
  end

  def current_user
    uri = URI.parse("#{url}/api/v1/app/session/current_user")
    header = { 'Content-Type': 'application/json', AppToken: @app_token, Authorization: "Bearer #{@auth_token}" }

    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri, header)

    response = http.request(request)
    JSON.parse(response.body)
  end
end
