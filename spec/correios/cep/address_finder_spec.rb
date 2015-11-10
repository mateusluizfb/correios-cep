require 'spec_helper'

describe Correios::CEP::AddressFinder do
  context 'when zipcode is valid' do
    let(:zipcode) { '54250610' }
    let(:web_service_response) { '<end>Rua Fernando Amorim</end>' }
    let(:address) { { address: 'Rua Fernando Amorim' } }
    let(:web_service) { double(Correios::CEP::WebService) }
    let(:parser) { double(Correios::CEP::Parser) }
    let(:dependencies) { { web_service: web_service, parser: parser } }

    before do
      allow(web_service).to receive(:request).with(zipcode).and_return(web_service_response)
      allow(parser).to receive(:hash).with(web_service_response).and_return(address)
    end

    describe '#get' do
      subject { described_class.new(dependencies) }

      it 'returns address' do
        expect(subject.get(zipcode)).to eq address
      end
    end

    describe '.get' do
      subject { described_class }

      it 'returns address' do
        expect(subject.get(zipcode, dependencies)).to eq address
      end
    end
  end

  context 'when zipcode is not valid' do
    {
      'zipcode is required' => {
        'nil value' => nil,
        'empty value' => ''
      },
      'zipcode in invalid format (valid format: 00000-000)' => {
        'less than 8 digits' => '1234567',
        'invalid format' => '1234-5678'
      }
    }.each do |error_message, values|
      values.each do |text, value|
        context "with #{text}" do
          it "raises ArgumentError with '#{error_message}' error message" do
            expect { subject.get(value) }.to raise_error(ArgumentError, error_message)
          end
        end
      end
    end
  end
end
