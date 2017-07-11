require 'bugsnag'
require 'exception_notifier'

module ExceptionNotifier
  class BugsnagNotifier
    def initialize(options={})
      @defaults = options
    end

    def call(exception, options={})
      Bugsnag.notify(exception, @defaults.merge(options))
    end
  end
end
