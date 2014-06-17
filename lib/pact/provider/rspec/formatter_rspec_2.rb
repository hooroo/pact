require 'pact/provider/print_missing_provider_states'
require 'rspec/core/formatters/documentation_formatter'
require 'term/ansicolor'

module Pact
  module Provider
    module RSpec
      class Formatter2 < ::RSpec::Core::Formatters::DocumentationFormatter

        C = ::Term::ANSIColor

        def dump_commands_to_rerun_failed_examples
          return if failed_examples.empty?

          print_rerun_commands
          print_failure_message
          print_missing_provider_states

        end

        private

        def print_rerun_commands
          output.puts("\n")
          interaction_rerun_commands.each do | message |
            output.puts(message)
          end
        end

        def print_missing_provider_states
          PrintMissingProviderStates.call Pact.provider_world.provider_states.missing_provider_states, output
        end

        def interaction_rerun_commands
          failed_examples.collect do |example|
            interaction_rerun_command_for example
          end.uniq
        end

        def interaction_rerun_command_for example
          provider_state = example.metadata[:pact_interaction].provider_state
          description = example.metadata[:pact_interaction].description
          pactfile_uri = example.metadata[:pactfile_uri]
          example_description = example.metadata[:pact_interaction_example_description]
          C.red("rake pact:verify:at[#{pactfile_uri}] PACT_DESCRIPTION=\"#{description}\" PACT_PROVIDER_STATE=\"#{provider_state}\"") + " " + C.blue("# #{example_description}")
        end

        def print_failure_message
          output.puts failure_message
        end

        def failure_message
          "\n" +  C.underline(C.yellow("For assistance debugging failures, please note:")) + "\n\n" +
          "The pact files have been stored locally in the following temp directory:\n #{Pact.configuration.tmp_dir}\n\n" +
          "The requests and responses are logged in the following log file:\n #{Pact.configuration.log_path}\n\n"
        end

      end

    end

  end
end


