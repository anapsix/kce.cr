module KCE
  # ```
  # require "kce"
  #
  # # using instance methods
  # # if path is omitted, KUBECONFIG env variable will be used
  # # if env variable is unset, it defaults to "~/.kube/config"
  # kce = KCE::Extractor.new("my-context", "/path/to/kubeconfig")
  # puts kce.config         # => config as Object (from YAML)
  # puts kce.config.to_yaml # => config as String (from YAML)
  #
  # # using class methods
  # kubeconfig = KCE::Extractor.config("my-context", "/path/to/kubeconfig")
  # ```
  class Extractor
    # Path to `KUBECONFIG`
    getter kubeconfig : String

    # Context to extract config for
    getter kubecontext : String

    def initialize(
      kubecontext : String,
      kubeconfig : String? = nil
    )
      @kubecontext = kubecontext.strip
      kubeconfig ||= KCE::KUBECONFIG
      @kubeconfig = kubeconfig
      self.check_kubecontext(@kubecontext)
      self.check_kube_config(@kubeconfig)
    end

    # Checks if `kubeconfig` is readable
    #
    # Raises `KCE::Exceptions::NoFileAccessError` if `kubeconfig` is not readable
    private def check_kube_config(kubeconfig) : Nil
      unless File.readable?(kubeconfig)
        raise KCE::Exceptions::NoFileAccessError.new("\"#{kubeconfig}\" is not readable")
      end
    end

    # Check if `kubecontext` is not empty
    #
    # Raises `KCE::Exceptions::ContextEmptyError` if `kubecontext` is an empty String
    private def check_kubecontext(kubecontext) : Nil
      if kubecontext.strip.empty?
        raise KCE::Exceptions::ContextEmptyError.new("\"#{kubecontext}\" is an empty String")
      end
    end

    # Returns `KUBECONFIG` Object for `kubecontext`
    def config
      self.extract_context
    end

    # :ditto:
    def self.config(kubecontext : String, kubeconfig : String? = nil)
      self.new(kubecontext, kubeconfig).config
    end

    # Returns `KUBECONFIG` object for selected context
    #
    # Raises `KCE::Exceptions::ContextMissingError`
    private def extract_context
      config = KCE::ConfigReader.new(@kubeconfig).config

      # find requested context
      contexts = config.contexts.select { |c| c.name == @kubecontext }
      if (contexts.size != 1)
        raise KCE::Exceptions::ContextMissingError.new("could not find context by name: #{@kubecontext}")
      end

      # get cluster name from context
      cluster_name = contexts[0].context.cluster.to_s
      # # find cluster for selected context
      clusters = config.clusters.select { |c| c.name == cluster_name }

      # get username from context
      username = contexts[0].context.user.to_s
      # find user for selected context
      users = config.users.select { |c| c.name == username }

      # update config object
      config.current_context = @kubecontext
      config.contexts = contexts
      config.clusters = clusters
      config.users = users

      # return config
      config
    end
  end
end
