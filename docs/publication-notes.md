# Safe Publication Notes

This repository is intended to inform defenders without exposing private systems or operational details.

## Positioning

Use this wording:

> This is an anonymized real-world incident report. It is not a claim of a new CVE, zero-day, or exploit technique.

Avoid this wording:

> We discovered a new vulnerability.

## Do publish

- General failure chain.
- Sanitized indicators.
- Defensive forensic workflow.
- Hardening checklist.
- Framework and container security lessons.
- References to public advisories and official documentation.

## Do not publish

- Real domains.
- Real IP addresses.
- Container IDs.
- Project names from private systems.
- Secret values.
- Environment values.
- Full logs.
- Screenshots with infrastructure details.
- Exact pool endpoints.
- Private repository paths.

## Suggested title

```text
A Real-World Next.js Container Compromise: How a Crypto Miner Landed in a Production Web Container
```

## Suggested short description

```text
An anonymized case study documenting how outdated framework versions, root containers, writable filesystems, and weak deployment hardening can turn a normal web container into a crypto-mining incident.
```

## Publishing sequence

1. Publish this repository as the canonical source.
2. Publish a shortened article on Dev.to or Hashnode with a canonical link back to this repository.
3. Publish a short professional summary on LinkedIn.
4. Only share to Hacker News or Reddit after the write-up is concise, non-promotional, and technically precise.
