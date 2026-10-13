#!/usr/bin/env python3
"""
doctor_helper.py - Dedicated helper for flow doctor check registry,
JSON report formatting, and bundled-tree receipt verification.
Compatible with Python 3.8+ (no nested f-string quotes, no walrus operators).
"""

import os
import sys
import json
import hashlib
import re
from pathlib import Path

REGISTRY_PATH = Path(__file__).resolve().parent / "doctor-checks.tsv"

def get_registry():
    checks = []
    if REGISTRY_PATH.exists():
        with open(str(REGISTRY_PATH), "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line or line.startswith("#"):
                    continue
                parts = line.split("\t", 2)
                if len(parts) == 3:
                    checks.append((parts[0].strip(), parts[1].strip(), parts[2].strip()))
    return checks

def get_known_names():
    return [name for name, _, _ in get_registry()]

def cmd_list(as_json=False):
    reg = get_registry()
    if as_json:
        checks = [
            {"name": name, "category": cat, "description": desc}
            for name, cat, desc in reg
        ]
        envelope = {
            "schema_version": 1,
            "kind": "doctor.list",
            "checks": checks,
        }
        print(json.dumps(envelope, indent=2))
    else:
        print("flow doctor - available checks:")
        for name, _, desc in reg:
            print("  %-24s %s" % (name, desc))


def cmd_validate_checks(csv_str):
    parts = csv_str.split(",")
    canonical = []
    unknown = []
    has_non_empty = False

    for p in parts:
        c = p.strip()
        if not c:
            continue
        has_non_empty = True
        known = set(get_known_names())
        if c in known:
                canonical.append(c)
        else:
            if c not in unknown:
                unknown.append(c)

    if not has_non_empty:
        print("ERROR:--check requires at least one non-empty check name")
        sys.exit(1)

    if unknown:
        sample = ", ".join(unknown)
        print("ERROR:unknown check name(s): %s (run 'flow doctor --list' for available checks)" % (sample,))
        sys.exit(1)

    print(",".join(canonical))


def cmd_format_error(msg):
    envelope = {
        "schema_version": 1,
        "kind": "doctor.report",
        "healthy": False,
        "error": msg,
        "summary": {"total": 1, "ok": 0, "warn": 0, "fail": 1, "skip": 0},
        "checks": [
            {
                "name": "check_selection",
                "category": "registry",
                "status": "fail",
                "evidence": msg,
            }
        ],
    }
    print(json.dumps(envelope, indent=2))


def cmd_format_report(ok_flag):
    # Expect NUL-delimited records: name\0category\0status\0evidence\0...
    try:
        raw_bytes = sys.stdin.buffer.read()
        raw_text = raw_bytes.decode("utf-8", errors="replace")
    except Exception as e:
        cmd_format_error("failed to read report stream: %s" % (str(e),))
        return

    tokens = raw_text.split("\x00")
    if tokens and tokens[-1] == "":
        tokens.pop()

    if len(tokens) % 4 != 0:
        cmd_format_error("malformed report records stream (tokens count %d not divisible by 4)" % (len(tokens),))
        return

    checks = []
    summary = {"total": 0, "ok": 0, "warn": 0, "fail": 0, "skip": 0}

    for i in range(0, len(tokens), 4):
        name = tokens[i]
        cat = tokens[i + 1]
        status = tokens[i + 2]
        ev = tokens[i + 3]
        checks.append({
            "name": name,
            "category": cat,
            "status": status,
            "evidence": ev,
        })
        summary["total"] += 1
        if status in summary:
            summary[status] += 1
        else:
            summary["fail"] += 1

    healthy = (summary["fail"] == 0) and (ok_flag == 1)
    envelope = {
        "schema_version": 1,
        "kind": "doctor.report",
        "healthy": healthy,
        "summary": summary,
        "checks": checks,
    }
    print(json.dumps(envelope, indent=2))


def _reject_duplicate_keys_hook(ordered_pairs):
    d = {}
    for k, v in ordered_pairs:
        if k in d:
            raise ValueError("duplicate key: " + str(k))
        d[k] = v
    return d


def cmd_verify_receipt(skill_dir_str, manifest_path_str):
    skill_dir = Path(skill_dir_str)
    mf_path_str = str(manifest_path_str)

    # Check symlink or existence using lexists
    if os.path.islink(mf_path_str):
        print("FAIL:manifest receipt file cannot be a symlink")
        return

    if not os.path.lexists(mf_path_str):
        print("SKIP:dev checkout (install receipt not present)")
        return

    if not os.path.isfile(mf_path_str):
        print("FAIL:manifest receipt path is not a regular file")
        return

    try:
        with open(mf_path_str, "r", encoding="utf-8") as f:
            data = json.load(f, object_pairs_hook=_reject_duplicate_keys_hook)
    except Exception as e:
        print("FAIL:malformed receipt JSON (%s)" % (str(e),))
        return

    if not isinstance(data, dict):
        print("FAIL:unsupported receipt schema (root must be an object)")
        return

    schema_v = data.get("schema_version")
    if type(schema_v) is not int or schema_v != 1:
        print("FAIL:unsupported receipt schema (expected schema_version: 1)")
        return

    files = data.get("files")
    if not isinstance(files, dict) or not files:
        print("FAIL:receipt missing 'files' mapping")
        return

    try:
        resolved_skill_dir = skill_dir.resolve()
    except Exception as e:
        print("FAIL:cannot resolve skill root directory (%s)" % (str(e),))
        return

    unsafe = []
    symlinks = []
    missing = []
    modified = []

    for rel_path, expected_hash in files.items():
        if not isinstance(rel_path, str):
            unsafe.append(str(rel_path))
            continue

        # Strictly reject backslashes anywhere
        if "\\" in rel_path:
            unsafe.append("%s (backslashes forbidden)" % (rel_path,))
            continue

        # Cannot be empty or receipt self-reference
        if not rel_path or rel_path == "manifest-hashes.json":
            unsafe.append("%s (reserved receipt self-reference)" % (rel_path,))
            continue

        # Disallow leading slash, trailing slash, drive colons
        if rel_path.startswith("/") or rel_path.endswith("/") or ":" in rel_path:
            unsafe.append(rel_path)
            continue

        parts = rel_path.split("/")
        # Disallow empty parts, '.', and '..'
        if any((p == "" or p == "." or p == "..") for p in parts):
            unsafe.append(rel_path)
            continue

        # Digest format validation: exactly 64 hex characters, fullmatch
        if not isinstance(expected_hash, str) or not re.fullmatch(r"[0-9a-fA-F]{64}\Z", expected_hash):
            unsafe.append("%s (invalid digest format)" % (rel_path,))
            continue

        # Check every path component from skill_dir down to target for symlinks
        cur = skill_dir
        symlink_found = False
        for comp in parts:
            cur = cur / comp
            if os.path.islink(str(cur)):
                symlinks.append("%s (symlink at %s)" % (rel_path, comp))
                symlink_found = True
                break
        if symlink_found:
            continue

        target = cur
        if not target.is_file():
            missing.append(rel_path)
            continue

        # Verify strict containment within skill_dir
        try:
            resolved_target = target.resolve()
            if resolved_skill_dir not in resolved_target.parents and resolved_target != resolved_skill_dir:
                unsafe.append("%s (out-of-root target)" % (rel_path,))
                continue
        except Exception:
            unsafe.append("%s (unresolvable path)" % (rel_path,))
            continue

        # Hash verification with caught filesystem read errors
        h = hashlib.sha256()
        try:
            with open(str(target), "rb") as tf:
                chunk = tf.read(65536)
                while chunk:
                    h.update(chunk)
                    chunk = tf.read(65536)
        except PermissionError:
            modified.append("%s (permission denied)" % (rel_path,))
            continue
        except OSError as e:
            modified.append("%s (read error: %s)" % (rel_path, str(e)))
            continue

        actual = h.hexdigest().lower()
        if actual != expected_hash.lower():
            modified.append("%s (expected %s..., got %s...)" % (rel_path, expected_hash[:8], actual[:8]))

    if unsafe:
        sample = ", ".join(unsafe[:3])
        print("FAIL:unsafe path(s) in receipt: %s" % (sample,))
    elif symlinks:
        sample = ", ".join(symlinks[:3])
        print("FAIL:symlink(s) in bundled tree: %s" % (sample,))
    elif missing:
        sample = ", ".join(missing[:3])
        print("FAIL:missing bundled file(s): %s" % (sample,))
    elif modified:
        sample = ", ".join(modified[:3])
        print("FAIL:modified bundled file(s): %s" % (sample,))
    else:
        print("OK:%d" % (len(files),))

def cmd_verify_bounded_json(project_root_str):
    root = Path(project_root_str).resolve()
    flow_dir = root / ".flow"
    handoff_dir = flow_dir / "context-handoff"
    journal_dir = flow_dir / "journal"

    if not handoff_dir.exists() and not journal_dir.exists():
        print("SKIP:no bounded state directories present")
        return

    # 1. Check context-handoff if present
    if handoff_dir.exists():
        if os.path.islink(str(handoff_dir)):
            print("FAIL:context-handoff directory is a symlink")
            return
        if not handoff_dir.is_dir():
            print("FAIL:context-handoff is not a directory")
            return
        if os.name != "nt":
            st = handoff_dir.stat()
            if hasattr(os, "getuid") and st.st_uid != os.getuid():
                print("FAIL:context-handoff directory foreign owner")
                return
            if (st.st_mode & 0o777) != 0o700:
                print("FAIL:context-handoff directory mode is not 0700 (got %o)" % (st.st_mode & 0o777))
                return

        snap = handoff_dir / "snapshot.json"
        if snap.exists():
            if os.path.islink(str(snap)):
                print("FAIL:snapshot.json is a symlink")
                return
            if not snap.is_file():
                print("FAIL:snapshot.json is not a regular file")
                return
            if os.name != "nt":
                st_snap = snap.stat()
                if hasattr(os, "getuid") and st_snap.st_uid != os.getuid():
                    print("FAIL:snapshot.json foreign owner")
                    return
                if (st_snap.st_mode & 0o777) != 0o600:
                    print("FAIL:snapshot.json mode is not 0600 (got %o)" % (st_snap.st_mode & 0o777))
                    return
                if st_snap.st_size > 256 * 1024:
                    print("FAIL:snapshot.json exceeds 256 KiB cap")
                    return
            try:
                with open(str(snap), "r", encoding="utf-8") as f:
                    data = json.load(f, object_pairs_hook=_reject_duplicate_keys_hook)
                if not isinstance(data, dict):
                    print("FAIL:snapshot.json root is not an object")
                    return
            except Exception as e:
                print("FAIL:snapshot.json invalid JSON (%s)" % (str(e),))
                return

    # 2. Check journal if present
    if journal_dir.exists():
        if os.path.islink(str(journal_dir)):
            print("FAIL:journal directory is a symlink")
            return
        if not journal_dir.is_dir():
            print("FAIL:journal is not a directory")
            return
        if os.name != "nt":
            st_j = journal_dir.stat()
            if hasattr(os, "getuid") and st_j.st_uid != os.getuid():
                print("FAIL:journal directory foreign owner")
                return
            if (st_j.st_mode & 0o777) != 0o700:
                print("FAIL:journal directory mode is not 0700 (got %o)" % (st_j.st_mode & 0o777))
                return
        try:
            for entry in journal_dir.iterdir():
                if entry.name.endswith(".json"):
                    if os.path.islink(str(entry)):
                        print("FAIL:journal file is a symlink: %s" % (entry.name,))
                        return
                    if not entry.is_file():
                        print("FAIL:journal entry is not a regular file: %s" % (entry.name,))
                        return
                    if os.name != "nt":
                        st_e = entry.stat()
                        if hasattr(os, "getuid") and st_e.st_uid != os.getuid():
                            print("FAIL:journal file foreign owner: %s" % (entry.name,))
                            return
                        if (st_e.st_mode & 0o777) != 0o600:
                            print("FAIL:journal file mode is not 0600 (got %o): %s" % (st_e.st_mode & 0o777, entry.name))
                            return
                        if st_e.st_size > 256 * 1024:
                            print("FAIL:journal file exceeds 256 KiB cap: %s" % (entry.name,))
                            return
                    try:
                        with open(str(entry), "r", encoding="utf-8") as f:
                            data = json.load(f, object_pairs_hook=_reject_duplicate_keys_hook)
                    except Exception as e:
                        print("FAIL:journal file invalid JSON (%s): %s" % (str(e), entry.name))
                        return
        except Exception as e:
            print("FAIL:cannot iterate journal directory: %s" % (str(e),))
            return

    print("OK:bounded state verified (private modes, no symlinks)")


def main():
    if len(sys.argv) < 2:
        sys.exit(1)

    cmd = sys.argv[1]
    if cmd == "list":
        cmd_list(as_json=False)
    elif cmd == "list-json":
        cmd_list(as_json=True)
    elif cmd == "validate-checks":
        csv_str = sys.argv[2] if len(sys.argv) > 2 else ""
        cmd_validate_checks(csv_str)
    elif cmd == "format-error":
        msg = sys.argv[2] if len(sys.argv) > 2 else "Unknown error"
        cmd_format_error(msg)
    elif cmd == "format-report":
        ok_flag = int(sys.argv[2]) if len(sys.argv) > 2 else 0
        cmd_format_report(ok_flag)
    elif cmd == "verify-receipt":
        if len(sys.argv) < 4:
            print("FAIL:insufficient arguments for verify-receipt")
            return
        cmd_verify_receipt(sys.argv[2], sys.argv[3])
    elif cmd == "verify-bounded-json":
        if len(sys.argv) < 3:
            print("FAIL:insufficient arguments for verify-bounded-json")
            return
        cmd_verify_bounded_json(sys.argv[2])
    else:
        sys.exit(1)


if __name__ == "__main__":
    main()
