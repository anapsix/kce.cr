require "yaml"
require "option_parser"

VERSION="0.3.0"

kubeconfig_default = "#{ENV["HOME"]}/.kube/config"
kubeconfig = ENV.fetch("KUBECONFIG", kubeconfig_default)

target_context = nil

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

# unless File.exists?(kubeconfig)
#   puts "Unable to read file: #{kubeconfig}, exiting.."
#   exit 1
# end

if (target_context == nil)
  STDERR.puts "ERROR: context must be passed, exiting.."
  STDERR.puts parser
  exit 1
end

config = {
  "kind": "Config",
  "apiVersion": "v1",
  "current-context": target_context,
  "clusters": [] of YAML::Any,
  "contexts": [] of YAML::Any,
  "users": [] of YAML::Any,
}

data = YAML.parse(File.read(kubeconfig))

## find requested context
contexts = data["contexts"].as_a
context = contexts.select { |c| c["name"] == target_context }
if (context.size != 1)
  STDERR.puts "ERROR: could not find context by name: #{target_context}, exiting.."
  STDERR.puts parser
  exit 1
end


## get cluster name from context
cluster_name = context[0]["context"]["cluster"].to_s

## get username from context
username = context[0]["context"]["user"].to_s

## add selected context to new YAML
config["contexts"].push(context[0])

## find cluster for selected context
clusters = data["clusters"].as_a
cluster = clusters.select { |c| c["name"] == cluster_name }

## add selected cluster to YAML
config["clusters"].push(cluster[0])

## find user for selected context
users = data["users"].as_a
user = users.select { |c| c["name"] == username }

## add selected user to YAML
config["users"].push(user[0])

## output compiles config
puts config.to_yaml
