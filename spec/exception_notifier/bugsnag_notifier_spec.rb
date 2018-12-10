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

    context 'with `:env` option' do
      let(:rack_env) { { 'rack.version' => [1, 3] } }
      let(:config) { instance_double('Bugsnag::Configuration') }

      before do
        allow(report).to receive(:configuration).and_return(config)
        allow(Bugsnag).to receive(:notify) do |_exception, &block|
          block.call report
        end
      end

      it 'ignores the option' do
        expect(config).to receive(:send_environment).and_return(false)
        expect(report).not_to receive(:add_tab)
        described_class.new.call(exception, env: rack_env)
      end

      it 'adds a tab for the option' do
        expect(config).to receive(:send_environment).and_return(true)
        expect(report).to receive(:add_tab).with(:environment, rack_env)
        described_class.new.call(exception, env: rack_env)
      end
    end
  end
end
