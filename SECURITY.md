# Security Policy

## Reporting a vulnerability

Please do not disclose security or privacy vulnerabilities in a public issue. Contact the repository owner privately through the security-reporting channel listed on the repository hosting page. Include reproduction steps, affected versions or commits, and the likely impact. Do not include real API keys, personal media, or other sensitive data.

## Security boundary

Sketched is local-first and has no project backend, analytics, or telemetry. Its optional browser agent seat uses a key supplied by the user, retains that key in memory only, and sends a request only after explicit user action. Reports about key persistence, unintended network calls, human-layer mutation, consent bypass, provenance loss, or recording/upload behavior are treated as security issues.

Only the current default branch is supported. This project makes no commitment to a particular private response deadline, but good-faith reports will be acknowledged and assessed as promptly as maintainers can manage.
