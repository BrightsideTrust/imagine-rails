require "imagine-rails"
require "imagine/attachment_helper"

module Refile
  # @api private
  class Engine < Rails::Engine
    initializer "imagine-rails.setup", before: :load_environment_config do
      ActiveSupport.on_load :active_record do
        require "imagine/active_record/attachment"
      end

      ActionView::Base.send(:include, Imagine::AttachmentHelper)
      ActionView::Helpers::FormBuilder.send(:include, Imagine::AttachmentHelper::FormBuilder)
    end

  end
end
