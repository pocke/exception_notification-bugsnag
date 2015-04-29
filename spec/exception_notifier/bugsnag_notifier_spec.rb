require 'spec_helper'

RSpec.describe ExceptionNotifier::BugsnagNotifier do
  describe '#call' do
    let(:exception) { RuntimeError.new }

    it do
      expect(Bugsnag).to receive(:auto_notify).with(exception)
      described_class.new({}).call(exception)
    end
  end
end
