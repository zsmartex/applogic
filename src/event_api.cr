module EventAPI
  @@middlewares = Array(Middlewares::IncludeEventMetadata | Middlewares::GenerateJWT | Middlewares::PrintToScreen | Middlewares::PublishToKafka).new

  def self.notify(event_name : String, event_payload)
    arguments = { event_name, event_payload }

    arguments = Middlewares::IncludeEventMetadata.call(*arguments)
    arguments = Middlewares::GenerateJWT.call(*arguments)
    arguments = Middlewares::PrintToScreen.call(*arguments)
    arguments = Middlewares::PublishToKafka.call(*arguments)
  rescue e
    report_exception(e)
    raise e
  end

  def self.middlewares=(list)
    @@middlewares = list
  end

  def self.middlewares
    @@middlewares
  end

  module Middlewares
    def self.application_name
      :applogic
    end

    module IncludeEventMetadata
      def self.call(event_name : String, event_payload)
        { event_name, { :name => event_payload }.merge(event_payload) }
      end
    end

    module GenerateJWT
      def self.call(event_name, event_payload)
        jwt_payload = {
          jss:   Middlewares.application_name,
          jti:   UUID.random,
          iat:   Time.local.to_unix,
          exp:   (Time.local + 1.hour).to_unix,
          event: event_payload
        }

        private_key = Base64.decode_string(ENV["JWT_PRIVATE_KEY"])
        algorithm   = JWT::Algorithm::RS256

        jwt = JWT::Multisig.generate_jwt(
          jwt_payload,
          { Middlewares.application_name => Base64.decode_string(ENV["JWT_PRIVATE_KEY"]) },
          { Middlewares.application_name => JWT::Algorithm::RS256 }
        )

        { event_name, jwt }
      rescue e : KeyError
        raise "No EVENT_API_JWT_PRIVATE_KEY found in env!"
      end
    end

    module PrintToScreen
      def self.call(event_name : String, event_payload)
        Log.debug do
          ["",
           "Produced new event at " + Time.local.to_s + ": ",
           "name    = " + event_name,
           "payload = " + event_payload.to_json,
           ""].join("\n")
        end
        { event_name, event_payload }
      end
    end

    module PublishToKafka
      @@producer = Kafka::Producer.new({ "bootstrap.servers" => ENV["KAFKA_BROKERS"] })

      def self.call(event_name : String, event_payload)
        topic = "#{Middlewares.application_name}.events.#{event_name.split(".").first}"

        Log.debug do
          "\nPublishing #{topic} with key: #{event_name}.\n"
        end

        @@producer.produce(topic: topic, key: event_name.to_slice, payload: event_payload.to_json.to_slice)
        @@producer.flush
        { event_name, event_payload }
      end
    end

  end
end
