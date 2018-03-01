require 'bugsnag'
require 'exception_notifier'

module ExceptionNotifier
  class BugsnagNotifier
    def initialize(options=nil, &default_block)
      @default_options = options
      @default_block = default_block
    end

    def call(exception, options={}, &block)
      merged_block = proc do |notification|
        @default_block.call(notification) if @default_block
        block.call(notification) if block
      end

      if @default_options
        Bugsnag.notify(exception, @default_options.merge(options), &merged_block)
      else
        Bugsnag.notify(exception, &merged_block)
      end
    end
  end
end
