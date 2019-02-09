require 'bugsnag'
require 'exception_notifier'

module ExceptionNotifier
  class BugsnagNotifier
    def initialize(options=nil)
      @default_options = options || {}
    end

    def call(exception, options={}, &block)
      options = @default_options.merge(options)

      wrapped_block = proc do |report|
        options.each do |key, value|
          case
          when support_rack?(key)
            process_rack(report, value)
          when support_sidekiq?(key, value)
            process_sidekiq(report, value)
          when support_resque?(key, value)
            process_resque(report, value)

          # Support any attributes.
          when report.respond_to?("#{key}=")
            report.public_send("#{key}=", value)

          # Just warn instead of an error because it's tough to support
          # all data formats which ExceptionNotification may pass.
          else
            warn "#{self.class.name} does not know the data: `#{key.inspect}=>#{value.inspect}`"
          end
        end

        block.call(report) if block
      end

      Bugsnag.notify(exception, &wrapped_block)
    end

    private

    # `:env` option can be passed as a Rack Env object by `ExceptionNotification::Rack`.
    # Bugsnag provides the way to report the Env object by default.
    #
    # @see https://github.com/smartinez87/exception_notification/blob/v4.3.0/lib/exception_notification/rack.rb#L51
    # @see https://github.com/bugsnag/bugsnag-ruby/blob/v6.0.0/lib/bugsnag/middleware/rack_request.rb#L61-L63
    # @see https://docs.bugsnag.com/platforms/ruby/rails/configuration-options/#send_environment
    def support_rack?(key)
      key == :env
    end

    def process_rack(report, value)
      if report.configuration.send_environment
        report.add_tab(:environment, value)
      end
    end

    # Support Sidekiq data format.
    #
    # @see https://github.com/smartinez87/exception_notification/blob/v4.3.0/lib/exception_notification/sidekiq.rb#L28
    def support_sidekiq?(key, value)
      key == :data && value.is_a?(Hash) && value.include?(:sidekiq)
    end

    def process_sidekiq(report, value)
      report.add_tab(:sidekiq, value[:sidekiq])
    end

    # Support Resque data format.
    #
    # @see https://github.com/smartinez87/exception_notification/blob/v4.3.0/lib/exception_notification/resque.rb#L20
    def support_resque?(key, value)
      key == :data && value.is_a?(Hash) && value.include?(:resque)
    end

    def process_resque(report, value)
      report.add_tab(:resque, value[:resque])
    end
  end
end
