# frozen_string_literal: true

module BulkDataTestKit
  module BulkDataV400
    module Submit
      module Consumer
        class ProcessingWaitGroup < Inferno::TestGroup
          include URLs

          title 'Wait For Processing'

          description %(
            This group pauses after Inferno sends the terminal `completed`
            submission so the tester can allow the Data Consumer to finish
            processing before Inferno begins final status polling.
          )

          id :bulk_data_v400_submit_consumer_processing_wait

          run_as_group

          input :consumer_client_id,
                title: 'Data Consumer Client ID',
                optional: true,
                description: <<~DESCRIPTION
                  Client ID of the Bulk Submit Data Consumer system under test.
                  If no value is provided, the Inferno session id will be used.
                DESCRIPTION

          test do
            title 'Wait For Data Consumer Processing'

            run do
              identifier = consumer_client_id.presence || test_session_id

              wait(
                identifier:,
                message: %(
                  Inferno has sent the terminal `completed` submission. When the
                  Data Consumer under test has finished processing and its final
                  status poll is ready to return `200`,
                  [click here](#{resume_pass_url}?id=#{identifier}).
                ),
                timeout: 900
              )
            end
          end
        end
      end
    end
  end
end
