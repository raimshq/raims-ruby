# Contributing

Read [AGENTS.md](AGENTS.md) and [maintenance](docs/maintenance.md) before
changing this SDK. Keep public documentation and repository descriptions
in English.

Use the pinned public contract. Do not import private API code, edit generated
outputs, change public field names, or add a parallel HTTP client. Financial
amounts use integer cents and API resource dates use Unix seconds. Preserve
omission, null, pending results, and unknown future fields.

Run `python scripts/generate.py --check` and `python scripts/check.py` from
the SDK checkout. The latter requires the engineering workspace's Developer
Toolkit and runs isolated tests without the real API. Tests, simulators,
validation dependencies, builds, and evidence belong outside this repository
in the workspace's temporary directory. Do not include them in the gem.

Review every changed and new file, `git diff --check`, `git diff`, and
`git diff --cached`. Leave work uncommitted and unstaged until a commit is
requested. Keep credentials, customer data, operational plans, TODO lists,
backlogs, and roadmaps out of the public repository and distribution.

Publishing source, tags, releases, executable workflows, guides, or the gem
requires separate authorization. Local validation does not publish the SDK.
Report security problems privately as described in [SECURITY.md](SECURITY.md).
