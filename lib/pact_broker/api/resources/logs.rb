require 'pact_broker/api/resources/base_resource'
require 'pact_broker/configuration'
require 'pact_broker/domain/verification'
require 'pact_broker/api/contracts/verification_contract'
require 'pact_broker/api/decorators/verification_decorator'
require 'pact_broker/api/decorators/extended_verification_decorator'

module PactBroker
  module Api
    module Resources
      class Logs < BaseResource
        def content_types_provided
          [
            ["application/hal+json", :to_text],
            ["application/json", :to_text]
          ]
        end

        def allowed_methods
          ["GET", "OPTIONS"]
        end

        def resource_exists?
          if identifier_from_path[:verification_number] == "all"
            set_json_error_message("To see all the verifications for a pact, use the Matrix page")
            false
          else
            !!verification
          end
        end

        def to_text
          verification[:logs]
        end

        private

        def verification
          @verification ||= verification_service.find_by_logs_id(identifier_from_path[:logsID])
        end

        def decorator_for model
          PactBroker::Api::Decorators::VerificationDecorator.new(model)
        end
      end
    end
  end
end
