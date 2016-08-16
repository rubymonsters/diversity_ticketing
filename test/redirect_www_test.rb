require 'test_helper'
require 'redirect_www'

class RedirectWWWTest < ActiveSupport::TestCase
  describe "incoming requests" do
    it "www.diversitytickets.org should redirect to diversitytickets.org" do
      app = ->(env) { [200, {}, []] }
      middleware = RedirectWWW.new(app)
      env = Rack::MockRequest.env_for("http://www.diversitytickets.org/hello")
      response = middleware.call(env)

      assert_equal 301, response[0]
      assert_equal "https://diversitytickets.org/hello", response[1]["Location"]
    end

    it "diversitytickets.org should be passed through" do
      app = ->(env) { [200, {}, []] }
      middleware = RedirectWWW.new(app)
      env = Rack::MockRequest.env_for("http://diversitytickets.org/hello")
      response = middleware.call(env)

      assert_equal 200, response[0]
    end

    it "should cope with query strings" do
      app = ->(env) { [200, {}, []] }
      middleware = RedirectWWW.new(app)
      env = Rack::MockRequest.env_for("http://www.diversitytickets.org/hello?q=foooo")
      response = middleware.call(env)

      assert_equal "https://diversitytickets.org/hello?q=foooo", response[1]["Location"]
    end
  end
end