module SendgridPostback
  module EventReceiver

    def self.post_sendgrid_event(event_data)
      SendgridPostback.logger.info "Posted event data #{event_data.inspect}"
      sendgrid_events ||= []
      sendgrid_events << event_data
      sendgrid_events.each do |event|
        unless event["bulk_mail_id"] # don't create any records for non-bulkmail postbacks
          mail_postback = self.class.new
          mail_postback.bulk_mail_id = event.delete("bulk_mail_id") if event["bulk_mail_id"]
          mail_postback.event = event.delete("event") if event["event"]
          mail_postback.event_at = event.delete("timestamp") if event["timestamp"]
          mail_postback.recipient = event.delete("email") if event["email"]
          mail_postback.categories = event.delete("category") if event["category"] #This could be string or array
          mail_postback.attempt = event.delete("attempt").to_i if event["attempt"]
          mail_postback.url_clicked = event.delete("url") if event["url"]
          mail_postback.reason = event.delete("reason") if event["reason"]
          mail_postback.bounce_type = event.delete("type") if event["type"]
          mail_postback.response = event.delete("response") if event["response"]
          mail_postback.status = event.delete("status") if event["status"]
          mail_postback.unique_ids = event #dump the rest of the hash into unique ids
          mail_postback.save! # Blow an exception for now to aid debugging
        end
      end
    end
    
    private

    # Including class should persist sendgrid_events and sendgrid_state
    # Serialize if using ActiveRecord
    attr_accessor :sendgrid_events
    attr_accessor :sendgrid_state

    def post_sendgrid_event event_data
      # TODO: decompose events into a single event and capture timestamp and state for each event
      SendgridPostback.logger.info "Posted event data #{event_data.inspect}"
      sendgrid_events ||= []
      sendgrid_events << event_data
      sendgrid_state = Event.sorted(sendgrid_events).last['event']
      after_create_sendgrid_event(event_data)
    end

    # Override hook as necessary
    def after_create_sendgrid_event(event_data)
    end

  end

end
