# Installation and updates

Requires Ruby 3.3 or later. The official gem is
[`raims` on RubyGems](https://rubygems.org/gems/raims). Installation resolves
the gem's declared runtime dependencies. Load the SDK with `require 'raims'`.

## Install with RubyGems

Install the current stable version:

```sh
gem install raims
```

## Use Bundler

Add the gem to your application's `Gemfile`:

```ruby
source 'https://rubygems.org'

gem 'raims'
```

Run `bundle install` from the application directory. Keep the resulting
`Gemfile.lock` with your application to retain its resolved versions.

## GitHub release downloads

Use GitHub CLI to download the gem and its checksum file from the current
stable [GitHub release](https://github.com/raimshq/raims-ruby/releases/latest)
into a new directory:

```sh
gh release download --repo raimshq/raims-ruby --pattern raims.gem --pattern SHA256SUMS --dir raims-ruby-release
```

You can also download both assets from the releases page. The asset name
`raims.gem` stays the same between releases; the gem metadata identifies its
version.

## Verify the download

Check that the files came from `raimshq/raims-ruby` and review the release tag
and commit. On systems with `sha256sum`, verify the downloaded gem from the
asset directory:

```sh
cd raims-ruby-release
sha256sum --check SHA256SUMS
```

On macOS, use `shasum -a 256 -c SHA256SUMS` in the same directory.
In PowerShell, run this command from the directory containing
`raims-ruby-release` and compare its `Hash` with the `raims.gem` entry in
`SHA256SUMS`:

```powershell
Get-FileHash -Algorithm SHA256 -LiteralPath ./raims-ruby-release/raims.gem
```

Stop if the hashes differ. Checksums detect changed files; the official
repository, release tag, and commit establish which source you are installing.

## Install a GitHub download

Run this command from the directory containing `raims-ruby-release`:

```sh
gem install ./raims-ruby-release/raims.gem
```

RubyGems installs the local SDK artifact and resolves its declared dependencies
through your configured gem sources. Load the library with `require 'raims'`.
The gem contains the runtime library, public contract metadata, license, and
README.

## Use Bundler with release source

Download the current release's source archive:

```sh
gh release download --repo raimshq/raims-ruby --archive tar.gz --dir raims-ruby-source
```

Extract the archive. Add its directory, containing `raims.gemspec`, to your
application's Gemfile:

```ruby
gem 'raims', path: '/path/to/extracted/raims-ruby'
```

Run `bundle install` from the application directory. Bundler resolves the
dependencies declared in the gemspec and records them in your application's
lockfile.

## Update an existing installation

For an installation managed by RubyGems:

```sh
gem update raims
```

For a Bundler application:

```sh
bundle update raims
```

Review the release notes and test your integration before deployment. Keep
the updated lockfile with your application. Installing a release does not
apply future updates automatically.

For a GitHub installation, download the current stable release into a new
directory, verify its hash, and install the new `raims.gem` as above.

For a Bundler path installation, extract the new release source, update the
Gemfile path if needed, and run `bundle update raims`. Keep the resulting
lockfile with your application.

## Build from source

From a source checkout, choose an existing output directory:

```sh
gem build raims.gemspec --output /path/to/artifacts/raims.gem
gem install /path/to/artifacts/raims.gem
```

The gemspec supplies the package version and dependencies. Run your application's
integration checks against the rebuilt gem before deploying it.
