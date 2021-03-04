module EventAPI
  @@middlewares = Array(Middlewares::IncludeEventMetadata | Middlewares::GenerateJWT | Middlewares::PrintToScreen | Middlewares::PublishToRabbitMQ).new

  def notify(event_name : String, event_payload)
    arguments = [event_name, event_payload]
    middlewares.each do |middleware|
      returned_value = middleware.call(*arguments)
      case returned_value
      when Array then arguments = returned_value
      else return returned_value
      end
    rescue e
      report_exception(e)
      raise e
    end
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

    class IncludeEventMetadata
      def call(event_name, event_payload)
        event_payload[:name] = event_name
        [event_name, event_payload]
      end
    end

    class GenerateJWT
      def call(event_name, event_payload)
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
          { application_name => Base64.decode_string(ENV["JWT_PRIVATE_KEY"]) },
          { application_name => JWT::Algorithm::RS256 }
        )

        [event_name, jwt]
      rescue e : KeyError
        raise "No EVENT_API_JWT_PRIVATE_KEY found in env!"
      end
    end

    class PrintToScreen
      def call(event_name, event_payload)
        Finex.logger.debug do
          ["",
           "Produced new event at " + Time.local.to_s + ": ",
           "name    = " + event_name,
           "payload = " + event_payload.to_json,
           ""].join("\n")
        end
        [event_name, event_payload]
      end
    end

    class PublishToRabbitMQ
      def call(event_name, event_payload)
        Finex.logger.debug do
          "\nPublishing #{routing_key(event_name)} (routing key) to #{exchange_name(event_name)} (exchange name).\n"
        end
        exchange = bunny_exchange(exchange_name(event_name))
        exchange.publish(event_payload.to_json, routing_key: routing_key(event_name))
        [event_name, event_payload]
      end

      def amqp_session
        ::AMQP::Client.new("amqp://#{ENV["RABBITMQ_USERNAME"]}:#{ENV["RABBITMQ_PASSWORD"]}@#{ENV["RABBITMQ_HOST"]}").connect
      end

      def amqp_channel
        amqp_session.channel
      end

      def amqp_exchange(name : String)
        amqp_channel.direct_exchange(name)
      end

      def exchange_name(event_name)
        "#{Middlewares.application_name}.events.#{event_name.split('.').first}"
      end

      def routing_key(event_name)
        event_name.split('.').drop(1).join('.')
      end


    end
  end

  middlewares << Middlewares::IncludeEventMetadata.new
  middlewares << Middlewares::GenerateJWT.new
  middlewares << Middlewares::PrintToScreen.new
  middlewares << Middlewares::PublishToRabbitMQ.new
end
