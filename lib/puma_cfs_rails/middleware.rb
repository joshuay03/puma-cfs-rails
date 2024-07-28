# frozen_string_literal: true

require 'rails'

module PumaCFSRails
  class Middleware
    PATH_INFO = "PATH_INFO"
    REQUEST_METHOD = "REQUEST_METHOD"
    MIN_VRUNTIME = "MIN_VRUNTIME"
    PUMA_CFS_RAILS = "PUMA_CFS_RAILS"

    def initialize(app)
      @app = app
      @min_vruntimes = {}
    end

    def call(env)
      path_params = begin
        Rails.application.routes.recognize_path(env[PATH_INFO], method: env[REQUEST_METHOD])
      rescue ActionController::RoutingError
        {}
      end

      if key = key_from(path_params)
        env[MIN_VRUNTIME] = @min_vruntimes[key] ||= 0

        vruntime, (status, headers, body) = with_time_diff { @app.call(env) }

        @min_vruntimes[key] = vruntime if vruntime < @min_vruntimes[key]

        headers[PUMA_CFS_RAILS] = "Success"
      else
        status, headers, body = @app.call(env)

        headers[PUMA_CFS_RAILS] = "Error: Could not determine controller and action from path"
      end

      [status, headers, body]
    end

    private

    def key_from(path_params)
      if controller = path_params[:controller] && action = path_params[:action]
        "#{controller}-#{action}"
      end
    end

    def with_time_diff
      before = Time.now
      result = yield
      [Time.now - before, result]
    end
  end
end
