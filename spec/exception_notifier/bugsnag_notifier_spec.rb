require 'spec_helper'

RSpec.describe ExceptionNotifier::BugsnagNotifier do
  describe '#call' do
    let(:exception) { RuntimeError.new }
    let(:report) { instance_double('Bugsnag::Report') }

    it 'calls Bugsnag#notify' do
      expect(Bugsnag).to receive(:notify).with(exception).and_yield(report)
      described_class.new({}).call(exception)
    end

    it 'calls Bugsnag#notify with default options' do
      expect(report).to receive(:severity=).with('error')
      expect(Bugsnag).to receive(:notify).with(exception).and_yield(report)
      described_class.new(severity: 'error').call(exception)
    end

    it 'calls Bugsnag#notify with options' do
      expect(report).to receive(:severity=).with('error')
      expect(Bugsnag).to receive(:notify).with(exception).and_yield(report)
      described_class.new({}).call(exception, severity: 'error')
    end

    it 'calls Bugsnag#notify with override options' do
      expect(report).to receive(:severity=).with('error')
      expect(Bugsnag).to receive(:notify).with(exception).and_yield(report)
      described_class.new(severity: 'info').call(exception, severity: 'error')
    end

    it 'calls Bugsnag#notify with invalid options' do
      expect { described_class.new.call(exception, nil) }.to raise_error(TypeError)
    end

    it 'ignores passed unknown options' do
      expect(Bugsnag).to receive(:notify) do |_exception, &block|
        block.call report
      end
      expect(report).to receive(:severity=).with('info')
      described_class.new.call(exception, foo: 1, bar: 2, severity: 'info')
    end

    context 'with block(s)' do
      let(:passed_block) do
        proc do |report|
          report.add_tab :user, name: 'foo'
        end
      end

      before do
        allow(Bugsnag).to receive(:notify) do |_exception, &block|
          block.call report
        end
      end

      it 'calls passed block' do
        expect(passed_block).to receive(:call).with(report)
        described_class.new.call(exception, &passed_block)
      end
    end
  end
end
