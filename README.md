# kubeconfig-context-extractor

Kubeconfig-context-extractor extracts sections of [KUBECONFIG][1] file based on selected context.

Since context includes cluster, and user name, extracting all relevant sections allows creating fully working KUBECONFIG for selected context.


## Usage

```bash
Usage: kce [arguments]
    -k PATH, --kubeconfig=PATH       Path to kubeconfig file, defaults to KUBECONFIG env value, if present, otherwise /Users/adancha/.kube/config
    -c NAME, --context=NAME          Context to extract config for
    -h, --help                       Show this help
    -v, --version                    Display version
```

## Install

Get latest release from [Releases][2] page.


## Build

```bash
make all
```


[ Link Reference ]::
[1]: https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/#define-clusters-users-and-contexts
[2]: https://github.com/anapsix/kubeconfig-context-extractor/releases
