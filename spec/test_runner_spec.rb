require_relative 'spec_helper'

describe TestRunner do
  let(:runner) { TestRunner.new({'swipl_path' => 'swipl'}) }
  let(:file) { OpenStruct.new(path: '/tmp/foo.pl') }

  describe '#run_test_command' do
    it { expect(runner.run_test_command(file.path)).to include('swipl -f /tmp/foo.pl --quiet -t run_tests') }
    it { expect(runner.run_test_command(file.path)).to include('2>&1') }
  end

  describe '#validate_compile_errors' do
    let(:results) { runner.post_process_file(file, *original_results) }

    describe 'fails on test errors' do
      let(:original_results) { ['Test failed', :failed] }
      it { expect(results).to eq(["```\nTest failed\n```", :failed]) }
    end

    describe 'fails on compile errors ' do
      let(:original_results) { ['ERROR: /tmp/foo.pl:3:0: Syntax error: Operator expected', :passed] }
      it { expect(results).to eq(["```\nERROR: /tmp/foo.pl:3:0: Syntax error: Operator expected\n```", :failed]) }
    end

    describe 'passes otherwise' do
      let(:original_results) { ['....', :passed] }
      it { expect(results).to eq(["```\n....\n```", :passed]) }
    end
  end

end
