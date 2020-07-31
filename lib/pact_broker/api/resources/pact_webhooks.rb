require 'pact_broker/api/resources/base_resource'
require 'pact_broker/api/decorators/webhook_decorator'
require 'pact_broker/api/decorators/webhooks_decorator'
require 'pact_broker/api/contracts/webhook_contract'

module PactBroker
  module Api
    module Resources
      class PactWebhooks < BaseResource

        def allowed_methods
          ["POST", "GET", "OPTIONS"]
        end

        def content_types_provided
          [["application/hal+json", :to_json]]
        end

        def content_types_accepted
          [["application/json", :from_json]]
        end

        def resource_exists?
          (!consumer_specified? || consumer) && (!provider_specified? || provider)
        end

        def malformed_request?
          if request.post?
            return invalid_json? || validation_errors?(webhook)
          end
          false
        end

        def validation_errors? webhook
          errors = webhook_service.errors(webhook)

          unless errors.empty?
            response.headers['Content-Type'] = 'application/hal+json;charset=utf-8'
            response.body = { errors: errors.messages }.to_json
          end

          !errors.empty?
        end

        def create_path
          webhook_url next_uuid, base_url
        end

        def post_is_create?
          true
        end

        def from_json
          saved_webhook = webhook_service.create next_uuid, webhook, consumer, provider
          response.body = Decorators::WebhookDecorator.new(saved_webhook).to_json(decoractor_options)
        end

        def to_json
          Decorators::WebhooksDecorator.new(webhooks).to_json(user_options: decorator_context(resource_title: 'Pact webhooks'))
        end

        private

        def webhooks
          webhook_service.find_by_consumer_and_provider consumer, provider
        end

        def webhook
          @webhook ||= Decorators::WebhookDecorator.new(PactBroker::Domain::Webhook.new).from_json(request_body)
        end

        def next_uuid
          @next_uuid ||= webhook_service.next_uuid
        end

      end
    end
  end
end
