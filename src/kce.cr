require "./kce/*"

# KUBECONFIG Content Extractor.
#
# KCE generates fully usable `KUBECONFIG` for `kubecontext`
#
# Usage examples:
# ```
# require "kce"
#
# # using KCE instance methods
# kce = KCE.new("my-context", "/path/to/kubeconfig")
# puts kce.kubeconfig     # => path to selected KUBECONFIG file
# puts kce.kubecontext    # => selected kubecontext ("my-context")
# puts kce.config         # => "my-context" config as Object (from YAML)
# puts kce.config.to_yaml # => "my-context" config as String (from YAML)
#
# # using KCE class methods
# config = KCE.config("my-context", "/path/to/kubeconfig")
# puts config         # => "my-context" config as Object (from YAML)
# puts config.to_yaml # => "my-context" config as String (from YAML)
#
# # using KCE::ConfigReader instance methods
# reader = KCE::ConfigReader.new("/path/to/kubeconfig")
# reader.config         # => original KUBECONFIG as Object (from YAML)
# reader.config.to_yaml # => original KUBECONFIG as String (from YAML)
#
# # using KCE::ConfigReader class methods
# kubeconfig = KCE::ConfigReader.config("/path/to/kubeconfig")
# ```
module KCE
  # :nodoc:
  VERSION = {{ read_file("#{__DIR__}/../VERSION") }}

  # :nodoc:
  KUBECONFIG = ENV.fetch("KUBECONFIG", "#{ENV["HOME"]}/.kube/config")

  # Returns `KUBECONFIG` object for selected context
  def self.config(kubecontext : String, kubeconfig : String? = nil)
    KCE::Extractor.config(kubecontext, kubeconfig)
  end

  # Returns `Extractor` object for selected context
  def self.new(kubecontext : String, kubeconfig : String? = nil)
    KCE::Extractor.new(kubecontext, kubeconfig)
  end
end
