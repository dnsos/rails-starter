# Temporary compatibility fix for making Devise work with Rails 7's Turbo
# See https://www.youtube.com/watch?v=m3uhldUGVes
# Also see https://betterprogramming.pub/devise-auth-setup-in-rails-7-44240aaed4be
class TurboDeviseController < ApplicationController
  # Responder
  class Responder < ActionController::Responder
    def to_turbo_stream
      controller.render(options.merge(formats: :html))
    rescue ActionView::MissingTemplate => error
      if get?
        raise error
      elsif has_errors? && default_action
        render rendering_options.merge(
                 formats: :html,
                 status: :unprocessable_entity,
               )
      else
        redirect_to navigation_location
      end
    end
  end

  self.responder = Responder
  respond_to :html, :turbo_stream
end
