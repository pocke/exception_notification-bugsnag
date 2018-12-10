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
          # NOTE: `:env` option can be passed as a Rack Env object by `ExceptionNotification::Rack`.
          #       Bugsnag provides the way to report the Env object by default.
          #
          # See below:
          # - https://github.com/smartinez87/exception_notification/blob/2443af19e4c7433c7439c6ff01922a54023b89dd/lib/exception_notification/rack.rb#L51
          # - https://github.com/bugsnag/bugsnag-ruby/blob/46d345d93dcb715c977615d24b369da204ed7b72/lib/bugsnag/middleware/rack_request.rb#L74-L76
          # - https://docs.bugsnag.com/platforms/ruby/rails/configuration-options/#send_environment
          if key == :env
            if report.configuration.send_environment
              report.add_tab(:environment, value)
            end
          else
            report.public_send("#{key}=", value)
          end
        end

        block.call(report) if block
      end

      Bugsnag.notify(exception, &wrapped_block)
    end
  end
end
