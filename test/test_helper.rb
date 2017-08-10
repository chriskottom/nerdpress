require 'simplecov'
SimpleCov.start do
  add_filter '/test/'
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'nerdpress'

require "minitest/autorun"
require 'minitest/spec'
require 'minitest/mock'
