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
          accessor = "#{key}=".to_sym
          if report.respond_to?(accessor)
            report.public_send(accessor, value)
          end
        end

        block.call(report) if block
      end

      Bugsnag.notify(exception, &wrapped_block)
    end
  end
end
