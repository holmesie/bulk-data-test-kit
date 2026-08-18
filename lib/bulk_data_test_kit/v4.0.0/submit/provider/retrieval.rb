# frozen_string_literal: true

require 'smart_app_launch_test_kit'
require_relative 'helpers'

module BulkDataTestKit
  module BulkDataV400
    module Submit
      module Provider
        module Retrieval
          FAILURE_DIAGNOSTIC = 'Bulk Submit retrieval failed.'

          def completed_submission_identities
            completed_submission_timelines.keys
          end

          def completed_submission_timelines
            @completed_submission_timelines ||=
              valid_completed_submission_timelines(parsed_submissions)
          end

          def parsed_submissions
            @parsed_submissions ||= parsed_submission_parameters(load_tagged_requests(SUBMIT_TAG))
          end

          def retrieval_contexts(identity)
            Array(completed_submission_timelines[identity]).flat_map do |parameters|
              oauth_metadata_url = parameters.parameter.find do |parameter|
                parameter.name == 'oauthMetadataUrl' && parameter.valueUrl.present?
              end&.valueUrl

              parameters.parameter.filter_map do |parameter|
                next unless parameter.name == 'manifestUrl' && parameter.valueUrl.present?

                { manifest_url: parameter.valueUrl, oauth_metadata_url: }
              end
            end
          end

          def retrieve_submission(identity)
            retrieval_contexts(identity).each do |context|
              retrieve_manifest_and_files(context)
            end
          end

          def retrieve_manifest_and_files(context)
            headers = { 'Accept' => 'application/json' }
            if context[:oauth_metadata_url]
              headers['Authorization'] = "Bearer #{access_token(context[:oauth_metadata_url])}"
            end

            manifest_request = get(context[:manifest_url], headers:, tags: [MANIFEST_TAG])
            require_success(manifest_request)
            manifest = JSON.parse(manifest_request.response_body).deep_symbolize_keys
            raise 'The retrieved manifest was not a JSON object' unless manifest.is_a?(Hash)

            file_headers = { 'Accept' => 'application/fhir+ndjson' }
            if context[:oauth_metadata_url] && manifest[:requiresAccessToken]
              file_headers['Authorization'] = "Bearer #{access_token(context[:oauth_metadata_url])}"
            end

            Array(manifest[:output]).each do |output|
              file_request = get(
                output[:url],
                headers: file_headers,
                tags: [FILE_DOWNLOAD_TAG, output[:type].to_s]
              )
              require_success(file_request)
            end
          end

          def require_success(request)
            return request if request.status.to_i == 200

            raise "Retrieval request to #{request.url} failed with status #{request.status}"
          end

          def oauth_metadata(metadata_url)
            oauth_metadata_cache[metadata_url] ||= begin
              metadata_request = get(metadata_url, tags: [OAUTH_METADATA_TAG])
              require_success(metadata_request)
              metadata = JSON.parse(metadata_request.response_body).deep_symbolize_keys
              raise 'The retrieved OAuth metadata was not a JSON object' unless metadata.is_a?(Hash)

              metadata
            end
          end

          def access_token(metadata_url)
            token = token_response(metadata_url)[:access_token]
            raise 'OAuth token response did not include an access token' if token.blank?

            token
          end

          def token_response(metadata_url)
            token_response_cache[metadata_url] ||= begin
              endpoint = oauth_metadata(metadata_url)[:token_endpoint]
              raise 'OAuth metadata did not include a token endpoint' if endpoint.blank?

              request_details = token_request(endpoint)
              token_request_result = post(
                endpoint,
                body: request_details[:body],
                headers: request_details[:headers],
                tags: [TOKEN_TAG]
              )
              require_success(token_request_result)
              response = JSON.parse(token_request_result.response_body).deep_symbolize_keys
              raise 'The OAuth token response was not a JSON object' unless response.is_a?(Hash)

              response
            end
          end

          def token_request(audience)
            SMARTAppLaunch::BackendServicesAuthorizationRequestBuilder.build(
              encryption_method: consumer_auth_info.encryption_algorithm,
              scope: consumer_auth_info.requested_scopes,
              iss: consumer_auth_info.client_id,
              sub: consumer_auth_info.client_id,
              aud: audience,
              kid: consumer_auth_info.kid,
              custom_jwks: consumer_auth_info.jwks
            )
          end

          def oauth_metadata_cache
            @oauth_metadata_cache ||= {}
          end

          def token_response_cache
            @token_response_cache ||= {}
          end
        end
      end
    end
  end
end
