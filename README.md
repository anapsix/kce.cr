# kubeconfig-parser

Kubeconfig-parser extracts sections of [KUBECONFIG][1] file based on selected context.

Since context includes cluster, and user name, extracting all relevant sections allows creating fully working KUBECONFIG for selected context.

## Build

### as Docker image
```bash
make docker
```

### as binary
```bash
make all
```

## Usage
```bash
Usage: ./releases/kcp [arguments]
    -k PATH, --kubeconfig=PATH       Path to kubeconfig file, defaults to KUBECONFIG env value, if present, otherwise /Users/adancha/.kube/config
    -c NAME, --context=NAME          Context to extract config for
    -h, --help                       Show this help
```

[ Link Reference ]::
[1]: https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/#define-clusters-users-and-contexts
