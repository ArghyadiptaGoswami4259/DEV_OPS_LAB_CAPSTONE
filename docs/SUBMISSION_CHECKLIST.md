# TaskFlow submission checklist

**Student:** Arghyadipta Goswami · **Roll:** 2301010192 · **Section:** C
**Subject:** DevOps and Automation · **Topic:** Capstone Project · **Year:** 2023–2027

## Prepared in this repository

- [x] One complete [capstone PDF](Capstone_Report.pdf) with the problem statement, design,
      implementation, verification results, screenshots and conclusions.
- [x] 36 screenshots and charts (E01–E36), indexed in the [evidence gallery](EVIDENCE.md) and the
      [CSV index](evidence-index.csv): 21 terminal and configuration captures, 3 charts computed
      from this repository, 5 diagrams and the application dashboard.
- [x] Updated repository [README](../README.md) and [Markdown report](../REPORT.md).
- [x] [Execution runbook](RUNBOOK.md) covering startup, infrastructure, CI/CD, monitoring and
      troubleshooting.
- [x] [Viva guide](VIVA_GUIDE.md) with short answers, practice questions and a demonstration order.
- [x] Captions distinguish real command output, configuration, diagrams and stated limitations.

## Final actions by the student

- [ ] Commit and push this repository to
      <https://github.com/ArghyadiptaGoswami4259/DEV_OPS_LAB_CAPSTONE>.
- [ ] Open the report and evidence links from the repository README after pushing.
- [ ] Upload `docs/Capstone_Report.pdf` in the capstone PDF field on the college portal.
- [ ] Submit `https://github.com/ArghyadiptaGoswami4259/DEV_OPS_LAB_CAPSTONE` in the GitHub field.
- [ ] Check that both submission fields show the expected result.
- [ ] Before the viva, start the local services and port-forwards using the runbook.
- [ ] Optional: replace or extend the hosted-dashboard screenshots with your own captures from
      Jenkins, Argo CD, Grafana and Kibana, following Appendix B of the report.

## Evidence coverage

| Requirement | Evidence |
| --- | --- |
| Working application, containerisation and tests | E01–E04, E07–E08, E22, E24, E27, E35 |
| Observability of the application itself | E05–E06, E17–E18, E25–E26, E30 |
| Jenkins pipeline and security scanning | E09–E10, E21 |
| Kubernetes configuration, Services and persistent storage | E11–E13, E32, E34 |
| Terraform and Ansible infrastructure automation | E14–E15 |
| Argo CD and GitOps delivery | E16 |
| Blue-green release strategy | E19, E36 |
| Design and request flow | E20, E33 |
| Repository and evidence metrics | E28–E29, E31 |
| Verification | E23 |

The repository contains synthetic sample data in `migrations/seed_demo.sql`. A sample task named
**Test database restore** is application data; it is not evidence that a restore was executed.

## Scope to explain accurately

The results establish a working local teaching platform. Trivy reports findings without blocking the
pipeline, and Bandit uses severity and confidence filters. Recovery evidence covers pod recreation
against the existing database volume and a Service traffic rollback; an independent backup restore,
continuous log collection, production high availability and measured zero downtime are not claimed.
