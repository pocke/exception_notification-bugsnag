require 'spec_helper'

RSpec.describe ExceptionNotifier::BugsnagNotifier do
  describe '#call' do
    let(:exception) { RuntimeError.new }

    it 'calls Bugsnag#notify' do
      expect(Bugsnag).to receive(:notify).with(exception, {})
      described_class.new({}).call(exception)
    end

    it 'calls Bugsnag#notify with default options' do
      expect(Bugsnag).to receive(:notify).with(exception, severity: 'error')
      described_class.new(severity: 'error').call(exception)
    end

    it 'calls Bugsnag#notify with options' do
      expect(Bugsnag).to receive(:notify).with(exception, severity: 'error')
      described_class.new({}).call(exception, severity: 'error')
    end

    it 'calls Bugsnag#notify with override options' do
      expect(Bugsnag).to receive(:notify).with(exception, severity: 'error')
      described_class.new(severity: 'info').call(exception, severity: 'error')
    end
  end
end
