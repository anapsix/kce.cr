require "option_parser"
require "./kce"

VERSION = {{ read_file("#{__DIR__}/../VERSION") }}

kubeconfig_default = "#{ENV["HOME"]}/.kube/config"
kubeconfig = ENV.fetch("KUBECONFIG", kubeconfig_default)
target_context = ""

parser = OptionParser.new do |op|
  op.banner = "Kubeconfig-context-extractor extracts sections of KUBECONFIG file based on selected context.\n" +
              "Usage: #{PROGRAM_NAME} [arguments]"
  op.on("-k PATH", "--kubeconfig=PATH", "Path to kubeconfig file, defaults to KUBECONFIG env value, if present, otherwise #{kubeconfig_default}") { |f| kubeconfig = f }
  op.on("-c NAME", "--context=NAME", "Context to extract config for") { |c| target_context = c }
  op.on("-h", "--help", "Show this help") { puts op; exit 0 }
  op.on("-v", "--version", "Display version") { puts "v#{VERSION}"; exit 0 }
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

if target_context.empty?
  STDERR.puts "ERROR: context must be passed, exiting.."
  STDERR.puts parser
  exit 1
end

begin
  kce = KCE.new(kubeconfig: kubeconfig, target_context: target_context)
  puts kce.config
rescue KCE::ContextMissingError
  STDERR.puts "\"#{target_context}\" context is not found in \"#{kubeconfig}\""
  exit 1
rescue ex
  STDERR.puts ex.message
  exit 1
end
