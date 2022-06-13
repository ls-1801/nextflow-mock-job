NEXTFLOW = /home/ls/Uni/SoSe22/MSPDS/nextflow/launch.sh
HOSTDATA = /host-data
NEXTFLOW_POD_IMAGE = gcr.io/spark-on-kubernetes-316714/nextflow:perf

nextflow/clean:
	rm -rf nextflow/*
	mkdir nextflow/ls
	cp results/do_stuff.nf nextflow/
	cp results/nextflow.config nextflow/
	cp Cargo.toml nextflow/ls/

nextflow/kind:
	$(MAKE) -C kubernetes kind


nextflow/kuberun:
	$(NEXTFLOW) kuberun $(HOSTDATA)/do_stuff.nf \
				-pod-image $(NEXTFLOW_POD_IMAGE) \
				--file Cargo.toml \
				-remoteConfig $(HOSTDATA)/nextflow.config  \
				-v pvc-host-data:$(HOSTDATA) \
				-with-dag dag.mmd \
				-c nextflow/nextflow.config


nextflow/docker:
	$(NEXTFLOW) results/do_stuff.nf \
				--file Cargo.toml \
				-with-dag dag.mmd \
				-c results/nextflow.config \
				-with-trace trace.txt \
				-with-docker dostuff:latest
