# frozen_string_literal: true

require 'rails'

module PumaCFSRails
  class Middleware
    EMPTY_KEY = "".freeze

    def initialize(app)
      @app = app
      @min_vruntimes = {}
    end

    def call(env)
      request = ActionDispatch::Request.new(env)
      path_params = begin
        Rails.application.routes.recognize_path(request.path, method: request.request_method)
      rescue ActionController::RoutingError
        {}
      end
      key = key_from(path_params)

      env["MIN_VRUNTIME"] = @min_vruntimes[key] ||= 0
      duration, response = with_time_diff { @app.call(env) }
      unless key == EMPTY_KEY || (@min_vruntimes[key] > 0 && @min_vruntimes[key] < duration)
        @min_vruntimes[key] = duration
      end

      response
    end

    private

    def key_from(path_params)
      if (controller = path_params[:controller]) && (action = path_params[:action])
        "#{controller}-#{action}"
      else
        EMPTY_KEY
      end
    end

    def with_time_diff
      before = Time.now
      result = yield
      [Time.now - before, result]
    end
  end
end
