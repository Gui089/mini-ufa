# The paper, and where each idea lands in this repo

**Uber's Failover Architecture: Reconciling Reliability and Efficiency in Hyperscale Microservice Infrastructure** — Bansal et al., NSDI '26.

## In five points

1. **2× is expensive and rarely used.** Full-peak regional failovers took under 20 hours a year (0.23% of the time); fleet CPU utilization sat near 20%.
2. **Four failure classes** (Table 4): Always-On, Active-Migrate, Restore-Later, Terminate, each with its own failover behavior and RTO.
3. **Overcommit through extended resources** (§4.4): every host advertises a `stateless.cpu` pool for Always-On and an `overcommit.cpu` pool for preemptible work, so the scheduler keeps them apart.
4. **Only safe once dependencies fail open** (§3, §6): a critical service must not break when a non-critical one disappears. Validated by graduated blackholing drills (§5).
5. **An orchestrator drives the failover** (§4.1, Figures 5 and 6): detect peak mode, lock, evict, convert batch to burst, migrate make-before-break, restore, and fail back in reverse.

## Mapping

| Paper | Here | Phase |
|---|---|---|
| Two regions, batch clusters (§2, Fig. 1) | k3d nodes labelled `region=a`, `region=b`, `pool=batch` | 0 |
| 2× provisioning (§3, Problem 1) | Baseline sizing and utilization dashboard | 1 |
| Failure classes (Table 4) | `ufa.io/failure-class` label + PriorityClasses | 1–2 |
| `stateless.cpu` / `overcommit.cpu` (§4.4) | Extended resources `ufa.io/stateless-cpu`, `ufa.io/overcommit-cpu` | 2 |
| Fail-close dependencies (§3, Problem 2) | Fail-open calls in `trip-api`, a planted fail-close bug | 3 |
| Traffic isolation / blackholing (§4.2, §5) | NetworkPolicy drills driven by k6 | 3 |
| OMG failover orchestration (§4.1, Fig. 5) | `ufa-operator` reconciling a `Failover` resource | 4 |
| Make-before-break vs break-before-make (§4.3) | Active-Migrate vs Restore-Later handling | 4 |
| Peak detection, failback (§4.1, §4.7, Fig. 6) | Mode detection from Prometheus, reverse workflow | 5 |
| Cloud bursting (§4.6) | Operator adds a k3d node when batch is short | 6 |
| Quantitative impact (§8, Figs. 8–10) | 2× vs 1.3× report | 7 |
