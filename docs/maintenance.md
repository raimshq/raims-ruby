# Contract and maintenance

## Contract source

`contracts/source.json` identifies the published public contract revision,
SHA-256, and source URL. `contracts/openapi.json` preserves those exact bytes.
The generator is offline and verifies the checksum before reading the spec.
`contracts/service-map.json` maps every operation exactly once.

Generate with Python 3.8 or later:

```sh
python scripts/generate.py
python scripts/generate.py --check
```

Generated outputs include services, response models, enum constants, runtime
HTTP metadata, and the English method reference. Keep reference translations
in `docs/reference.en.json`. Generation rejects missing wording instead of
changing the pinned source or omitting descriptions. Review all generated
changes when updating the contract.

The SDK uses the published contract and does not change the Public API or
other consumers. No CLI contract regeneration is required solely to add this
library. New public API behavior must follow the workspace's consumer impact
procedure before it is consumed here.

`contracts/ruby-api.json` is the independent baseline for public class names,
inheritance, method signatures, constant values, and runtime dependency
requirements. Generation does not update it. Constructor signatures and
inherited SDK methods are included. Run
`ruby scripts/check-compatibility.rb` to reject incompatible changes.
New symbols are permitted. Accept an intentional baseline update only after
review, with `ruby scripts/check-compatibility.rb --write`.

## Local validation

```sh
python scripts/check.py
```

This launcher calls the canonical Ruby adapter in the sibling Developer
Toolkit checkout. The adapter checks generation, public compatibility,
operation coverage, transport, pagination, errors, webhooks, dependency
advisories, and a built gem installed outside the checkout. The consumer resolves
dependencies from the built gem's declared requirements and uses its own gem
directory plus the reviewed Ruby runtime. Prepared source-validation libraries
are not added to its load path. The gate checks the resolved dependency graph
and rejects missing or weakened declarations against the reviewed baseline.
It uses isolated Ruby runtimes, fake transport, and loopback receivers. It never
calls the financial API. Missing tools or incomplete checks are failures.

Tests, simulators, tools, reports, and build artifacts belong exclusively in
`C:\server\raims\.tmp\raims-ruby-sdk`. Do not put test files, generated
evidence, caches, secrets, or validation dependencies in this checkout or gem.
Stop temporary processes after validation and preserve existing user processes.

Before a delivery commit, use the workspace preflight's Commit stage for
`Raims-Ruby`. Before an authorized publication, use Deploy for the same
reviewed sources. Preserve complete SAST and dependency auditing. Freeze
the SDK and Toolkit inputs during a gate; edits invalidate affected evidence.

## Distribution

The gemspec explicitly includes only library files, public runtime metadata,
the README, and the license. Build the gem outside the checkout and verify a
clean installation with only its declared dependencies. Consumers need Ruby
and the gem, without Python or the engineering Toolkit.

The initial distribution publishes source code and `raims.gem` through
[GitHub releases](https://github.com/raimshq/raims-ruby/releases/latest), with
`SHA256SUMS` for the packaged gem. It does not publish the SDK on RubyGems.
Build the release asset from the reviewed source and verify the downloaded
artifact and a clean consumer installation after publication.

The repository has no executable workflow. The CI recipe remains a template
until runner access and activation are authorized. Further releases, RubyGems
publication, public guide publication, and workflow activation require their
own authorization. Successful local checks alone do not publish an update.
