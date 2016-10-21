# BDD EXAMPLES:
# foo = HumanityAPI.new
# foo.token = 'asdfasdf'
# puts foo.key
# resp = foo.fetch_humanity_data({
#     bas: 4
# })
# if foo.errors?
#   puts 'oh no'
#   puts foo.errors.first
# else
#   put resp[:name]
# end

require "humanity_api/version"
require "uri"
require "net/http"

module HumanityApi

  @@errors = []

  HUMANITY_BASE = 'https://www.humanity.shiftplanning.com/api/'
  HUMANITY_TOKEN = ENV['HUMANITY_TOKEN']
  HUMANITY_KEY = ENV['HUMANITY_KEY']
  VALID_REQUEST_METHODS = %w(GET CREATE UPDATE DELETE)

  def fetch_humanity_data(data)
    request_params = build_request_params(data)
    humanity_response = make_request(request_params)
    parse_humanity_response(humanity_response)
  end

  def build_request_params(data)
    token = data[:token] || HUMANITY_TOKEN
    key = data[:key] || HUMANITY_KEY
    request_params = data.reject(:token, :key)

    request_params[:method] = data[:method].upcase || 'GET'

    if key == nil
      @@errors << "Invalid data packet: please provide a Humanity API key."
    elsif token == nil
      @@errors << "Invalid data packet: please provide a Humanity auth token."
    elsif VALID_REQUEST_METHODS.include?(request_params[:method])
      @@errors << "Invalid data packet: please provide a valid request method of 'GET', 'CREATE', 'UPDATE', or 'DELETE'."
    end

    body = {
      :token    => token,
      :key      => key,
      :request  => request_params,
      :output   => 'json'
    }
  end

  def make_request(body)
    return unless @@errors.count == 0

    uri = URI(HUMANITY_BASE)
    req = Net::HTTP::Post.new(uri)
    req.set_form_data({"data" => body})
    response = Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(req) }

    case response
    when Net::HTTPSuccess, Net::HTTPRedirection
      JSON.parse(response.body)
    else
      @@errors << "Request failed: #{response.value}"
      JSON.parse(response) # think about when this will return falsey/nil/error
    end
  end

  def parse_humanity_response(response)
    if @@errors.count != 0
      @@errors.join(" ")
    elsif response['status'] != "1"
      response
    else
      response['data']
    end
  end
end
