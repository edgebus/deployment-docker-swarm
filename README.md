# Deployment Docker Swarm

## Get Started

## Fetch Repositories
```shell
mkdir ~/deployment-docker-swarm
cd    ~/deployment-docker-swarm
git init
git remote add github git@github.com:edgebus/deployment-docker-swarm.git
git fetch --all --prune

git checkout workspace

git worktree add ~/deployment-docker-swarm/traefik-deployment        traefik#1-setup-deployment-local
git worktree add ~/deployment-docker-swarm/portainer-deployment      portainer#3-deployment-for-portainer
git worktree add ~/deployment-docker-swarm/prometheus-deployment     prometheus#5-deployment-for-prometheus
git worktree add ~/deployment-docker-swarm/grafana-deployment        grafana#7-deployment-for-grafana

code deployment-docker-swarm.code-workspace
```