# frozen_string_literal: true

require 'digest'
require_relative '../shared/submission_status'

module BulkDataTestKit
  module BulkDataV400
    module Submit
      module Provider
        module Helpers
          TERMINAL_SUBMISSION_STATUSES = %w[completed stopped].freeze

          def submission_identity(parameters)
            parameter_list = parameters.respond_to?(:parameter) ? parameters.parameter : []
            submitter = parameter_list.find { |parameter| parameter.name == 'submitter' }&.valueIdentifier
            submission_id = parameter_list.find do |parameter|
              parameter.name == 'submissionId'
            end&.valueString

            return if submitter&.system.blank? || submitter&.value.blank? || submission_id.blank?

            {
              submitter_system: submitter.system,
              submitter_value: submitter.value,
              submission_id:
            }
          end

          def submission_status(parameters)
            parameter_list = parameters.respond_to?(:parameter) ? parameters.parameter : []
            status_parameters = parameter_list.select do |parameter|
              parameter.name == 'submissionStatus'
            end
            return unless status_parameters.one?

            coding = status_parameters.first.valueCoding

            return unless coding&.system == Shared::SubmissionStatus::SYSTEM

            coding.code
          end

          def parsed_submission_parameters(requests)
            requests.filter_map do |request|
              parameters = FHIR.from_contents(request.request_body)
              parameters if parameters.is_a?(FHIR::R4::Parameters)
            rescue JSON::ParserError, TypeError
              nil
            end
          end

          def submission_timelines(parameters_list)
            parameters_list.each_with_object({}) do |parameters, timelines|
              identity = submission_identity(parameters)
              next unless identity

              (timelines[identity] ||= []) << parameters
            end
          end

          def valid_completed_submission_timelines(parameters_list)
            submission_timelines(parameters_list).select do |_identity, timeline|
              terminal_indexes = timeline.each_index.select do |index|
                TERMINAL_SUBMISSION_STATUSES.include?(submission_status(timeline[index]))
              end

              terminal_indexes == [timeline.length - 1] &&
                submission_status(timeline.last) == 'completed'
            end
          end

          def valid_completed_submission_parameters(requests)
            valid_completed_submission_timelines(
              parsed_submission_parameters(requests)
            ).values.flatten
          end

          def validate_terminal_submission_order(requests)
            assert requests.present?, 'No $bulk-submit requests were received.'

            submission_timelines(parsed_submission_parameters(requests)).each_value do |timeline|
              terminal_index = timeline.index do |parameters|
                TERMINAL_SUBMISSION_STATUSES.include?(submission_status(parameters))
              end

              assert terminal_index.nil? || terminal_index == timeline.length - 1,
                     'No `$bulk-submit` request may follow a terminal submission status ' \
                     'for the same `submitter` and `submissionId`.'
            end
          end

          def submission_key(identity)
            Digest::SHA256.hexdigest(
              [identity[:submitter_system], identity[:submitter_value], identity[:submission_id]].to_json
            )
          end

          def complete_manifest(submission_id)
            {
              submissionId: submission_id,
              transactionTime: DateTime.now,
              requiresAccessToken: true
            }
          end

          def validate_submitter_identifiers(requests, operation_name)
            assert requests.present?, "No #{operation_name} requests were received."

            requests.each do |request|
              parameters = FHIR.from_contents(request.request_body)
              submitter_parameters = parameters.parameter.select do |parameter|
                parameter.name == 'submitter'
              end

              assert submitter_parameters.one?,
                     "Every #{operation_name} request must include exactly one `submitter` parameter."

              submitter_identifier = submitter_parameters.first.valueIdentifier
              assert submitter_identifier.present?,
                     'The `submitter` parameter must have type `Identifier`.'
              assert submitter_identifier.system.present?,
                     'The `submitter` Identifier must include a system.'
              assert submitter_identifier.value.present?,
                     'The `submitter` Identifier must include a value.'

              [submitter_identifier.system, submitter_identifier.value]
            end
          end

          def validate_status_submission_identities(status_requests, submit_requests)
            validate_submitter_identifiers(status_requests, '$bulk-submit-status')
            validate_submission_ids(status_requests, '$bulk-submit-status')
            validate_submitter_identifiers(submit_requests, '$bulk-submit')
            validate_submission_ids(submit_requests, '$bulk-submit')

            submitted_identities = submit_requests.map do |request|
              submission_identity(FHIR.from_contents(request.request_body))
            end
            status_identities = status_requests.map do |request|
              submission_identity(FHIR.from_contents(request.request_body))
            end

            assert status_identities.all? { |identity| submitted_identities.include?(identity) },
                   'Every `$bulk-submit-status` request must match the `submitter` and ' \
                   '`submissionId` of a `$bulk-submit` request.'
          end

          def validate_submission_ids(requests, operation_name)
            assert requests.present?, "No #{operation_name} requests were received."

            requests.each do |request|
              parameters = FHIR.from_contents(request.request_body)
              submission_id_parameters = parameters.parameter.select do |parameter|
                parameter.name == 'submissionId'
              end

              assert submission_id_parameters.one?,
                     "Every #{operation_name} request must include exactly one `submissionId` parameter."
              assert submission_id_parameters.first.valueString.present?,
                     'The `submissionId` parameter must have type `string` and contain a value.'
            end
          end

          def submission_status_parameters(request)
            FHIR.from_contents(request.request_body).parameter.select do |parameter|
              parameter.name == 'submissionStatus'
            end
          end

          def request_has_submission_status?(request, code)
            status_parameters = submission_status_parameters(request)
            return code == 'in-progress' if status_parameters.empty?
            return false unless status_parameters.one?

            coding = status_parameters.first.valueCoding
            coding.present? &&
              coding.system == Shared::SubmissionStatus::SYSTEM &&
              coding.code == code
          end

          def validate_submission_statuses(requests)
            assert requests.present?, 'No $bulk-submit requests were received.'

            requests.each do |request|
              status_parameters = submission_status_parameters(request)

              assert status_parameters.length <= 1,
                     'Every $bulk-submit request must include at most one `submissionStatus` parameter.'
              next if status_parameters.empty?

              coding = status_parameters.first.valueCoding
              assert coding.present?, '`submissionStatus` must have type `Coding`.'
              assert Shared::SubmissionStatus::CODES.include?(coding.code),
                     "#{coding.code} is not a valid submissionStatus code"
              assert coding.system == Shared::SubmissionStatus::SYSTEM,
                     "#{coding.system} is not the submissionStatus code system"
            end
          end

          def validate_optional_part_parameter(requests, parameter_name)
            parameters = requests.flat_map do |request|
              FHIR.from_contents(request.request_body).parameter
            end.select do |parameter|
              parameter.name == parameter_name
            end

            skip_if parameters.empty?,
                    "No submission included the optional `#{parameter_name}` parameter"

            all_parts = parameters.all? do |parameter|
              serialized = parameter.to_hash
              parameter.part.present? &&
                serialized.keys.none? { |key| key.start_with?('value') || key == 'resource' }
            end

            assert all_parts, "`#{parameter_name}` must have type `part`"
          end
        end
      end
    end
  end
end
