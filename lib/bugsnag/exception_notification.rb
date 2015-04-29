require 'bugsnag'
require 'exception_notifier'

module ExceptionNotifier
  class BugsnagNotifier
    def initialize(options)
    end

    def call(exception, options={})
      Bugsnag.auto_notify(exception)
    end
  end
end
