# Mitigation Checklist

This checklist is for SaaS teams using Next.js, Docker, Docker Compose, and AI-assisted development.

## Immediate containment

- Stop the affected container.
- Preserve logs, process lists, and filesystem diff before deleting anything.
- Copy suspicious artifacts for offline review.
- Rebuild from clean source and clean image layers.
- Deploy with no build cache.
- Rotate production secrets.

## Framework and dependency security

- Upgrade Next.js above known patched floors.
- Upgrade React and React DOM to compatible patched versions.
- Add a CI gate for minimum framework versions.
- Run a production dependency audit before deployment.
- Track security advisories for framework and runtime dependencies.

## Container hardening

- Run application containers as non-root users.
- Use read-only runtime filesystems where practical.
- Remove unnecessary tools from runtime images where practical.
- Drop unnecessary Linux capabilities.
- Add CPU and memory limits.
- Avoid privileged application containers.
- Avoid mounting sensitive host paths into application containers.

## Network exposure

- Expose only the public web entrypoint.
- Keep API, worker, database, cache, object storage, PDF rendering, and analysis services internal-only unless there is a documented reason otherwise.
- Verify firewall rules and Docker published ports.
- Protect internal services with authentication or network-level restrictions.

## Secret hygiene

- Rotate application signing secrets.
- Rotate refresh-token secrets.
- Rotate database passwords.
- Rotate object storage credentials.
- Rotate deploy tokens and repository tokens.
- Remove default or demo credentials from production.
- Avoid storing secrets in image history.

## Application hardening

- Disable unauthenticated API documentation in production.
- Add allowlists to broad proxy routes.
- Validate URL schemes for redirects and links.
- Validate object storage keys against issued upload URLs.
- Restrict URL-fetching services to expected internal hosts.
- Authenticate rendering and analysis endpoints.

## Monitoring and detection

- Alert on abnormal CPU usage.
- Alert on unexpected persistence artifacts inside runtime containers.
- Alert on unknown miner-like process names.
- Track outbound connections to unapproved destinations.
- Run regular image scanning.
- Run regular dependency scanning.

## Process improvements

- Treat AI-generated code as untrusted until reviewed.
- Require a security review before production deployment.
- Require a container-hardening review before production deployment.
- Add a release checklist covering dependency versions, ports, secrets, and runtime users.
