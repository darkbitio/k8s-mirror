# K8s-mirror

## Why?

To enable high-fidelity, offline review of Kubernetes clusters as a part of Darkbit's cloud and Kubernetes security [consulting services offerings](https://darkbit.io/services/), a simple script to export all K8s resources from a cluster was developed.  A modified version of this script is included in this repository as `kube-exporter.sh`.

The original goal of this export format was to support ingestion by the [OpenCSPM](https://github.com/opencspm/opencspm) analysis platform.  However, there are instances where analysis is best performed with a quick run of `kubectl`.  Without having direct access to a client's cluster, a "mirror" cluster is needed.

## How?

* Clone the repository
* Run `kube-exporter.sh` against the target cluster.  It's output file should be named `<kubecontext_name>.json`.
* Copy `<kubecontext_name>.json` to `data/import.json`
* Modify the `Dockerfile` to use the correct `K8S_VERSION`
* Run `make build` to build the docker container.
* Run `make run` to launch the "mirror" cluster container.  This container runs etcd, loads the data from `/data/import.json` into etcd, and then launches an _insecure_ API server.  That is, it runs without TLS, listens on `localhost:31337` and requires a simple token for authentication as `cluster-admin`.
* Run `export KUBECONFIG=kubeconfig.honk`
* Run `kubectl get pods -A` to query for pods in the "mirror" cluster container.
* When done, kill the container to clean up.

## Warning!

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
