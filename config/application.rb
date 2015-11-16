require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Gams
  class Application < Rails::Application

    $gams_config = YAML.load_file("#{Rails.root}/config/config.yml")

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    # Set default application language
    config.i18n.default_locale = :'it'

    # Set default back-office language (en.yml, it.yml)
    $language = YAML.load_file("#{Rails.root}/config/languages/it.yml")
  end
end
