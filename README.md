# DevOps Playground

A small Python web app taken through the full DevOps toolchain on one laptop:
Docker, an nginx reverse proxy, Blue/Green, Canary, Rolling and Recreate deployments,
Prometheus + Grafana + Loki + Alertmanager monitoring, GitHub Actions CI with image scanning and publishing,
a Jenkins pipeline, Kubernetes (minikube) with Helm and Argo CD, Terraform (Docker + AWS), Ansible, HTTPS and Vault.

## Quick start
    ./scripts/setup.sh                 # app v1 on BLUE + proxy on http://localhost:8080
    ./scripts/deploy-idle.sh v2        # start v2 on the idle slot (GREEN)
    ./scripts/switch.sh green          # flip live traffic to v2
    ./scripts/rollback.sh              # flip back instantly

## Monitoring
    cd monitoring && docker compose up -d
    # Grafana http://localhost:3000 (admin / devops123) · Prometheus http://localhost:9090

## Layout
    app/         Flask app, tests, Dockerfile
    proxy/       nginx reverse proxy that decides which slot gets traffic
    scripts/     deployment strategies (blue/green, canary, recreate, rollback)
    monitoring/  Prometheus, Grafana, Loki, Alloy
    k8s/         Kubernetes manifests: rolling, blue/green, canary
    jenkins/     Jenkins image with the Docker CLI
    Jenkinsfile  CI/CD pipeline with a manual approval before switching traffic
    terraform/   Infrastructure as Code: local Docker (free) and AWS EC2
    ansible/     Configuration management lab: 2 servers managed over SSH with a role
    proxy-tls/   HTTPS front door with a TLS certificate
    helm/        The app packaged as a Helm chart
    k8s/argocd/  GitOps: Argo CD keeps the cluster in sync with Git
    vault/       Secrets management with HashiCorp Vault (dev mode)
    .github/workflows/release.yml  Builds, scans (Trivy) and pushes the image to ghcr.io
