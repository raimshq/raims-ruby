# Raims Ruby SDK

Read README, CONTRIBUTING, and docs/maintenance.md before changing this SDK.

- Write repository descriptions and Markdown documentation in English.
- Keep internal TODO lists, backlogs, and roadmaps outside this public repository
  and its packages. Use the private workspace tracker without publishing its
  contents, location, or links.
- Ruby 3.3 or later; gem `raims`, namespace `Raims`, client `RaimsClient`.
- Use only the public contract pinned in contracts, with its revision and
  SHA-256 verified. Do not import private contracts or host implementation code.
- Generate services, models, enum values, HTTP metadata, and docs/reference.md
  with scripts/generate.py. Do not edit those outputs manually.
- Preserve JSON names, integer cents, Unix seconds, omission, null, unknown
  response fields, and pending results. Never generate idempotency keys or retry
  writes automatically. Configurable retries apply only to reads.
- The API key determines company and environment. Do not offer environment
  selection, OAuth, or arbitrary headers. Preserve TLS verification; do not
  follow redirects, upload files, or download external URLs.
- Default representations and diagnostics must not expose credentials,
  resource IDs, query strings, or payloads.
- Tests, simulators, tooling dependencies, builds, and evidence belong only in
  C:\server\raims\.tmp\raims-ruby-sdk. Do not include them in Git or packages.
- Check offline generation, all operations and success variants, transport,
  pagination, webhooks, compatibility, and gem installation without calling the
  real API. Stop temporary processes before finishing.
- scripts/check.py calls the canonical Developer Toolkit validator. Preserve
  security and dependency checks before a release.
- Leave changes uncommitted and unstaged. Creating a remote, pushing, releasing,
  publishing on RubyGems, and publishing guides require separate authorization.
- Keep CI as a template until runner access and activation are authorized.
- Describe Raims features directly. Preserve required licenses and attribution
  and apply the workspace humanizer skill to text intended for people.
