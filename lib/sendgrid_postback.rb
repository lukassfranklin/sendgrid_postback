
module SendgridPostback

  @@root = File.expand_path('../..', __FILE__)
  mattr_reader :root

  autoload :EventsController,                    "#{root}/app/controllers/sendgrid_postback/events_controller"

  autoload :Event,                               "#{root}/lib/sendgrid_postback/event"
  autoload :EventReceiver,                       "#{root}/lib/sendgrid_postback/event_receiver"
  autoload :MailInterceptor,                     "#{root}/lib/sendgrid_postback/mail_interceptor"

  class Config
    attr_accessor :logger
    attr_accessor :report_exception
    attr_accessor :find_receiver_by_uuid
    attr_accessor :get_general_event_receiver
    attr_accessor :request_path
    attr_accessor :enable_interceptor
    attr_accessor :require_ssl
    attr_accessor :insert_events_separately
    attr_accessor :receiver #If insert_events_separately is true, we need a receiver class vs an instance

    def initialize
      #@report_exception = proc { |exc| }
      enable_interceptor ||= true
      require_ssl ||= true
      insert_event_separately ||= false
    end
  end

  class << self
    delegate :logger, :to => :config

    def configure &block
      yield config
    end

    def config
      @config ||= Config.new
    end
  end

end

require 'sendgrid_postback/engine'
require 'sendgrid_postback/action_dispatch_ext'
require "sendgrid_postback/version" unless SendgridPostback::VERSION
