CLUSTER  := mini-ufa
MON_NS   := monitoring

.PHONY: up down cluster monitoring dashboards sandbox load grafana status

up: cluster monitoring dashboards sandbox ## Cluster + monitoring + placeholder workload

cluster:
	k3d cluster create --config deploy/k3d/cluster.yaml --wait

monitoring:
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts >/dev/null
	helm repo update >/dev/null
	helm upgrade --install kps prometheus-community/kube-prometheus-stack \
	  --namespace $(MON_NS) --create-namespace -f deploy/monitoring/values.yaml --wait --timeout 10m

dashboards:
	kubectl -n $(MON_NS) create configmap mini-ufa-dashboards --from-file=dashboards/ \
	  --dry-run=client -o yaml | kubectl label --local -f - grafana_dashboard=1 -o yaml | kubectl apply -f -

sandbox:
	kubectl apply -f deploy/sandbox/echo.yaml
	kubectl -n sandbox rollout status deploy/echo --timeout=120s

load: ## 5 minutes of steady load with k6, inside the cluster
	kubectl -n sandbox create configmap k6-scripts --from-file=drills/k6/ --dry-run=client -o yaml | kubectl apply -f -
	kubectl -n sandbox delete job k6-smoke --ignore-not-found
	kubectl apply -f deploy/load/k6-job.yaml

grafana: ## http://localhost:3000 (admin / mini-ufa)
	kubectl -n $(MON_NS) port-forward svc/kps-grafana 3000:80

status:
	kubectl get nodes -L region,pool
	kubectl -n sandbox get pods -o wide

down:
	k3d cluster delete $(CLUSTER)
