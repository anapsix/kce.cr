# KCE.cr

[![GitHub release](https://img.shields.io/github/v/release/anapsix/kce.cr.svg)](https://github.com/anapsix/kce.cr/releases)
[![Docs](https://img.shields.io/badge/docs-available-brightgreen.svg)](https://anapsix.github.io/kce.cr/api/latest)

KCE (Kubeconfig Context Extractor) extracts sections of [KUBECONFIG](https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/#define-clusters-users-and-contexts) file based on selected context.

Since context includes cluster, and user name, extracting all relevant sections allows creating fully working KUBECONFIG for selected context.

Same functionality can be achieved with native kubectl command

```sh
kubectl --context=${context_name} config view --minify --flatten
```

## Install

Get latest release from [Releases](https://github.com/anapsix/kce.cr/releases) page.

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

kce = KCE.new("my-context", "/path/to/kubeconfig")
puts kce.kubeconfig     # => path to selected KUBECONFIG file
puts kce.kubecontext    # => selected kubecontext ("my-context")
puts kce.config         # => "my-context" config as Object (from YAML)
puts kce.config.to_yaml # => "my-context" config as String (from YAML)

config = KCE.config("my-context", "/path/to/kubeconfig")
puts config         # => "my-context" config as Object (from YAML)
puts config.to_yaml # => "my-context" config as String (from YAML)
```

### KCE::ConfigReader
```crystal
require "kce/configreader"

# getting config via instance method
reader = KCE::ConfigReader.new # will use `KUBECONFIG` env variable if set
kubeconfig = reader.config     # otherwise `$HOME/.kube/config`
puts kubeconfig                # => original KUBECONFIG as Object (from YAML)
puts kubeconfig.to_yaml        # => original KUBECONFIG as String (from YAML)

# reading from alternative path
reader = KCE::ConfigReader.new("/path/to/kubeconfig")

# getting config via class method
kubeconfig = KCE::ConfigReader.config("/path/to/kubeconfig")
```

## Build

```sh
# local build
shards build --release

# build Docker image, and release binaries (results will vary depending on your OS/ARCH)
make all
```

## Generate and Publish Docs

> make sure to tag and push changes and tags before generating docs

```sh
# assuming latest tag is 0.6.1
ghshard docs:publish
ghshard docs:redirect 0.6 0.6.1
ghshard docs:redirect latest 0.6.1
```
