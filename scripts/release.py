"""Verify canonical gem bytes and publish stable releases through RubyGems."""
import argparse
import hashlib
import io
import json
import os
from pathlib import Path
import re
import stat
import subprocess
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
import zipfile

sys.dont_write_bytecode = True
REPOSITORY = 'raimshq/raims-ruby'
WORKFLOW = '.github/workflows/validate.yml'
JOBS = {'validateRuby': ('ruby-sdk-check', 'Run the canonical Ruby SDK checks'),
        'securityLinux': ('ruby-sdk-security', 'Run the canonical SDK security checks')}
RUBY_VERSIONS = {'3.3': '3.3.13', '4.0': '4.0.9'}
SHA = re.compile(r'[a-f0-9]{40}')
VERSION = re.compile(r'(?:0|[1-9]\d*)\.(?:0|[1-9]\d*)\.(?:0|[1-9]\d*)')
MAX_DOWNLOAD = 32 * 1024 * 1024
MAX_METADATA = 2 * 1024 * 1024
FILES = {'raims.gem'}

def require(condition, message):
    if not condition:
        raise RuntimeError(message)

def digest(raw):
    return hashlib.sha256(raw).hexdigest()

class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, request, file, code, message, headers, new_url):
        return None

def read_response(request, maximum=MAX_METADATA):
    with urllib.request.build_opener(NoRedirect).open(request, timeout=60) as response:
        raw = response.read(maximum + 1)
    require(len(raw) <= maximum, 'The remote response exceeds the allowed size.')
    return raw

def public_download(url):
    parsed = urllib.parse.urlsplit(url)
    require(parsed.scheme == 'https' and parsed.hostname in {'github.com', 'rubygems.org'}
            and parsed.username is None and parsed.password is None, 'Unexpected public artifact origin.')
    request = urllib.request.Request(url, headers={'User-Agent': 'Raims-Ruby-Release'})
    try:
        return read_response(request, MAX_DOWNLOAD)
    except urllib.error.HTTPError as error:
        require(parsed.hostname == 'github.com' and error.code in {301, 302, 303, 307, 308},
                'A public artifact could not be read.')
        destination = error.headers.get('Location', '')
        redirect = urllib.parse.urlsplit(destination)
        require(redirect.scheme == 'https' and redirect.hostname == 'release-assets.githubusercontent.com'
                and redirect.username is None and redirect.password is None, 'Unexpected release download origin.')
        return read_response(urllib.request.Request(destination, headers={'User-Agent': 'Raims-Ruby-Release'}), MAX_DOWNLOAD)

def github_url(endpoint):
    return ('https://api.github.com/repos/' + REPOSITORY + '/' + endpoint).rstrip('/')

def github(endpoint, binary=False):
    token = os.environ.get('GITHUB_TOKEN')
    require(token, 'A GitHub token is required for release verification.')
    headers = {'Authorization': 'Bearer ' + token, 'Accept': 'application/vnd.github+json',
               'User-Agent': 'Raims-Ruby-Release', 'X-GitHub-Api-Version': '2022-11-28'}
    try:
        raw = read_response(urllib.request.Request(github_url(endpoint), headers=headers), MAX_DOWNLOAD if binary else MAX_METADATA)
    except urllib.error.HTTPError as error:
        require(binary and error.code in {301, 302, 303, 307, 308}, 'GitHub release metadata could not be read.')
        destination = error.headers.get('Location', '')
        url = urllib.parse.urlsplit(destination)
        require(url.scheme == 'https' and url.hostname and url.username is None and url.password is None and
                (url.hostname.endswith('.blob.core.windows.net') or url.hostname.endswith('.githubusercontent.com')
                 or url.hostname.endswith('.actions.githubusercontent.com')), 'Unexpected artifact download origin.')
        raw = read_response(urllib.request.Request(destination, headers={'User-Agent': 'Raims-Ruby-Release'}), MAX_DOWNLOAD)
    return raw if binary else json.loads(raw)

def git(source, *args):
    p = subprocess.run(['git', '-C', str(source), *args], capture_output=True, text=True, timeout=60)
    require(p.returncode == 0, 'Release source identity could not be verified.')
    return p.stdout.strip()

def source_version(source):
    raw = (source / 'lib/raims/version.rb').read_text(encoding='utf-8')
    values = re.findall(r"^  VERSION = '([^']+)'$", raw, flags=re.M)
    require(len(values) == 1 and VERSION.fullmatch(values[0]), 'A stable gem version is required.')
    spec = (source / 'raims.gemspec').read_text(encoding='utf-8')
    require(re.findall(r"^  spec.name = '([^']+)'$", spec, flags=re.M) == ['raims']
            and re.findall(r'^  spec.version = (.+)$', spec, flags=re.M) == ['Raims::VERSION'],
            'The declared gem identity differs.')
    return values[0]

