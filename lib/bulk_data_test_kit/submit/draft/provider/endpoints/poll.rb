# frozen_string_literal: true

require 'smart_app_launch_test_kit'
require_relative '../jobs/retrieve_files'

module BulkDataTestKit
  module Submit
    module Draft
      module Provider
        module Endpoints
          class Poll < Inferno::DSL::SuiteEndpoint
            include URLs
            include Helpers

            def test_run_identifier
              return request.params[:session_path] if request.params[:session_path].present?

              SMARTAppLaunch::MockSMARTServer.issued_token_to_client_id(
                request.headers['Authorization']&.delete_prefix('Bearer ')
              )
            end

            def completed_file_download_requests
              requests_repo.tagged_requests(test_run.test_session_id, [FILE_DOWNLOAD_TAG]).count
            end

            def file_count_to_download
              manifest_requests =
                requests_repo.tagged_requests(test_run.test_session_id, [MANIFEST_TAG])
                  .map { |request| JSON.parse(request.response_body).deep_symbolize_keys }

              manifest_requests.reduce(0) do |count, manifest|
                count + manifest[:output].count
              end
            end

            def done_downloading_files?
              done = completed_file_download_requests
              total = file_count_to_download
              puts "#{done}/#{total}"

              total.positive? && done >= total
            end

            def poll_request_count
              requests_repo.tagged_requests(test_run.test_session_id, [POLL_TAG]).count
            end

            def kickoff_file_downloads
              Inferno::Jobs.perform(
                BulkDataTestKit::Submit::Draft::Provider::Jobs::RetrieveFiles,
                test_run.test_session_id,
                result.id
              )
            end

            def update_result
              results_repo.update(result.id, result: 'pass') if done_downloading_files?
            end

            def make_response
              kickoff_file_downloads if poll_request_count.zero?

              response.status =
                if done_downloading_files?
                  200
                else
                  202
                end

              response.headers['Content-Type'] = 'application/json'
              response.body = complete_manifest(request).to_json
            end

            def tags
              [POLL_TAG]
            end
          end
        end
      end
    end
  end
end
