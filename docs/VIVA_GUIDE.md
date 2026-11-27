# TaskFlow viva guide

Short answers to the questions a reviewer is most likely to ask about this capstone, plus a
demonstration order that fits into about ten minutes.

## A. One-line summary

> TaskFlow is a Flask and PostgreSQL task manager whose whole path to production is automated:
> pytest gates the build, Jenkins produces one immutable commit-tagged image, Argo CD deploys the
> manifests from Git, and Prometheus, Grafana and the ELK stack observe the result.

## B. Questions and answers

**1. Why is the image tagged with the commit SHA?**
Because a tag must identify an artefact, not a moment in time. `0.1.0` says which release line is
running; `git rev-parse --short HEAD` says exactly which source produced it, which is what the
blue-green comparison and the rollback depend on.

**2. Why does the pipeline not deploy to Kubernetes itself?**
That would require cluster credentials inside Jenkins. Instead the pipeline commits the new tag to
`kubernetes/deployment.yaml`; Argo CD, which already lives next to the cluster, reconciles it. This is
the GitOps split: CI builds, CD reconciles.

**3. Why are liveness and readiness separate endpoints?**
Liveness answers "is this process healthy enough to keep". Readiness answers "should this pod receive
traffic". During a database outage the correct action is to remove the pod from the Service, not to
restart it repeatedly, so readiness checks PostgreSQL and liveness never does.

**4. What happens if two replicas start at the same time?**
`Database.initialize()` takes a transaction-scoped advisory lock on `hashtextextended('taskflow:' ||
current_schema())`. One replica applies the migrations and commits its ledger rows; the other waits,
then sees the ledger complete and inserts nothing.

**5. How do you know migrations are safe to re-run?**
`schema_migrations` stores the applied filename, and each migration and its ledger row commit in the
same transaction. A failure rolls both back, so a retry re-applies cleanly. The concurrent-start test
asserts this behaviour.

**6. Where are the secrets?**
Nowhere in Git. `.env` is generated locally and ignored; Kubernetes reads `taskflow-db-secret`, which
is created once by hand with `kubectl create secret`; Jenkins injects the Docker Hub and GitHub
credentials through `withCredentials` at run time.

**7. Why is the container non-root and read-only?**
A read-only root filesystem turns accidental writes into visible errors, and it removes a common
post-exploitation step. The application only needs `/tmp`, so that path is a memory-backed
`emptyDir`/tmpfs. Capabilities are dropped and privilege escalation is disabled.

**8. Why one Gunicorn worker per pod?**
`prometheus_client` keeps its registry in process memory. One worker keeps the metric labels
meaningful and `taskflow_database_available` accurate. The scaling axis here is the number of pods,
not threads inside a pod; a multi-worker setup would need the multiprocess collector.

**9. How is the dashboard protected against injected task content?**
Task text is rendered with `textContent`, never `innerHTML`, all API responses send
`Content-Security-Policy: default-src 'none'` with self-only sources, and mutations that arrive with a
foreign `Origin` or a cross-site `Sec-Fetch-Site` are rejected with 403.

**10. What does Trivy actually enforce?**
Nothing yet — it runs with `--exit-code 0` and archives the report. That is a deliberate, stated
limitation: findings are visible, but the pipeline is not a vulnerability gate. The next step is to
fail on CRITICAL once the base image is clean.

**11. How would you roll back?**
Blue-green: revert the Service selector commit and let Argo CD sync. Normal release: `git revert` the
`GitOps:` commit that changed the image tag. Either way the cluster converges to a state that already
existed, so no rebuild is required.

**12. Is this production ready?**
No, and the report says so. Single Minikube node, one database pod, PVC reuse rather than a restore
drill, batch log forwarding instead of a collector, and no authentication. Those are listed as future
work, not hidden.

**13. What would you change first if this had to run for real users?**
Move PostgreSQL to a managed service with automated backups, add a staging overlay so the same
manifests deploy twice, replace the log snapshot with a Fluent Bit DaemonSet, and add OIDC
authentication.

**14. Why is `prune: false` set in Argo CD?**
So that removing a file from Git never deletes a running workload by accident during a demonstration.
The trade-off is that orphaned resources survive; that is an accepted risk for a lab.

**15. Which parts are Terraform and which are Ansible, and why both?**
Terraform owns the lifecycle of the cluster object itself (create, replace, destroy). Ansible owns
in-cluster configuration that is naturally task-shaped: wait for nodes, apply namespaces, quotas and
limit ranges, and report changes. Splitting them keeps each tool doing what it is good at.

## C. Ten-minute demonstration order

1. `docker compose ps` — application and database healthy (E02/E04).
2. Open `localhost:8090` — five tasks, live counts, filters (E22).
3. `bash scripts/test.sh` — the isolated suite passes (E03).
4. Show `Jenkinsfile` and the last successful build in Jenkins (E09/E10).
5. `kubectl -n taskflow-prod get pods,svc,pvc` — two replicas, one database, one PVC (E11/E12).
6. Argo CD — **Synced / Healthy** on `main:kubernetes` (E16).
7. Prometheus **Targets** and one Grafana panel (E05/E17).
8. Kibana Discover on `taskflow-logs-*` (E18).
9. Blue-green: `curl /api/version` before and after the selector commit (E19).
10. Close with the limitations table and the future work in section 13 of the report.

## D. If something is not running

| Symptom | Check |
| --- | --- |
| Port-forward stops after a rollout | Restart the `kubectl port-forward` command |
| Application returns 503 on `/health/ready` | `kubectl -n taskflow-prod get pods` and the database logs |
| Prometheus target down | `minikube -p taskflow-capstone ip` still matches `monitoring/prometheus.yml` |
| Jenkins cannot push | `github-credentials` ID and repository write access |
| Argo CD shows OutOfSync | Compare `git log` with the synced revision; refresh, then sync |
| Old data missing | The PVC was replaced; do not reset passwords, restore the volume first |
