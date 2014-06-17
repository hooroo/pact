require 'pact/tasks/verification_task'
require 'open3'

Pact::VerificationTask.new(:stubbing) do | pact |
	pact.uri './spec/support/stubbing.json', :pact_helper => './spec/support/stubbing_using_allow.rb'
end

Pact::VerificationTask.new(:pass) do | pact |
	pact.uri './spec/support/test_app_pass.json'
end

Pact::VerificationTask.new(:fail) do | pact |
	pact.uri './spec/support/test_app_pass.json'
	pact.uri './spec/support/test_app_fail.json'
end

Pact::VerificationTask.new(:term) do | pact |
	pact.uri './spec/support/term.json'
end

RSpec::Core::RakeTask.new('spec:standalone:fail') do | task |
	task.pattern = FileList["spec/standalone/**/*_fail_test.rb"]
end

RSpec::Core::RakeTask.new('spec:standalone:pass') do | task |
	task.pattern = FileList["spec/standalone/**/*_pass_test.rb"]
end

Pact::VerificationTask.new('test_app:pass') do | pact |
	pact.uri './spec/support/test_app_pass.json'
end

Pact::VerificationTask.new('test_app:fail') do | pact |
	pact.uri './spec/support/test_app_fail.json', pact_helper: './spec/support/pact_helper.rb'
end

task :bethtest => ['pact:tests:all','pact:tests:all:with_active_support']

namespace :pact do

	desc "All the verification tests"
	task "tests:all" do
		Rake::Task['pact:verify:stubbing'].execute
		Rake::Task['spec:standalone:pass'].execute
		Rake::Task['pact:verify'].execute
		Rake::Task['pact:verify:test_app:pass'].execute
		Rake::Task['pact:test:fail'].execute
	end

	desc "All the verification tests with active support loaded"
	task 'tests:all:with_active_support' => :set_active_support_on do
		Rake::Task['pact:tests:all'].execute
	end

	desc "Ensure pact file is written"
	task 'test:pactfile' do
		pact_path = './spec/pacts/standalone_consumer-standalone_provider.json'
		FileUtils.rm_rf pact_path
		Rake::Task['spec:standalone:pass'].execute
		fail "Did not find expected pact file at #{pact_path}" unless File.exist?(pact_path)
	end

	desc 'Runs pact tests against a sample application, testing failure and success.'
	task 'test:fail' do

		require 'open3'

		silent = true
		# Run these specs silently, otherwise expected failures will be written to stdout and look like unexpected failures.
		#Pact.configuration.output_stream = StringIO.new if silent

		expect_to_fail "bundle exec rake pact:verify:test_app:fail", with: [/Could not find one or more provider states/]
		expect_to_fail "bundle exec rake spec:standalone:fail", with: [/Actual interactions do not match expected interactions/]
		expect_to_fail "bundle exec rake pact:verify:term", with: [%r{"Content-type" with value /text/}]
	end

	def expect_to_fail command, options = {}
		success = execute_command command, options
		fail "Expected '#{command}' to fail" if success
	end

	def execute_command command, options
		result = nil
		Open3.popen3(command) {|stdin, stdout, stderr, wait_thr|
		  result = wait_thr.value
		  ensure_patterns_present(command, options, stdout, stderr) if options[:with]
		}
		result.success?
	end

	def ensure_patterns_present command, options, stdout, stderr
		require 'term/ansicolor'
		output = stdout.read + stderr.read
		options[:with].each do | pattern |
			raise (::Term::ANSIColor.red("Could not find #{pattern.inspect} in output of #{command}") + "\n\n#{output}") unless output =~ pattern
		end
	end

end