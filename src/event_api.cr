module EventAPI
  @@middlewares = Array(Middlewares::IncludeEventMetadata | Middlewares::GenerateJWT | Middlewares::PrintToScreen | Middlewares::PublishToRabbitMQ).new

  def self.notify(event_name : String, event_payload)
    arguments = { event_name, event_payload }

    arguments = Middlewares::IncludeEventMetadata.call(*arguments)
    arguments = Middlewares::GenerateJWT.call(*arguments)
    arguments = Middlewares::PrintToScreen.call(*arguments)
    arguments = Middlewares::PublishToRabbitMQ.call(*arguments)
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
        Finex.logger.debug do
          ["",
           "Produced new event at " + Time.local.to_s + ": ",
           "name    = " + event_name,
           "payload = " + event_payload.to_json,
           ""].join("\n")
        end
        { event_name, event_payload }
      end
    end

    module PublishToRabbitMQ
      def self.call(event_name : String, event_payload)
        Finex.logger.debug do
          "\nPublishing #{routing_key(event_name)} (routing key) to #{exchange_name(event_name)} (exchange name).\n"
        end
        exchange = amqp_exchange(exchange_name(event_name))
        exchange.publish(event_payload.to_json, routing_key: routing_key(event_name))
        { event_name, event_payload }
      end

      def self.amqp_session
        ::AMQP::Client.new("amqp://#{ENV["RABBITMQ_USERNAME"]}:#{ENV["RABBITMQ_PASSWORD"]}@#{ENV["RABBITMQ_HOST"]}").connect
      end

      def self.amqp_channel
        amqp_session.channel
      end

      def self.amqp_exchange(name : String)
        amqp_channel.direct_exchange(name)
      end

      def self.exchange_name(event_name)
        "#{Middlewares.application_name}.events.#{event_name.split('.').first}"
      end

      def self.routing_key(event_name)
        str = event_name.split(".")
        str.shift
        str.join(".")
      end


    end
  end
end
