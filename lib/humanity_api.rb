require "uri"
require "net/http"
require "openssl"
require "json"

class HumanityApi
  attr_reader :errors
  attr_accessor :key, :token

  HUMANITY_BASE = "https://www.humanity.shiftplanning.com/api/"
  VALID_REQUEST_METHODS = %w(GET CREATE UPDATE DELETE)

  def initialize
    @token = ENV["HUMANITY_TOKEN"]
    @key = ENV["HUMANITY_KEY"]
    @errors = []
    @output_format = "json"
  end

  def errors?
    @errors.count > 0
  end

  def check_params_for_errors(body)
    key_error = "Invalid data packet: please provide a Humanity API key."
    module_error = "Invalid data packet: please provide the Humanity module." 

    @errors << key_error if !body[:key]
    @errors << module_error if !body[:request][:module]
  end

  def request_humanity_data(data)
    @errors = []
    request_params = build_request_params(data)
    humanity_response = make_request(request_params)
    parse_humanity_response(humanity_response)
  end

  def build_request_params(data)
    data[:token] ||=  @token
    data[:key]   ||=  @key

    request_params = data.dup
    request_params.reject! { |data_key, data_value| data_key == :token || data_key == :key || data_key == :output_format }
    request_params[:method] = data[:method] || "GET"
    request_params[:method].upcase!

    body = {
      :token    => data[:token],
      :key      => data[:key],
      :request  => request_params,
      :output   => @output_format
    }

    check_params_for_errors(body)
    return body
  end

  def make_request(body)
    return unless @errors.count == 0

    uri = URI(HUMANITY_BASE)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.path)
    request_params = JSON.generate(body)
    request.set_form_data({"data" => request_params})
    response = http.request(request)

    case response.code.to_i
    when 200 || 201
      JSON.parse(response.body)
    else
      @errors << "Request failed: #{response.value}"
      begin
        JSON.parse(response)
      rescue error
        { error: error }
      end
    end
  end

  def parse_humanity_response(response)
    if errors?
      { "error" => @errors.join(" ") }
    elsif response["status"] != 1
      response
    else
      response["data"]
    end
  end

end
