# Sanitized Indicators

This document lists safe, anonymized indicators from the incident. Real infrastructure identifiers are intentionally omitted.

## Observed names

```text
softirq
qkpucq
rondo
xmrig
randomx
stratum+ssl
```

## Observed behavior pattern

- Abnormal CPU usage in a web container.
- Load dropped after the affected container was stopped.
- Runtime filesystem diff showed newly created files after container startup.
- Suspicious binary strings referenced XMRig and RandomX.
- A persistence-like artifact was present inside the container.

## Not published

The public report omits:

- server IP addresses;
- project names;
- container IDs;
- internal domains;
- full logs;
- environment variables;
- secrets;
- exact pool endpoints;
- private repository details.

## Safe detection themes

Defenders can watch for:

- sudden CPU spikes in web containers;
- unexpected binaries inside runtime containers;
- unexpected persistence artifacts;
- process names that mimic system components;
- outbound connections to unapproved destinations;
- containers running as root with writable runtime filesystems.
