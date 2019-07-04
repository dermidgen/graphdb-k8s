# graphdb-k8s
Configuration tools &amp; examples for running GraphDB in Kubernetes

These examples show various ways of running GraphDB editions in a Kubernetes environment. This work focuses on Standard and Enterprise editions of GraphDB, but can be adapted for running the Free version as well. The examples here are targeting GKE, but with minor adjustments can be adapted for AKS, EKS or any other k8s environment.

## Docker Images
This repo follows the examples at [Docker images](https://github.com/Ontotext-AD/graphdb-docker) for building images. However, you don't need to build these - you can get pre-built images, with `docker pull ontotext/graphdb:8.10.1-ee`. You can find out more on [Docker Hub](https://hub.docker.com/r/ontotext/graphdb/). These tools can be adapted to build & push custom images to your own private repository.

## Cluster Considerations
These examples run in a standard node pool with limited resources.  However, it is recommended to create a node pool that has greater than standard resources. More performant nodes typically also come with higher I/O, memory & CPU.  A decent production node pool for GKE would be 4+ instance pool of `n1-highmem-8` nodes. Depending on your GraphDB license, pick nodes that offer enough CPUs and memory.


## Performance Options
In the deployment examples, you'll find comments that indicate some optional settings you may want to consider for improved performance. To allow using these examples with roughly any license, most of these options are commented out. Some of these options include:

 * SSD for faster I/O (enabled)
 * Node pool assignment with `nodeSelector` for aligning to nodes with more resources (disabled)
 * CPU requests to align with your license (set to 2)
 * Memory requests to align with available memory in the node pool (set at 3g)

## Deployments
The examples are focused on demonstrating runtime configuration of the various deployment models of GraphDB editions. For example, rather than committing your license file, as suggested in the documentation on [Docker Hub](https://hub.docker.com/r/ontotext/graphdb/), we will supply the license via k8s configuration mounted onto the pod.

### Standalone (GraphDB-SE)
Standard edition doesn't support clustering so we'll use that as the example for standalone operation.

```
kubectl apply -f ./deploy/standalone.yml
```

### Single-Master Cluster (GraphDB-EE)
Very basic, [single-master cluster mode](http://graphdb.ontotext.com/documentation/enterprise/ee/setting-up-a-cluster-with-one-master.html). This offers improved performance and availability.

```
kubectl apply -f ./deploy/single-master-cluster.yml
```

#### Worker Membership
Workers must be joined to the master node to form the cluster. This should be done from the command line on the master node. Get on the master node with `kubectl exec -it graphdb-0 -- bash`. From the master node run the following commands to join the workers and validate their status.

*Add worker 1:*
```bash
curl -H 'content-type: application/json' \
  -d "{\"type\":\"exec\",\"mbean\":\"ReplicationCluster:name=ClusterInfo\/example\",\"operation\":\"addClusterNode\",\"arguments\":[\"http://graphdb-1.graphdb-headless:7200/repositories/example\",0,true]}" \
  http://graphdb-0.graphdb-headless:7200/jolokia/
```

*Add worker 2:*
```bash
curl -H 'content-type: application/json' \
  -d "{\"type\":\"exec\",\"mbean\":\"ReplicationCluster:name=ClusterInfo\/example\",\"operation\":\"addClusterNode\",\"arguments\":[\"http://graphdb-2.graphdb-headless:7200/repositories/example\",0,true]}" \
  http://graphdb-0.graphdb-headless:7200/jolokia/
```

*Add worker 3:*
```bash
curl -H 'content-type: application/json' \
  -d "{\"type\":\"exec\",\"mbean\":\"ReplicationCluster:name=ClusterInfo\/example\",\"operation\":\"addClusterNode\",\"arguments\":[\"http://graphdb-3.graphdb-headless:7200/repositories/example\",0,true]}" \
  http://graphdb-0.graphdb-headless:7200/jolokia/
```

*Get worker status:*
```bash
curl -H 'content-type: application/json' \
  -d "{\"type\":\"read\",\"mbean\":\"ReplicationCluster:name=ClusterInfo\/example\",\"attribute\":\"NodeStatus\"}" \
  http://graphdb-0.graphdb-headless:7200/jolokia/
```

*Remove a worker:*
```bash
curl -H 'content-type: application/json' \
  -d "{\"type\":\"exec\",\"mbean\":\"ReplicationCluster:name=ClusterInfo\/example\",\"operation\":\"removeClusterNode\",\"arguments\":[\"http://graphdb-1.graphdb-headless:7200/repositories/example\"]}" \
  http://graphdb-0.graphdb-headless:7200/jolokia/
```
