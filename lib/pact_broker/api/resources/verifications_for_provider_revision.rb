require 'pact_broker/api/resources/base_resource'
require 'pact_broker/configuration'
require 'pact_broker/domain/verification'
require 'pact_broker/pacts/generate_sha.rb'
require 'pact_broker/api/contracts/verification_contract'
require 'pact_broker/api/decorators/verification_decorator'
require 'pact_broker/api/decorators/extended_verification_decorator'

module PactBroker
  module Api
    module Resources
      class VerificationsForProviderRevision < BaseResource
        def content_types_provided
          [
            ["application/hal+json", :to_json],
            ["application/json", :to_json]
          ]
        end

        def allowed_methods
          ["GET", "OPTIONS"]
        end

        def resource_exists?
          !!resource
        end

        def resource
          verification
        end

        def to_json
          decorator_for(verification).to_json(user_options: { base_url: base_url })
        end

        private

        def verification
          @verification ||= verification_service.find_by_version_and_pact_version(identifier_from_path[:provider_name], identifier_from_path[:provider_version_number], pact)
        end

        def pact
            request
            @pact ||= pact_service.find_pact_by_pact_version_sha(pact_version_sha)
        end

        def pact_version_sha
          json_content = request.body.to_s
          parsed = JSON.parse(json_content, PACT_PARSING_OPTIONS)
          json_content = parsed.to_json
          @pact_version_sha ||= PactBroker.configuration.sha_generator.call(json_content)
        end

        def decorator_for model
          PactBroker::Api::Decorators::VerificationDecorator.new(model)
        end
      end
    end
  end
end
