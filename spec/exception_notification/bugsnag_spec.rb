require 'spec_helper'

describe ExceptionNotification::Bugsnag do
  it 'has a version number' do
    expect(ExceptionNotification::Bugsnag::VERSION).not_to be nil
  end
end
