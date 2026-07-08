# Changelog

All notable changes to this project are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-07-08

### Added

- Terraform root module that installs Istio (`base`, `istiod`, ingress
  `gateway`) via the Helm provider onto an existing cluster.
- `istio-addons` sub-module installing Prometheus, Grafana, Jaeger, and Kiali
  with per-addon toggles.
- Per-environment example tfvars and partial backend configs for `dev` and
  `prod`, sharing one mesh across separate networks.
- Helm value overrides for `base`, `istiod` (multi-cluster `meshConfig`), and
  the ingress gateway.
- Multi-cluster manifests: east-west gateway, cross-network gateway Service, and
  service exposure resources, plus remote-secret documentation.
- Observability: mesh-wide `Telemetry` CR and addon value files.
- Documentation: architecture, multi-cluster, and install guides.
- Open-source hygiene: LICENSE (MIT), CONTRIBUTING, SECURITY, CODE_OF_CONDUCT,
  CI workflow, pre-commit hooks, issue/PR templates, CODEOWNERS, and dependabot.
