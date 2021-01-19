require "option_parser"
require "./kce"

kubeconfig_default = "#{ENV["HOME"]}/.kube/config"
kubeconfig = ENV.fetch("KUBECONFIG", kubeconfig_default)
kubecontext = ""

parser = OptionParser.new do |op|
  op.banner = "Kubeconfig-context-extractor extracts sections of KUBECONFIG file based on selected context.\n" +
              "Usage: #{PROGRAM_NAME} [arguments]"
  op.on("-k PATH", "--kubeconfig=PATH", "Path to kubeconfig file, defaults to KUBECONFIG env value, if present, otherwise #{kubeconfig_default}") { |f| kubeconfig = f }
  op.on("-c NAME", "--context=NAME", "Context to extract config for") { |c| kubecontext = c }
  op.on("-h", "--help", "Show this help") { puts op; exit 0 }
  op.on("-v", "--version", "Display version") { puts "v#{KCE::VERSION}"; exit 0 }
  op.invalid_option do |opt|
    STDERR.puts "ERROR: '#{opt}' is not a valid option."
    STDERR.puts op
    exit 1
  end
  op.missing_option do |opt|
    STDERR.puts "ERROR: missing value for '#{opt}'"
    STDERR.puts op
    exit 1
  end
end
parser.parse(ARGV)

unless File.readable?(kubeconfig)
  STDERR.puts "ERROR: Unable to read KUBECONFIG: #{kubeconfig}, exiting.."
  exit 1
end

if kubecontext.empty?
  STDERR.puts "ERROR: context must be passed, exiting.."
  STDERR.puts parser
  exit 1
end

begin
  puts KCE.config(kubeconfig: kubeconfig, kubecontext: kubecontext).to_yaml
rescue KCE::Exceptions::ContextMissingError
  STDERR.puts "\"#{kubecontext}\" context is not found in \"#{kubeconfig}\""
  exit 1
rescue ex
  STDERR.puts ex.message
  exit 1
end