def context(source):
    require(os.environ.get('GITHUB_REPOSITORY') == REPOSITORY and os.environ.get('GITHUB_EVENT_NAME') == 'release',
            'Only the official repository release event may publish.')
    event = json.loads(Path(os.environ['GITHUB_EVENT_PATH']).read_text(encoding='utf-8'))
    release = event.get('release', {})
    require(event.get('action') == 'published' and release.get('draft') is False and release.get('prerelease') is False,
            'Only a published stable release can be uploaded.')
    version = source_version(source)
    tag = 'v' + version
    require(release.get('tag_name') == tag and os.environ.get('GITHUB_REF') == 'refs/tags/' + tag,
            'The release tag and gem version differ.')
    head = git(source, 'rev-parse', 'HEAD')
    require(SHA.fullmatch(head) and head == os.environ.get('GITHUB_SHA')
            and git(source, 'rev-parse', 'refs/tags/' + tag + '^{commit}') == head,
            'The checked-out release commit differs.')
    require(not git(source, 'status', '--porcelain', '--untracked-files=all'), 'Release sources must be clean.')
    repo = github('')
    require(repo.get('full_name') == REPOSITORY and repo.get('private') is False and repo.get('default_branch') == 'main',
            'The repository visibility or default branch differs.')
    require(github('commits/' + tag).get('sha') == head, 'The public tag changed.')
    git(source, 'merge-base', '--is-ancestor', head, 'origin/main')
    identifier = release.get('id')
    require(type(identifier) is int and identifier > 0, 'The release identity is invalid.')
    current = github('releases/' + str(identifier))
    require(current.get('id') == identifier and current.get('tag_name') == tag
            and current.get('draft') is False and current.get('prerelease') is False, 'The public release changed.')
    return {'sourceRevision': head, 'version': version, 'tag': tag, 'releaseId': identifier}

def validation(head, wait_seconds=600):
    deadline = time.monotonic() + wait_seconds
    while True:
        value = github('actions/workflows/validate.yml/runs?head_sha=' + head + '&per_page=100&page=1')
        rows = value.get('workflow_runs', [])
        require(isinstance(rows, list) and type(value.get('total_count')) is int, 'Validation history is incomplete.')
        if rows and rows[0].get('status') == 'completed':
            run = rows[0]
            break
        require(time.monotonic() < deadline, 'Validation of this exact commit did not finish within the allowed wait.')
        print('Waiting for validation of the release commit.', flush=True)
        time.sleep(min(15, max(0, deadline - time.monotonic())))
    require(run.get('head_sha') == head and run.get('path') == WORKFLOW and run.get('name') == 'Validate Ruby SDK'
            and run.get('conclusion') == 'success' and run.get('event') in {'push', 'workflow_dispatch'}
            and run.get('repository', {}).get('full_name') == REPOSITORY
            and run.get('head_repository', {}).get('full_name') == REPOSITORY,
            'Successful validation of this exact commit is required.')
    identifier, attempt = run.get('id'), run.get('run_attempt')
    require(type(identifier) is int and identifier > 0 and type(attempt) is int and attempt > 0,
            'Validation attempt identity is incomplete.')
    response = github(f'actions/runs/{identifier}/attempts/{attempt}/jobs?per_page=100&page=1')
    jobs = response.get('jobs', [])
    require(response.get('total_count') == len(jobs) == len(JOBS) and {job.get('name') for job in jobs} == set(JOBS),
            'The complete Ruby validation job inventory is required.')
    for job in jobs:
        suffix, step_name = JOBS[job['name']]
        require(job.get('status') == 'completed' and job.get('conclusion') == 'success'
                and set(job.get('labels', [])) == {f'codebuild-raims-github-actions-{identifier}-{attempt}', suffix}
                and len(job['labels']) == 2 and isinstance(job.get('runner_name'), str)
                and re.fullmatch(r'[a-f0-9]{8}(?:-[a-f0-9]{4}){3}-[a-f0-9]{12}', job['runner_name'])
                and job.get('runner_group_name'), 'A required AWS validation job did not pass.')
        required = [step for step in job.get('steps', []) if step.get('name') == step_name]
        require(len(required) == 1 and required[0].get('status') == 'completed' and required[0].get('conclusion') == 'success',
                'The canonical validation step did not pass.')
    return {'validationRunId': identifier, 'validationRunAttempt': attempt}

