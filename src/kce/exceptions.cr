class KCE
  # Raised when requested context is missing from selected `KUBECONFIG`.
  class ContextMissingError < Exception
    def initialize(message = "requested context is missing")
      super(message)
    end
  end

  # Raised when context is empty.String
  class ContextEmptyError < Exception
    def initialize(message = "requested context is missing")
      super(message)
    end
  end

  # Raised when requested file is not readable.
  class NoFileAccessError < Exception
    def initialize(message = "file is not readable")
      super("#{message}: doesn't exist or permissions issue")
    end
  end
end
