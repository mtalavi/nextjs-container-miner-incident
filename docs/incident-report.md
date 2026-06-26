# Anonymized Incident Report: Next.js Container Compromise

Author: **Farzin Alavi**  
Repository: `nextjs-container-miner-incident`

## Status

This document is an anonymized case study. It does not claim a new vulnerability, zero-day, or exploit technique. It documents a real-world failure pattern involving a web container, an outdated framework stack, root runtime permissions, and weak deployment hardening.

## Executive summary

A production-like Docker deployment started showing abnormal CPU usage. The issue was traced to a web container running a Next.js application. After stopping the container, host load dropped immediately.

Forensic checks showed that new files had appeared inside the container after it started. The observed artifacts strongly indicated a runtime compromise and crypto-mining payload.

## Timeline pattern

The exact timestamps, infrastructure identifiers, and logs are intentionally omitted. The generalized pattern was:

1. Web container starts normally.
2. Application reports ready/healthy.
3. CPU usage rises sharply.
4. Suspicious process appears under a system-like name.
5. Filesystem diff shows post-startup files in OS-level paths.
6. Container stop immediately reduces load.
7. Suspicious binaries and cron artifacts are preserved for offline inspection.
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

The suspicious binary contained strings associated with XMRig and RandomX mining. A cron-like persistence artifact was also present inside the container.

## Why this was not just a normal application bug

The application code did not contain an obvious direct shell execution primitive in the web service, such as:

```text
child_process.exec
eval
new Function
shell: true
```

That does not make the deployment safe. A deployment can still be vulnerable through framework vulnerabilities, unsafe runtime permissions, overly exposed internal services, weak secrets, or insecure container defaults.

## Framework factor

The application had originally been scaffolded with an outdated Next.js 15.1.x stack. That version line was below patched floors for important Next.js and React Server Components vulnerabilities.

The remediation path upgraded to a patched Next.js and React stack and added a CI gate to fail future builds if a vulnerable framework version is used.

## Container factor

The container process ran as root and the filesystem was writable. That made post-exploitation persistence easier. Once an attacker gained code execution inside the container, they could write into locations such as:

```text
/usr/bin
/etc/cron.d
/etc/crontab
```

Running as non-root and using a read-only runtime filesystem would not eliminate every possible exploit, but it would materially reduce the attacker’s ability to persist inside the container.

## Deployment factor

The broader stack included services that should be internal-only in production, such as database, cache, object storage, rendering, and analysis services. Any public exposure of these services increases blast radius.

## Immediate response

The immediate defensive response was:

1. Stop the affected container.
2. Preserve evidence before deletion.
3. Capture container diff, logs, process list, and suspicious binaries.
4. Rebuild from a clean image without cache.
5. Upgrade framework dependencies to patched versions.
6. Rotate production secrets.
7. Verify that the new container no longer contains miner artifacts.
8. Plan follow-up hardening.

## Root cause assessment

This incident should be treated as a compromise chain, not a single isolated mistake.

Most likely contributing factors:

- outdated framework version;
- root container runtime;
- writable filesystem;
- missing security gate before deployment;
- insufficient runtime monitoring;
- possible overexposure of internal services.

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