def artifact_files(value, proven):
    run, attempt = proven['validationRunId'], proven['validationRunAttempt']
    response = github(f'actions/runs/{run}/artifacts?per_page=100&page=1')
    require(type(response.get('total_count')) is int and 0 < response['total_count'] <= 100
            and isinstance(response.get('artifacts'), list) and len(response['artifacts']) == response['total_count'],
            'Validation artifact inventory is incomplete.')
    found = [row for row in response['artifacts'] if row.get('name') == f'raims-ruby-validation-{run}-{attempt}']
    require(len(found) == 1 and found[0].get('expired') is False
            and found[0].get('workflow_run', {}).get('id') == run
            and found[0].get('workflow_run', {}).get('head_sha') == value['sourceRevision'], 'The approved gem artifact is missing.')
    artifact = found[0]
    require(type(artifact.get('id')) is int and artifact['id'] > 0, 'The artifact identity is invalid.')
    raw = github('actions/artifacts/' + str(artifact['id']) + '/zip', binary=True)
    require(artifact.get('digest') == 'sha256:' + digest(raw), 'The Actions artifact digest differs.')
    with zipfile.ZipFile(io.BytesIO(raw)) as archive:
        expected = {'release-manifest.json', 'dist/raims.gem'}
        require(set(archive.namelist()) == expected and len(archive.infolist()) == len(expected)
                and sum(item.file_size for item in archive.infolist()) <= MAX_DOWNLOAD
                and all(not item.is_dir() and not stat.S_ISLNK(item.external_attr >> 16) for item in archive.infolist()),
                'The canonical gem artifact contains unexpected entries.')
        files = {'raims.gem': archive.read('dist/raims.gem')}
        manifest_raw = archive.read('release-manifest.json')
    manifest = json.loads(manifest_raw)
    require(set(manifest) == {'package', 'sourceRevision', 'toolkitRevision', 'rubyVersions', 'files'}
            and manifest['package'] == {'name': 'raims', 'version': value['version']}
            and manifest['sourceRevision'] == value['sourceRevision']
            and manifest['toolkitRevision'] == os.environ.get('RAIMS_RUBY_TOOLKIT_REF')
            and SHA.fullmatch(str(manifest['toolkitRevision']))
            and manifest['rubyVersions'] == RUBY_VERSIONS
            and manifest['files'] == {name: digest(raw) for name, raw in files.items()},
            'The canonical report and gem bytes differ.')
    files['release-manifest.json'] = manifest_raw
    return files, artifact['id']

def upload_release_asset(identifier, name, raw):
    token = os.environ.get('GITHUB_TOKEN')
    require(token and type(identifier) is int and identifier > 0 and Path(name).name == name, 'An asset upload could not be authorized.')
    endpoint = 'https://uploads.github.com/repos/' + REPOSITORY + '/releases/' + str(identifier) + '/assets?name=' + urllib.parse.quote(name, safe='')
    request = urllib.request.Request(endpoint, data=raw, method='POST', headers={'Authorization': 'Bearer ' + token,
        'Content-Type': 'application/octet-stream', 'User-Agent': 'Raims-Ruby-Release', 'Accept': 'application/vnd.github+json'})
    try:
        read_response(request)
    except (OSError, RuntimeError):
        current = github('releases/' + str(identifier))
        existing = [asset for asset in current.get('assets', []) if asset.get('name') == name]
        require(len(existing) == 1 and public_download(existing[0]['browser_download_url']) == raw,
                'Release asset creation was not confirmed; inspect the release before retrying.')

def release_files(value, files, create_missing=False):
    rows = github('releases/' + str(value['releaseId'])).get('assets', [])
    assets = {asset['name']: asset for asset in rows}
    expected = set(files) | {'SHA256SUMS'}
    require(len(assets) == len(rows) and set(assets).issubset(expected), 'The release contains unexpected or duplicate assets.')
    complete = dict(files, SHA256SUMS=''.join(digest(files[name]) + '  ' + name + '\n' for name in sorted(files)).encode())
    for name, raw in complete.items():
        if name in assets:
            require(public_download(assets[name]['browser_download_url']) == raw, 'An existing release asset differs from approved CI bytes.')
    missing = set(complete) - set(assets)
    require(not missing or create_missing, 'The approved gem assets are missing from the release.')
    for name in sorted(missing):
        upload_release_asset(value['releaseId'], name, complete[name])
    if missing:
        rows = github('releases/' + str(value['releaseId'])).get('assets', [])
        assets = {asset['name']: asset for asset in rows}
    require(len(assets) == len(rows) and set(assets) == expected, 'The release asset inventory differs.')
    for name, raw in complete.items():
        require(public_download(assets[name]['browser_download_url']) == raw, 'A public release asset differs.')

