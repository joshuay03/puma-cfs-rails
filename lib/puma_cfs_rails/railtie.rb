# frozen_string_literal: true

require_relative 'middleware'

module PumaCFSRails
  class Railtie < ::Rails::Railtie
    initializer "puma_cfs_rails.use_middleware" do |app|
      app.middleware.use Middleware
    end
  end
end
