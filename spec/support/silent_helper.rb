module SilentHelper
  def self.before_execution
    @original_stderr = $stderr
    @original_stdout = $stdout
    $stderr = File.open(File::NULL, 'w')
    $stdout = File.open(File::NULL, 'w')
  end

  def self.after_execution
    $stderr = @original_stderr
    $stdout = @original_stdout
    @original_stderr = nil
    @original_stdout = nil
  end
end

RSpec.configure do |config|
  config.around(:all, :silent) do |all|
    SilentHelper.before_execution
    all.run
    SilentHelper.after_execution
  end
end
