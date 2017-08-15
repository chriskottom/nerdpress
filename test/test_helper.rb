require 'simplecov'
SimpleCov.start do
  add_filter '/test/'
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'nerdpress'

require "minitest/autorun"
require 'minitest/spec'
require 'minitest/mock'

require 'support/build_helpers'
require 'support/command_helpers'

class Minitest::Test
  include BuildHelpers

  def teardown
    reset_build
    super
  end
end
