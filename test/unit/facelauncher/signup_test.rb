require 'test_helper'

module Facelauncher
  class SignupTest < ActiveSupport::TestCase
    test "should not save signup without program access key" do
      signup = Signup.new
      assert !signup.save
    end
  end
end
