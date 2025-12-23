# Platform Starter Kit — Roadmap

This roadmap defines the high-level phases for building a realistic, IaC-driven,
multi-environment platform inspired by modern DevOps best practices and
Kief Morris’ *Infrastructure as Code* principles.

The roadmap is intentionally stable.  
Individual tasks live in `docs/tasks/` and evolve incrementally.

---

## Workload Ownership

Workloads are treated as **external consumers of the platform**. The platform repository may include disposable smoke-test fixtures, but real workload codebases live in separate repositories and are integrated via GitOps.

---

## Phase 0 — Foundation & Repo Baseline

- Finalize initial repo layout.
- Add minimal documentation (architecture, delivery pipeline).
- Prepare local tooling: kind, kubectl, helm.
- Validate Terraform directory structure and globals.

---

## Phase 1 — Local Kubernetes Platform (kind)

- Create kind cluster configuration.
- Install ArgoCD locally.
- Install Observability stack locally (Prometheus, Grafana).
- Ensure GitOps manifests for **platform services and disposable test workloads** work locally before touching AWS.
- Establish a fast inner dev loop.

---

## Phase 2 — Terraform Foundations (Zero-Cost)

- Define strict Terraform repository structure and root/module contracts
- Establish deterministic local workflows (`fmt`, `validate`, `plan`, `test`) with guardrails
- Introduce IaC testing using `terraform test` with mocks (no cloud providers)
- Add baseline static checks and CI enforcement for Terraform code
- Ensure all Phase 2 code is fully executable and testable locally, with no cloud dependencies

---

## Phase 3 — Core Infra Modules (VPC / IAM / EKS)

- Implement VPC module (minimal, cost-conscious).
- Implement IAM module (cluster, node groups, optional admin roles).
- Implement EKS module (cluster + one managed node group).
- Stitch modules together in `accounts/dev` and validate end-to-end.
- Confirm kubectl connectivity to EKS.

---

## Phase 4 — GitOps Bootstrap (ArgoCD via Terraform)

- Implement ArgoCD bootstrap module (Helm or manifests).
- Configure the kubernetes provider inside Terraform.
- Install ArgoCD automatically during infra apply.
- Point ArgoCD App-of-Apps to `gitops/apps/root`.

---

## Phase 5 — GitOps Tree + Demo Application

- Define App-of-Apps structure.
- Add platform apps (Prometheus, Grafana, Loki).
- Integrate an **external demo workload repository** via ArgoCD (Helm or Kustomize), exercising image delivery and GitOps promotion flows.
- Verify automatic sync in dev environment.

---

## Phase 6 — CI/CD Automation (GitHub Actions)

- Terraform pipelines for dev/prod.
- Build & push demo-api container images.
- GitOps-based image tag bump workflow.
- Manual promotion flow for prod.

---

## Phase 7 — Hardening, Cost Controls, Refinements

- Add basic network policies.
- Add resource limits + HPA.
- Introduce spot node groups (optional).
- Add TTL tags for easy cleanup.
- Improve ops notes and runbooks.

---

## Phase 8 — Optional Extensions

- Add external-dns + cert-manager.
- Add Loki + Tempo for full observability.
- Add example app #2.
- Introduce SSO / OIDC integration.

---

Roadmap Reviewed: *2025-12-23*  
