# A Real-World Next.js Container Compromise

**How a crypto miner landed in a production web container — and what small SaaS teams should fix before it happens to them.**

Author: **Farzin Alavi**  
GitHub: **[@mtalavi](https://github.com/mtalavi)**

> This repository is an anonymized incident report and hardening guide. It does **not** disclose a new CVE, a zero-day, private infrastructure details, secrets, domains, IP addresses, or exploitable proof-of-concept code.

## Summary

A Docker-based SaaS deployment showed abnormal CPU usage. The host and deployment platform initially looked healthy, but investigation isolated the load to a single web container.

After stopping the affected container, the load dropped immediately. A filesystem diff showed new files created after container startup, including miner-like binaries and persistence artifacts.

The incident pattern was not one isolated mistake. It was a chain:

```text
outdated framework
+ root container
+ writable filesystem
+ weak deployment hardening
= easy post-exploitation persistence
```

## Exact affected versions

The affected web service used this framework stack at the time of the incident:

```text
next: 15.1.3
react: 19.0.0
react-dom: 19.0.0
@next/swc-linux-x64-gnu: 15.1.3
@next/swc-linux-x64-musl: 15.1.3
eslint-config-next: 15.1.3
```

It was remediated to:

```text
next: 15.5.19
react: 19.1.2
react-dom: 19.1.2
@next/swc-linux-x64-gnu: 15.5.19
@next/swc-linux-x64-musl: 15.5.19
eslint-config-next: 15.5.19
```

The vulnerable version came from the initial monorepo scaffold and was carried forward through the lockfile. The deployment platform did not choose the vulnerable version; it built and ran what the repository defined.

## Deployment technique

The affected deployment pattern was:

```text
AI-assisted monorepo scaffold
→ npm lockfile pins framework versions
→ Docker Compose stack builds service images
→ deployment platform runs the Compose-defined services
→ web service runs Next.js standalone server
→ container runs as root with a writable filesystem
```

The relevant web runtime pattern was:

```text
node apps/web/server.js
```

Docker Compose and deployment platforms are normal tools. The risk came from the combination of outdated framework versions, root runtime, writable filesystem, broad internal-service exposure risk, and missing pre-deploy security gates.

## Why this matters

Many teams now build and ship quickly with AI coding tools, Docker Compose, monorepos, and platforms like Coolify. Speed is useful, but a functional build is not the same as a production-hardened deployment.

This incident shows how a stack can pass build, lint, health checks, and deployment — while still having enough runtime risk for a container compromise.

## What was observed

Inside the affected container, forensic checks found indicators such as:

```text
softirq
qkpucq
rondo
xmrig
randomx
stratum+ssl
```

The exact server IPs, project names, container names, internal domains, secrets, pool endpoints, credentials, and full logs are intentionally omitted.

## Likely contributing factors

The analysis focused on these risk factors:

- outdated Next.js / React Server Components stack;
- container process running as root;
- writable runtime filesystem;
- internal services that would be dangerous if exposed publicly;
- no mandatory dependency/CVE gate before deployment;
- no container hardening gate before deployment.

The application code did not contain an obvious direct shell execution primitive in the web service, such as `child_process.exec`, `eval`, or `shell: true`. That does **not** prove the application was safe. Framework versions, container runtime permissions, and deployment topology are also part of the attack surface.

## Immediate remediation pattern

The high-level response was:

1. Stop the affected container.
2. Preserve evidence using container logs, process lists, and filesystem diff.
3. Copy suspicious files out for offline inspection.
4. Upgrade framework dependencies to patched versions.
5. Add a CI security gate for vulnerable framework versions.
6. Rebuild the web image without Docker cache.
7. Redeploy from a clean image.
8. Verify that miner artifacts no longer exist in running containers.
9. Plan follow-up hardening for non-root containers, internal ports, and secret rotation.

## Repository contents

```text
docs/
  incident-report.md        Full anonymized write-up
  deployment-context.md     Exact sanitized versions and deployment technique
  mitigation-checklist.md   Practical hardening checklist
  indicators.md             Safe, sanitized indicators
  publication-notes.md      What was intentionally omitted
examples/
  forensic-commands.sh      Defensive evidence-collection commands
  post-deploy-check.sh      Defensive post-redeploy validation commands
  nextjs-security-check.mjs Example version gate script
SECURITY.md                 Disclosure and safety policy
DISCLAIMER.md               Scope and limitations
```

## References

- Next.js security advisory for CVE-2025-66478: https://nextjs.org/blog/CVE-2025-66478
- GitHub advisory for CVE-2025-29927: https://github.com/vercel/next.js/security/advisories/GHSA-f82v-jwr5-mffw
- Docker Engine security documentation: https://docs.docker.com/engine/security/
- Docker Compose build documentation: https://docs.docker.com/reference/cli/docker/compose/build/
- XMRig command-line options: https://xmrig.com/docs/miner/command-line-options

## License

MIT License. See [LICENSE](LICENSE).
