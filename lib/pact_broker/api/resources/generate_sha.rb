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
      class GenerateSha < BaseResource
        def content_types_provided
          [
            ["application/hal+json", :to_text],
            ["application/json", :to_text]
          ]
        end

        def allowed_methods
          ["GET", "OPTIONS"]
        end

        def to_text
          pact_version_sha
        end

        private

        def pact_version_sha
          json_content = request.body.to_s
          parsed = JSON.parse(json_content, PACT_PARSING_OPTIONS)
          json_content = parsed.to_json
          @pact_version_sha ||= PactBroker.configuration.sha_generator.call(json_content)
        end

      end
    end
  end
end
