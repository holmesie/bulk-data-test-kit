module BulkDataTestKit
  module Submit
    module Draft
      module Provider
        module Jobs
          class RetrieveFiles
            include Sidekiq::Worker

            sidekiq_options retry: 0

            attr_reader :test_session_id, :result_id

            def perform(test_session_id, result_id)
              @test_session_id = test_session_id
              @result_id = result_id

              download_files
            end

            def requests_repo
              Inferno::Repositories::Requests.new
            end

            def session_data_repo
              Inferno::Repositories::SessionData.new
            end

            def connection
              Faraday.new do |f|
                f.request :url_encoded
                f.use FaradayMiddleware::FollowRedirects
              end
            end

            def submissions
              @submissions ||=
                requests_repo
                  .tagged_requests(test_session_id, [SUBMIT_TAG])
                  .map(&:request_body)
                  .map { |body_text| JSON.parse(body_text) }
                  .map(&:deep_symbolize_keys)
            end

            def manifest_url_list
              submissions.map do |parameters|
                parameters[:parameter]
                  .find { |parameter| parameter[:name] == 'manifestUrl' }
                  &.dig(:valueString)
              end.compact
            end

            def manifests
              @manifests ||=
                begin
                  headers = { 'Accept' => 'application/json' }

                  headers.merge!('Authorization' => "Bearer #{access_token}") if oauth_metadata_url

                  requests = manifest_url_list.map do |url|
                    raw_response = connection.get(url, nil, headers)

                    request = Inferno::Entities::Request.from_http_response(
                      raw_response, direction: 'outgoing', test_session_id:, tags: [MANIFEST_TAG]
                    )

                    request_id = requests_repo.create(request.to_hash.merge(result_id:)).id
                    requests_repo.class::Model.find(id: request_id)
                  end

                  requests
                    .map(&:response_body)
                    .map { |body| JSON.parse(body) }
                    .map(&:deep_symbolize_keys)
                end
            end

            def download_files
              manifests.each do |manifest|
                headers = { 'Accept' => 'application/fhir+ndjson' }

                if oauth_metadata_url && manifest[:requiresAccessToken]
                  headers.merge!('Authorization' => "Bearer #{access_token}")
                end

                manifest[:output].each do |output|
                  raw_response = connection.get(output[:url], nil, headers)

                  request = Inferno::Entities::Request.from_http_response(
                    raw_response,
                    direction: 'outgoing',
                    test_session_id:,
                    tags: [FILE_DOWNLOAD_TAG, output[:type].to_s]
                  )

                  requests_repo.create(request.to_hash.merge(result_id:))
                end
              end
            end

            def recipient_auth_info
              @recipient_auth_info ||=
                session_data_repo.load(test_session_id:, name: :recipient_auth_info, type: :auth_info)
            end

            def oauth_metadata_url
              submissions
                .flat_map { |submission| submission[:parameter] }
                .find { |param| param[:name] == 'oauthMetadataUrl' && param[:valueString].present? }
                &.dig(:valueString)
            end

            def oauth_metadata
              @oauth_metadata ||=
                if oauth_metadata_url.nil?
                  {}
                else
                  raw_response = connection.get(oauth_metadata_url, nil)

                  request = Inferno::Entities::Request.from_http_response(
                    raw_response,
                    direction: 'outgoing',
                    test_session_id:,
                    tags: [OAUTH_METADATA_TAG]
                  )

                  requests_repo.create(request.to_hash.merge(result_id:))

                  JSON.parse(request.response_body).deep_symbolize_keys
                end
            end

            def token_url
              oauth_metadata[:token_endpoint]
            end

            def access_token
              token_response[:access_token]
            end

            def token_request
              SMARTAppLaunch::BackendServicesAuthorizationRequestBuilder.build(
                encryption_method: recipient_auth_info.encryption_algorithm,
                scope: recipient_auth_info.requested_scopes,
                iss: recipient_auth_info.client_id,
                sub: recipient_auth_info.client_id,
                aud: recipient_auth_info.token_url,
                kid: recipient_auth_info.kid,
                custom_jwks: recipient_auth_info.jwks
              )
            end

            def token_response
              @token_response ||=
                begin
                  return {} if token_url.blank?

                  raw_response =
                    connection
                      .post(token_url, token_request[:body], token_request[:headers])

                  request = Inferno::Entities::Request.from_http_response(
                    raw_response,
                    direction: 'outgoing',
                    test_session_id:,
                    tags: [TOKEN_TAG]
                  )

                  requests_repo.create(request.to_hash.merge(result_id:))

                  JSON.parse(raw_response.body).deep_symbolize_keys
                end
            end
          end
        end
      end
    end
  end
end
