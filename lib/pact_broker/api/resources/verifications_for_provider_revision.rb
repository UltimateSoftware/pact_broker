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
            ["application/hal+json", :to_json],
            ["application/json", :to_json]
          ]
        end

        def allowed_methods
          ["GET", "OPTIONS"]
        end

        def to_json
          verification
        end

        private

        def verification
          @verification ||= verification_service.find_by_revision_and_pact_version(identifier_from_path[:revision], pact[:pact_version_id])
        end

        def pact
            params = new (
              consumer_name: pact_params[:consumer_name_in_pact],
              provider_name: pact_params[:provider_name_in_pact],
              pact_version_sha: pact_service.generate_sha()
            )
            rescue => exception
              
            end
            @pact ||= pact_service.find_pact(params)
        end
  
        def pact_params
            @pact_params ||= PactBroker::Pacts::PactParams.from_request request, path_info
        end

        def decorator_for model
          PactBroker::Api::Decorators::VerificationDecorator.new(model)
        end
      end
    end
  end
end
