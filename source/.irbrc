require 'irb/completion'

if defined?(ActiveRecord)
  ActiveRecord::Base.logger.level = Logger::INFO
end
