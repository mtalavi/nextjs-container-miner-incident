# Deployment Context and Version Matrix

This document records the sanitized technical context of the incident.

## Important note

This is not a proof that one specific CVE was the only entry point. It is a record of the affected versions and the deployment conditions that made the incident more likely and made post-exploitation persistence easier.

## Affected framework versions

```text
next: 15.1.3
react: 19.0.0
react-dom: 19.0.0
@next/swc-linux-x64-gnu: 15.1.3
@next/swc-linux-x64-musl: 15.1.3
eslint-config-next: 15.1.3
```

## Remediated framework versions

```text
next: 15.5.19
react: 19.1.2
react-dom: 19.1.2
@next/swc-linux-x64-gnu: 15.5.19
@next/swc-linux-x64-musl: 15.5.19
eslint-config-next: 15.5.19
```

## Origin of the vulnerable version

The affected Next.js version came from the initial monorepo scaffold. It was pinned in the web package manifest and carried forward through the lockfile. The deployment platform did not choose this version; it built the application from the repository definition.

## Deployment technique

The affected service followed this pattern:

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

The service was containerized and run behind a reverse proxy. Supporting services existed in the same broader stack and should be treated as internal-only production services.

## Why this technique created risk

Docker Compose and deployment platforms are normal tools. The risk came from how the stack was configured:

- the framework version was below patched security floors;
- the container had no non-root runtime boundary;
- the container filesystem was writable;
- internal services had potential host exposure risk;
- there was no mandatory security gate before deployment;
- the first strong signal was runtime CPU usage rather than a pre-deploy block.

## Safer deployment pattern

A safer production pattern would be:

```text
patched framework versions
+ locked dependency audit
+ image scan
+ non-root runtime user
+ read-only runtime filesystem where practical
+ internal-only supporting services
+ CPU/memory limits
+ no-cache rebuild after compromise
+ post-deploy artifact check
```

## What should not be inferred

Do not infer that:

- Docker Compose itself caused the incident;
- the deployment platform itself caused the incident;
- Next.js was conclusively the only entry point;
- the host was necessarily compromised;
- every AI-assisted project is unsafe.

The correct conclusion is narrower: a vulnerable framework stack combined with weak container hardening created a realistic compromise path and made persistence inside the web container easier.
