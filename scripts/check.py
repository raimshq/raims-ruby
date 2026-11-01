#!/usr/bin/env python3
"""Run the canonical Ruby SDK engineering gate."""
from pathlib import Path
import runpy
import sys

sys.dont_write_bytecode = True


def main():
    if sys.flags.optimize:
        raise RuntimeError('Validation requires Python without -O or -OO.')
    source = Path(__file__).resolve().parent.parent
    workspace = source.parent
    validator = workspace / 'Developer-Toolkit/scripts/release-preflight/ruby_sdk.py'
    if not validator.is_file() or not (workspace / 'AGENTS.md').is_file():
        raise RuntimeError('Validation requires the Raims engineering workspace and its sibling Developer Toolkit checkout. See CONTRIBUTING.md.')
    original = sys.argv
    try:
        sys.argv = [str(validator), '--source', str(source), '--workspace', str(workspace)] + original[1:]
        runpy.run_path(str(validator), run_name='__main__')
    finally:
        sys.argv = original


if __name__ == '__main__':
    main()
