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

    context 'with block(s)' do
      let(:report) { double('Bugsnag::Report') }
      let(:default_block) do
        Proc.new do |report|
        end
      end
      let(:passed_block) do
        Proc.new do |report|
        end
      end

      before do
        allow(Bugsnag).to receive(:notify) do |exception, options, &block|
          block.call report
        end
      end

      it 'calls default block' do
        notifier = described_class.new(&default_block)
        expect(default_block).to receive(:call).with(report)
        notifier.call(exception)
      end

      it 'calls default block and passed block' do
        notifier = described_class.new(&default_block)
        expect(default_block).to receive(:call).with(report)
        expect(passed_block).to receive(:call).with(report)
        notifier.call(exception, &passed_block)
      end

      it 'calls passed block' do
        notifier = described_class.new
        expect(passed_block).to receive(:call).with(report)
        notifier.call(exception, &passed_block)
      end
    end
  end
end
