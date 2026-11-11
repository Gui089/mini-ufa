# Phase 0 — Environment

**Delivers:** a 6-node k3d cluster (two nodes per region, two batch nodes), kube-prometheus-stack, a placeholder workload spread across both regions, k6 load inside the cluster, and a Grafana dashboard of CPU by region and pool.

**Done when:** the "mini-UFA · Capacidade" dashboard shows CPU per region and per pool under `make load`.

## Decisions

<!-- Write these in your own words. Prompts: -->
- Why one cluster with node labels instead of two clusters for two regions?
- Why does Prometheus/Grafana run on the batch pool?
- What does "requested CPU ÷ allocatable" show that "used CPU" does not, and why is it the number the paper attacks?

## What I learned

<!-- Prompts: -->
- How `kube_node_labels` joins with container metrics (`on(node) group_left`)
- What broke while setting this up, and why (hint: the Docker subnet)

## Next

Phase 1 replaces the placeholder with the four NestJS services and sizes them for the 2× baseline.
