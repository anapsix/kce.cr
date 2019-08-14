require "yaml"

class KCE

  getter kubeConfig : String
  getter targetContext : String

  def initialize(
      targetContext : String,
      @kubeConfig = ENV.fetch("KUBECONFIG", "#{ENV["HOME"]}/.kube/config")
    )
    @targetContext = targetContext.strip
    self.checkTargetContext(@targetContext)
    self.checkKubeConfig(@kubeConfig)
  end

  private def checkKubeConfig(kubeConfig)
    unless File.readable?(kubeConfig)
      raise "unable to read file: #{kubeConfig}"
    end
  end

  private def checkTargetContext(targetContext)
    if targetContext.strip.empty?
      raise "targetContext cannot be empty"
    end
  end

  def config
    self.extractContext.to_yaml
  end

  private def extractContext
    config = YAML.parse(File.read(@kubeConfig))

    ## find requested context
    contexts = config["contexts"].as_a
    context = contexts.select { |c| c["name"] == @targetContext }
    if (context.size != 1)
      raise "could not find context by name: #{@targetContext}"
    end

    ## get cluster name from context
    cluster_name = context[0]["context"]["cluster"].to_s
    ## find cluster for selected context
    clusters = config["clusters"].as_a
    cluster = clusters.select { |c| c["name"] == cluster_name }

    ## get username from context
    username = context[0]["context"]["user"].to_s
    ## find user for selected context
    users = config["users"].as_a
    user = users.select { |c| c["name"] == username }

    # return config
    config = {
      "kind": "Config",
      "apiVersion": "v1",
      "current-context": @targetContext,
      "clusters": cluster[0],
      "contexts": context[0],
      "users": user[0]
    }
  end

end
