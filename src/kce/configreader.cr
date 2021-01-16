require "yaml"
require "./exceptions"

class KCE
  # Implements YAML parser for `KUBECONFIG`
  #
  # Usage example:
  #
  # ```
  # require "kce/configreader"
  #
  # # if path is omitted, KUBECONFIG env variable will be used
  # # if env variable is unset, it defaults to "~/.kube/config"
  # reader = KCE::ConfigReader.new
  # config = reader.config
  # pp! config
  #
  # # reading from alternative path
  # reader = KCE::ConfigReader.new("/path/to/kubeconfig")
  #
  # # getting config via class method
  # KCE::ConfigReader.config("/path/to/kubeconfig")
  # ```
  struct ConfigReader
    # Top-level `KUBECONFIG` object
    struct Kubeconfig
      include YAML::Serializable
      include YAML::Serializable::Unmapped

      # Used for parsing `.users` in `KUBECONFIG`
      struct User
        include YAML::Serializable

        # From `KUBECONFIG`: `.users[*].name`
        getter name : String

        # From `KUBECONFIG`: `.users[*].user`
        property user : Hash(String, String | Int32 | Bool | YAML::Any)
        # getter user : Hash(String, Hash(String,String|Hash(String,String)) | String )
      end

      # Used for parsing `.clusters` in `KUBECONFIG`
      struct Cluster
        include YAML::Serializable

        # From `KUBECONFIG`: `.clusters[*].name`
        getter name : String

        # From `KUBECONFIG`: `.clusters[*].cluster`
        property cluster : Hash(String, String | Int32 | Bool | YAML::Any)
      end

      # Used for parsing `.contexts` in `KUBECONFIG`
      struct Context
        include YAML::Serializable

        # From `KUBECONFIG`: `.contexts[*].name`
        getter name : String

        # From `KUBECONFIG`: `.contexts[*].context`
        property context : Hash(String, String | Int32 | Bool | YAML::Any)
      end

      @[YAML::Field(key: "apiVersion")]
      # From `KUBECONFIG`: `.apiVersion`
      getter api_version : String

      # From `KUBECONFIG`: `.kind`
      getter kind : String

      # From `KUBECONFIG`: `.preferences`
      property preferences : Hash(String, YAML::Any)?

      @[YAML::Field(key: "current-context")]
      # From `KUBECONFIG`: `.current-context`
      property current_context : String?

      # From `KUBECONFIG`: `.users`
      property users : Array(User)

      # From `KUBECONFIG`: `.clusters`
      property clusters : Array(Cluster)

      # From `KUBECONFIG`: `.contexts`
      property contexts : Array(Context)
    end

    # Target `KUBECONFIG` used for parsing
    getter file : String

    # Parsed `KUBECONFIG` object
    getter config : Kubeconfig

    def initialize(file : String | Nil = nil)
      file ||= ENV.fetch("KUBECONFIG", "#{ENV["HOME"]}/.kube/config")
      @file = file
      if File.readable?(file)
        @config = Kubeconfig.from_yaml(File.read(@file))
        unless @config.@yaml_unmapped.empty?
          STDERR.puts "WARNING: unmapped valued detected"
        end
      else
        raise KCE::NoFileAccessError.new("\"#{file}\" is not readable")
      end
    end

    # Returns config YAML parsed config object.
    #
    # When `file` is not passed, uses value of `KUBECONFIG`.
    # If `KUBECONFIG` is unset, defaults to `$HOME/.kube/config`
    #
    # Raises `KCE::NoFileAccessError` if file is not accessible
    def self.config(file : String | Nil = nil)
      self.new(file).config
    end
  end
end
