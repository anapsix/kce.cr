require "./kce/configreader"
require "./kce/exceptions"

# KUBECONFIG Content Extractor.
#
# KCE generates fully usable `KUBECONFIG` for `target_context`
#
# Usage example:
# ```
# require "kce"
#
# # using instance methods
# # if path is omitted, KUBECONFIG env variable will be used
# # if env variable is unset, it defaults to "~/.kube/config"
# kce = KCE.new("my-context", "/path/to/kubeconfig")
# puts kce.config      # => config as String (YAML)
# puts kce.config_obj  # => config as Object (from YAML)
#
# # using class methods
# KCE.config("my-context", "/path/to/kubeconfig")     # => config as String (YAML)
# KCE.config_obj("my-context", "/path/to/kubeconfig") # => config as Object (from YAML)
#
class KCE
  # :nodoc:
  VERSION = {{ read_file("#{__DIR__}/../VERSION") }}

  # Path to `KUBECONFIG`
  getter kubeconfig : String

  # Context to extract config for
  getter target_context : String

  def initialize(
    target_context : String,
    kubeconfig : String? = nil
  )
    @target_context = target_context.strip
    @kubeconfig = kubeconfig || ENV.fetch("KUBECONFIG", "#{ENV["HOME"]}/.kube/config")
    self.check_target_context(@target_context)
    self.check_kube_config(@kubeconfig)
  end

  # Checks if `kubeconfig` is readable
  #
  # Raises `KCE::NoFileAccessError` if `kubeconfig` is not readable
  private def check_kube_config(kubeconfig) : Nil
    unless File.readable?(kubeconfig)
      raise KCE::NoFileAccessError.new("\"#{kubeconfig}\" is not readable")
    end
  end

  # Check if `target_context` is not empty
  #
  # Raises `KCE::ContextEmptyError` if `target_context` is an empty String
  private def check_target_context(target_context) : Nil
    if target_context.strip.empty?
      raise KCE::ContextEmptyError.new("\"#{target_context}\" is an empty String")
    end
  end

  # Returns `KUBECONFIG` String YAML representation for `target_context`
  def config
    self.extract_context.to_yaml
  end

  # :ditto:
  def self.config(target_context : String, kubeconfig : String? = nil)
    self.new(target_context, kubeconfig).config
  end

  # Returns `KUBECONFIG` Object for `target_context`
  def config_obj
    self.extract_context
  end

  # :ditto:
  def self.config_obj(target_context : String, kubeconfig : String? = nil)
    self.new(target_context, kubeconfig).config_obj
  end

  # Returns `KUBECONFIG` object for selected context
  #
  # Raises `KCE::ContextMissingError`
  private def extract_context
    config = KCE::ConfigReader.new(@kubeconfig).config

    # find requested context
    contexts = config.contexts
    context = contexts.select { |c| c.name == @target_context }
    if (context.size != 1)
      raise KCE::ContextMissingError.new("could not find context by name: #{@target_context}")
    end

    # get cluster name from context
    cluster_name = context[0].context["cluster"].to_s
    # # find cluster for selected context
    clusters = config.clusters
    cluster = clusters.select { |c| c.name == cluster_name }

    # get username from context
    username = context[0].context["user"].to_s
    # find user for selected context
    users = config.users
    user = users.select { |c| c.name == username }

    # return config
    {
      "apiVersion":      config.api_version,
      "kind":            config.kind,
      "preferences":     config.preferences,
      "current-context": @target_context,
      "contexts":        context,
      "clusters":        cluster,
      "users":           user,
    }
  end
end
