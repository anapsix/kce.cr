# KCE.cr

[![GitHub release](https://img.shields.io/github/v/release/anapsix/kce.cr.svg)][2]

KCE (Kubeconfig Context Extractor) extracts sections of [KUBECONFIG][1] file based on selected context.

Since context includes cluster, and user name, extracting all relevant sections allows creating fully working KUBECONFIG for selected context.

Same functionality can be achieved with native kubectl command

```sh
kubectl --context=${context_name} config view --minify --flatten
```

## Install

Get latest release from [Releases][2] page.

## Usage

### CLI

```sh
Usage: kce [arguments]
    -k PATH, --kubeconfig=PATH       Path to kubeconfig file, defaults to KUBECONFIG env value,
                                     if present, otherwise ~/.kube/config
    -c NAME, --context=NAME          Context to extract config for
    -h, --help                       Show this help
    -v, --version                    Display version
```

### Library

Add `kce` to `shard.yml` dependencies
```yaml
dependencies:
  kce:
    github: anapsix/kce.cr
```

### KCE
```crystal
require "kce"

# using instance methods
# if path is omitted, KUBECONFIG env variable will be used
# if env variable is unset, it defaults to "~/.kube/config"
kce = KCE.new("my-context", "/path/to/kubeconfig")
puts kce.kubeconfig      # => path to KUBECOFIG file (String)
puts kce.target_context  # => name of context (String)
puts kce.config          # => config as YAML (String)"
puts kce.config_obj      # => config as Object (from YAML)

# using class methods
KCE.config("my-context", "/path/to/kubeconfig")     # => String (YAML)
KCE.config_obj("my-context", "/path/to/kubeconfig") # => Object (from YAML)
```

### KCE::ConfigReader
```crystal
require "kce/configreader"

# getting config via instance method
reader = KCE::ConfigReader.new # will use `KUBECONFIG` env variable if set
config = reader.config         # otherwise `$HOME/.kube/config`
pp! config  # => config Object (from YAML)

# reading from alternative path
reader = KCE::ConfigReader.new("/path/to/kubeconfig")

# getting config via class method
KCE::ConfigReader.config("/path/to/kubeconfig")
```

## Build

```sh
# local build
shards build --release

# build Docker image, and release binaries (results will vary depending on your )
make all
```


[ Link Reference ]::
[1]: https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/#define-clusters-users-and-contexts
[2]: https://github.com/anapsix/kce.cr/releases
