# Anonymized Incident Report: Next.js Container Compromise

Author: **Farzin Alavi**  
Repository: `nextjs-container-miner-incident`

## Status

This document is an anonymized case study. It does not claim a new vulnerability, zero-day, or exploit technique. It documents a real-world failure pattern involving a web container, an outdated framework stack, root runtime permissions, a writable filesystem, and weak deployment hardening.

## Executive summary

A production-like Docker deployment started showing abnormal CPU usage. The issue was traced to a web container running a Next.js application. After stopping the container, host load dropped immediately.

Forensic checks showed that new files had appeared inside the container after it started. The observed artifacts strongly indicated a runtime compromise and crypto-mining payload.

The most important lesson is not only “upgrade Next.js.” The deeper lesson is that framework version, container user, filesystem permissions, published ports, and deployment process are all part of the security boundary.

## Affected stack at the time of the incident

The affected web service was running a Next.js 15.1.x stack created during the initial monorepo scaffold.

### Exact framework versions observed

```text
next: 15.1.3
react: 19.0.0
react-dom: 19.0.0
@next/swc-linux-x64-gnu: 15.1.3
@next/swc-linux-x64-musl: 15.1.3
eslint-config-next: 15.1.3
```

### Patched versions used during remediation

```text
next: 15.5.19
react: 19.1.2
react-dom: 19.1.2
@next/swc-linux-x64-gnu: 15.5.19
@next/swc-linux-x64-musl: 15.5.19
eslint-config-next: 15.5.19
```

The original `next@15.1.3` dependency came from the initial scaffold and was carried forward through the lockfile. It was not introduced by the deployment platform. The deployment platform built and ran what the repository defined.

## Deployment technique that increased risk

The application was deployed as a Docker Compose-based monorepo stack through a deployment platform.

The relevant web service pattern was:

```text
monorepo source
→ Docker Compose build
→ Next.js standalone runtime image
→ web service running with: node apps/web/server.js
→ container process running as root
→ writable container filesystem
→ public web entrypoint behind a reverse proxy
```

The stack also contained non-web services such as API, worker, database, cache, object storage, PDF rendering, and analysis services. Those services should be internal-only in production. If published to the host or reachable from the public internet, they materially increase the blast radius.

The deployment technique itself was not “bad” by default. Docker Compose and deployment platforms are normal production tools. The unsafe part was the combination of:

- outdated framework versions;
- root container runtime;
- writable runtime filesystem;
- broad service exposure risk;
- no enforced framework CVE gate before deploy;
- no enforced container-hardening gate before deploy.

## Why the version mattered

The affected stack used `next@15.1.3`, which was below patched floors for major Next.js security advisories.

For CVE-2025-66478, the Next.js advisory states that affected App Router applications using React Server Components should upgrade to patched versions, including `15.1.9` for the 15.1 line and `15.5.7` for the 15.5 line.

For CVE-2025-29927, the Next.js middleware authorization bypass advisory lists `15.0 < 15.2.3` as affected and `15.2.3` as the patched version for the 15.x line.

This does not prove that the incident entered through a specific Next.js CVE. It does mean the web service was running below known patched security floors and had to be treated as exposed.

## Timeline pattern

The exact timestamps, infrastructure identifiers, and logs are intentionally omitted. The generalized pattern was:

1. Web container starts normally.
2. Application reports ready/healthy.
3. CPU usage rises sharply.
4. Suspicious process appears under a system-like name.
5. Filesystem diff shows post-startup files in OS-level paths.
6. Container stop immediately reduces load.
7. Suspicious binaries and persistence artifacts are preserved for offline inspection.
8. Framework and deployment hardening work begins.

## Key observations

The affected container showed indicators including:

```text
softirq
qkpucq
rondo
xmrig
randomx
stratum+ssl
```

The suspicious binary contained strings associated with XMRig and RandomX mining. A persistence-like artifact was also present inside the container.

The report intentionally omits real project names, domains, IP addresses, container IDs, pool endpoints, credentials, environment values, and full logs.

## Why this was not just a normal application bug

The application code did not contain an obvious direct shell execution primitive in the web service, such as:

```text
child_process.exec
eval
new Function
shell: true
```

That does not make the deployment safe. A deployment can still be vulnerable through framework vulnerabilities, unsafe runtime permissions, overly exposed internal services, weak secrets, or insecure container defaults.

## Container factor

The container process ran as root and the filesystem was writable. That made post-exploitation persistence easier. Once code execution happened inside the container, an attacker could write into OS-level paths such as:

```text
/usr/bin
/etc/cron.d
/etc/crontab
```

Running as non-root and using a read-only runtime filesystem would not eliminate every possible exploit, but it would materially reduce the attacker’s ability to persist inside the container.

## Deployment factor

The broader stack included services that should be internal-only in production, such as database, cache, object storage, rendering, and analysis services. Any public exposure of these services increases blast radius.

A safer production deployment would expose only the public web entrypoint and keep supporting services reachable only on private container networks unless there is a documented reason otherwise.

## Immediate response

The immediate defensive response was:

1. Stop the affected container.
2. Preserve evidence before deletion.
3. Capture container diff, logs, process list, and suspicious binaries.
4. Upgrade framework dependencies to patched versions.
5. Add a CI gate for minimum safe Next.js versions.
6. Rebuild from a clean image without Docker cache.
7. Rotate production secrets.
8. Verify that the new container no longer contains miner artifacts.
9. Plan follow-up hardening.

## Root cause assessment

This incident should be treated as a compromise chain, not a single isolated mistake.

Most likely contributing factors:

- `next@15.1.3` and `react@19.0.0` were carried from the initial scaffold into deployment;
- Docker Compose built and ran the web service exactly as defined by the repository;
- the web container ran as root;
- the runtime filesystem was writable;
- internal services had potential exposure risk;
- there was no framework CVE gate before deployment;
- there was no container-hardening gate before deployment;
- runtime monitoring detected the load only after CPU usage became abnormal.

## What changed after the incident

The framework stack was upgraded to:

```text
next: 15.5.19
react: 19.1.2
react-dom: 19.1.2
```

A CI gate was added to fail future builds if the web application falls below the patched Next.js floors for the relevant 15.x release lines.

The next hardening priorities are:

- non-root containers;
- read-only runtime filesystems where practical;
- removal of public host port mappings for internal services;
- authentication or network restrictions for rendering and analysis services;
- production secret rotation;
- image scanning;
- dependency scanning;
- runtime alerting for abnormal CPU and unexpected persistence artifacts.

## Final lesson

A successful build is not a security review.

A production deployment should enforce at least these gates:

- known CVE check;
- dependency audit;
- container image scan;
- non-root runtime check;
- public port exposure check;
- secret hygiene check;
- post-deploy runtime validation.
