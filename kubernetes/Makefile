kind:
	kind delete clusters nextflow-cluster
	kind create cluster --config kind-config.yaml
	kubectl create -f pv.yaml -f rbac.yaml