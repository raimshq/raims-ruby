# Security

Report vulnerabilities privately to `security@raims.com`. Include the SDK
version, scenario, impact, and a minimal reproduction using fictitious data.
Do not open public issues containing credentials, personal data, or access to
account resources.

Use the SDK on the server. API keys, webhook secrets, temporary URLs, and
financial data need your application's access and logging controls. Keep TLS
verification enabled and dependencies updated through trusted sources.

Use the [current stable GitHub release](https://github.com/raimshq/raims-ruby/releases/latest)
and review its notes before updating. Download from the official repository
and verify `raims.gem` against the release's `SHA256SUMS` before installation.
The SDK is not yet distributed through RubyGems.
