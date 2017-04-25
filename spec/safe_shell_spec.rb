require 'spec_helper'

local_pathdir = File.dirname(__FILE__)

RSpec.describe SafeShell do
  it 'has a version number' do
    expect(SafeShell::VERSION).not_to be nil
  end

  describe '#context' do
    it 'create context' do
      ctx = SafeShell.make_context({ :VAR1 => '1', :VAR2 => '2' },
                                   '/usr/lib/script.sh')

      expect(ctx).to eq(:constants => {:VAR1=>"1", :VAR2=>"2"},
                        :libraries => ['/usr/lib/script.sh'])
    end

    it 'create context with a list of libs' do
      ctx = SafeShell.make_context({ :VAR1 => '1', :VAR2 => '2' },
                                    ['/usr/lib/script.sh', '/usr/lib/script2.sh'])

      expect(ctx).to eq(:constants => {:VAR1=>"1", :VAR2=>"2"},
                        :libraries => ['/usr/lib/script.sh', '/usr/lib/script2.sh'])
    end
  end

  describe "#Mock" do
    it 'should get the right predefined mock' do
      expect(SafeShell::Mock::ECHO_PIPE).to eq('read a; echo $a;')
      expect(SafeShell::Mock::NOOP).to eq(': ;')
    end

    it 'should make the right Mock with empty body' do
      expect(SafeShell::Mock.make('beautiful_fun')).to eq('beautiful_fun () { echo $@ ; }')
    end

    it 'should make the right Mock with a defined body' do
      expect(SafeShell::Mock.make('beautiful_fun', 'echo "hello" ;'))
        .to eq('beautiful_fun () { echo "hello" ; }')
    end
  end

  describe "#safe run" do
    it 'should run a command and return the output' do
      expect(SafeShell.safe_run(['echo hello'])).to eq('hello')
    end

    it 'should raise an error when the commands failed' do
      expect { SafeShell.safe_run(['sddsf hello']) }
        .to raise_error(/command not found/)
    end

    it 'should run a list of commands' do
      expect(SafeShell.safe_run(['VAR="coucou"', 'echo $VAR'])).to eq('coucou')
    end
  end

  describe '#run test' do
    let(:ctx) { SafeShell.make_context({}, File.join(local_pathdir, 'assets/script1.sh')) }
    let(:ctx_var) { SafeShell.make_context({ :MESSAGE => 'message' }, File.join(local_pathdir, 'assets/script1.sh')) }

    it 'source a script and run commands' do
      expect(SafeShell.run_test(ctx, 'say_hello')).to eql('hello')
    end

    it 'source a script and run command on predefined variable' do
      expect(SafeShell.run_test(ctx_var, 'print_message_content')).to eql('message')
    end

    it 'source a script and run command with mocks' do
      expect(SafeShell.run_test(ctx,
                                'get_web_page',
                                [SafeShell::Mock.make('curl')]
                               )).to eql('-XGET http://www.google.com')
    end
  end
end
