require "spec_helper"

describe HumanityApi do
  let(:humanity_api) { HumanityApi.new }

  let(:valid_data) {
    {
      :token => '',
      :key => 'dummy_key',
      :method => 'get',
      :module => 'api.config'
    }
  }

  let(:valid_request_params) {
    {
      :token => valid_data[:token],
      :key => valid_data[:key],
      :request => {
        :method => 'GET',
        :module => valid_data[:module]
      },
      :output => 'json'
    }
  }

  let(:invalid_request_params) {
    {
      :token => '',
      :key => '',
      :request => {
        :method => 'INVALID',
        :module => 'invalid.invalid'
      },
      :output => 'invalid'
    }
  }

  it "has a version number" do
    expect(HumanityApi::VERSION).not_to be nil
  end

  describe '#initialize' do
    it "sets an empty array for errors" do
      expect(humanity_api.errors).to eq([])
    end

    it "sets the output format" do
      expect(humanity_api.instance_variable_get(:@output_format)).to eq('json')
    end

    context "given that there is are specified environment variables" do
      before(:each) do
        allow(ENV).to receive(:[]).with("HUMANITY_TOKEN").and_return("foobarbaz123")
        allow(ENV).to receive(:[]).with("HUMANITY_KEY").and_return("123foobarbaz")
        @humanity_api = HumanityApi.new
      end

      it "sets the token from the environment variable" do
        expect(@humanity_api.token).to eq("foobarbaz123")
      end

      it "sets the key from the environment variable" do
        expect(@humanity_api.key).to eq("123foobarbaz")
      end
    end

    context "given that there are no specified environment variables" do
      it "does not set the token" do
        expect(humanity_api.token).to eq(nil)
      end

      it "does not set the key" do
        expect(humanity_api.key).to eq(nil)
      end
    end
  end

  describe '#errors?' do
    it "returns true if there are errors" do
      humanity_api.instance_variable_set(:@errors, ["An error message"])
      expect(humanity_api.errors?).to be(true)
    end

    it "returns false if there are no errors" do
      expect(humanity_api.errors?).to be(false)
    end
  end

  describe '#check_params_for_errors' do
    context "given that an invalid data packet is passed in" do
      it "adds an error message for a missing key" do
        invalid_request_params.delete(:key)
        request_params = humanity_api.check_params_for_errors(invalid_request_params)
        expect(humanity_api.errors).to include("Invalid data packet: please provide a Humanity API key.")
      end

      it "adds an error message for a missing request module" do
        invalid_request_params[:request].delete(:module)
        request_params = humanity_api.check_params_for_errors(invalid_request_params)
        expect(humanity_api.errors).to include("Invalid data packet: please provide the Humanity module.")
      end
    end
  end

  describe '#request_humanity_data' do
    it "calls the methods to necessary access the Humanity API" do
      expect(humanity_api).to receive(:build_request_params)
      expect(humanity_api).to receive(:make_request)
      expect(humanity_api).to receive(:parse_humanity_response)
      humanity_api.request_humanity_data({})
    end
  end

  describe '#build_request_params' do
    context "given that a valid data packet is passed in" do
      it "creates the humanity request parameters from the data" do
        expect(humanity_api.build_request_params(valid_data)).to eq(valid_request_params)
      end
    end

    context "given that a method is not passed in" do
      it "sets the default method as 'GET'" do
        valid_data.delete(:method)
        request_params = humanity_api.build_request_params(valid_data)
        expect(request_params[:request][:method]).to eq('GET')
      end
    end
  end

  describe '#make_request' do
    context "given that there are no errors" do
      it "makes a request to the humanity API" do
        valid_request_params[:token] = ''
        response = humanity_api.make_request(valid_request_params)
        expect(response['status']).to eq(1)
      end
    end

    context "given that there are errors" do
      it "returns out of the request call" do
        humanity_api.instance_variable_set(:@errors, ["An error message"])
        expect(humanity_api.make_request(valid_request_params)).to eq(nil)
      end
    end
  end

  describe '#parse_humanity_response' do
    context "given that there are errors" do
      it "returns a hash containing all the errors" do
        humanity_api.instance_variable_set(:@errors, ["An error message", "Another error message."])
        expect(humanity_api.parse_humanity_response("")).to eq({'error' => humanity_api.errors.join(" ")})
      end
    end

    context "given a failed response from Humanity" do
      it "returns Humanity's error message" do
        request = humanity_api.make_request(invalid_request_params)
        humanity_response = {"status"=>4, "data"=>"Invalid Method - No Method with that name exists in our API", "error"=>"unrecognized method: INVALID", "token"=>nil}
        expect(humanity_api.parse_humanity_response(request)).to eq(humanity_response)
      end
    end

    context "given a succesful response from Humanity" do
      it "returns the data from Humanity" do
        response = humanity_api.make_request(valid_request_params)
        expect(humanity_api.parse_humanity_response(response)).to eq(response['data'])
      end
    end
  end

end