def indexed(version, raw):
    url = 'https://rubygems.org/api/v2/rubygems/raims/versions/' + version + '.json?platform=ruby'
    try:
        metadata = json.loads(read_response(urllib.request.Request(url, headers={'User-Agent': 'Raims-Ruby-Release'})))
    except urllib.error.HTTPError as error:
        if error.code == 404:
            return False
        raise
    require(metadata.get('name') == 'raims' and metadata.get('version') == version
            and metadata.get('platform') == 'ruby' and metadata.get('sha') == digest(raw)
            and metadata.get('metadata', {}).get('source_code_uri') == 'https://github.com/' + REPOSITORY,
            'An immutable RubyGems version differs from the approved identity or bytes.')
    require(public_download('https://rubygems.org/downloads/raims-' + version + '.gem') == raw,
            'The public RubyGems artifact differs from the approved bytes.')
    return True

def validate_local(artifact, files):
    require(artifact.is_dir() and not artifact.is_symlink(), 'The approved upload directory is missing.')
    paths = list(artifact.rglob('*'))
    require({path.relative_to(artifact).as_posix() for path in paths} == {'dist', 'dist/raims.gem', 'release-manifest.json'}
            and all(not path.is_symlink() for path in paths), 'The upload directory contains unexpected entries.')
    for name, raw in files.items():
        path = artifact / name if name == 'release-manifest.json' else artifact / 'dist' / name
        require(path.read_bytes() == raw, 'The local gem upload differs from approved CI bytes.')

def publish(artifact, value, files):
    if indexed(value['version'], files['raims.gem']):
        print('The exact approved gem is already published.', flush=True)
        return
    token = os.environ.get('GEM_HOST_API_KEY', '')
    require(bool(token) and '\r' not in token and '\n' not in token, 'An ephemeral RubyGems publishing credential is required.')
    environment = {key: content for key, content in os.environ.items() if key.upper() in {
        'PATH', 'HOME', 'USERPROFILE', 'SYSTEMROOT', 'WINDIR', 'TEMP', 'TMP', 'TMPDIR', 'LD_LIBRARY_PATH',
        'GEM_HOST_API_KEY', 'ACTIONS_ID_TOKEN_REQUEST_URL', 'ACTIONS_ID_TOKEN_REQUEST_TOKEN',
        'GITHUB_ACTIONS', 'GITHUB_SERVER_URL', 'GITHUB_REPOSITORY', 'GITHUB_REF', 'GITHUB_SHA', 'GITHUB_EVENT_NAME'}}
    result = subprocess.run(['ruby', '-S', 'gem', 'push', str(artifact / 'dist/raims.gem'), '--host', 'https://rubygems.org'],
                            cwd=str(artifact), env=environment, capture_output=True, timeout=300, check=False)
    if result.returncode:
        print('The push response was not successful; checking the public version before another upload.', flush=True)
    # Do not repeat an uncertain write. A rerun checks immutable public bytes first.
    confirm(value['version'], files)

def confirm(version, files, wait_seconds=600):
    deadline = time.monotonic() + wait_seconds
    while True:
        if indexed(version, files['raims.gem']):
            print('RubyGems serves the exact approved gem bytes.', flush=True)
            return
        require(time.monotonic() < deadline, 'RubyGems has not confirmed the gem; inspect the registry before retrying.')
        time.sleep(min(10, max(0, deadline - time.monotonic())))

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('command', choices=('prepare', 'verify', 'publish', 'confirm'))
    parser.add_argument('--source', type=Path, required=True)
    parser.add_argument('--artifact', type=Path, required=True)
    args = parser.parse_args()
    source, artifact = args.source.resolve(), args.artifact.resolve()
    workspace = Path(os.environ.get('GITHUB_WORKSPACE', '.')).resolve()
    require(workspace / '.tmp' in artifact.parents, 'Release artifacts must stay in workspace .tmp.')
    value = context(source)
    proven = validation(value['sourceRevision'])
    files, _identifier = artifact_files(value, proven)
    release_files(value, files, create_missing=args.command == 'prepare')
    if args.command == 'prepare':
        require(not artifact.exists(), 'Use a new upload directory.')
        (artifact / 'dist').mkdir(parents=True)
        for name, raw in files.items():
            (artifact / name if name == 'release-manifest.json' else artifact / 'dist' / name).write_bytes(raw)
    else:
        validate_local(artifact, files)
    if args.command == 'verify':
        required = not indexed(value['version'], files['raims.gem'])
        if os.environ.get('GITHUB_OUTPUT'):
            with Path(os.environ['GITHUB_OUTPUT']).open('a', encoding='utf-8') as output:
                output.write('publishRequired=' + ('true' if required else 'false') + '\n')
    elif args.command == 'publish':
        publish(artifact, value, files)
    elif args.command == 'confirm':
        confirm(value['version'], files)
    return 0

if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, ValueError, RuntimeError, subprocess.SubprocessError, zipfile.BadZipFile) as error:
        print('Ruby release verification failed: ' + str(error), file=sys.stderr)
        sys.exit(1)
