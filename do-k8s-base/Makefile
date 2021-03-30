.PHONY: default
default:
	@echo "no target specified - exiting"
	@exit

.PHONY: linkerd-ca
linkerd-ca: linkerd-ca/ca.crt linkerd-ca/issuer.crt linkerd-ca/exp.tmp

linkerd-ca/ca.crt:
	@step certificate create identity.linkerd.cluster.local linkerd-ca/ca.crt linkerd-ca/ca.key --profile root-ca --no-password --insecure --san identity.linkerd.cluster.local

linkerd-ca/issuer.crt:
	@step certificate create identity.linkerd.cluster.local linkerd-ca/issuer.crt linkerd-ca/issuer.key --ca linkerd-ca/ca.crt --ca-key linkerd-ca/ca.key --profile intermediate-ca --not-after 8760h --no-password --insecure --san identity.linkerd.cluster.local

linkerd-ca/exp.tmp:
	date -d '+8760 hour' +"%Y-%m-%dT%H:%M:%SZ"  | tr -d '\n' > linkerd-ca/exp.tmp