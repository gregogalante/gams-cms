# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Remove deprecation advice
ActiveSupport::Deprecation.silenced = true

# Initialize the Rails application.
Rails.application.initialize!
