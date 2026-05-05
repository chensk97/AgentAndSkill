#!/usr/bin/env python3

from __future__ import annotations

import json
import re
import sys
from pathlib import Path
from typing import Iterable
from urllib.parse import unquote


REPO_ROOT = Path(__file__).resolve().parents[1]
REGISTRY_PATH = REPO_ROOT / "registry" / "agent_skill_registry.json"
INDEX_PATH = REPO_ROOT / "Doc" / "Agent_Skill_Index.md"

PD_RUNTIME_REF = "{{AAS_HOME}}/agents/pd-references/AGENTS.md"
PL_RUNTIME_REF = "{{AAS_HOME}}/agents/pl-references/AGENTS.md"

FRONTMATTER_RE = re.compile(r"\A---\n.*?\n---\n", re.DOTALL)
LINK_RE = re.compile(r"\[[^\]]+\]\(([^)]+)\)")
VERSIONED_MD_RE = re.compile(r"(_R\d+|_round\d+|_v\d+)(?=\.md$)", re.IGNORECASE)

REQUIRED_FILES = [
    "AGENTS.md",
    "README.md",
    "README_zh.md",
    "CHANGELOG.md",
    "LICENSE",
    "sync.sh",
    ".gitignore",
    "Doc/README(project-director).md",
    "Doc/README(pl-coordinator).md",
    "Doc/Agent_Skill_Index.md",
    "agents/pd-references/AGENTS.md",
    "agents/pd-references/agent_progress_template.md",
    "agents/pd-references/architecture_template.md",
    "agents/pd-references/prd_template.md",
    "agents/pd-references/quality_check_template.md",
    "agents/pd-references/test_report_template.md",
    "agents/pd-references/repo_readiness_template.md",
    "agents/pd-references/archive_audit_checklist_template.md",
    "agents/pl-references/AGENTS.md",
    "agents/pl-references/deep_dive_template.md",
    "agents/pl-references/dependency_map_template.md",
    "agents/pl-references/flow_template.md",
    "agents/pl-references/knowledge_base_template.md",
    "agents/pl-references/learning_path_template.md",
    "agents/pl-references/learning_plan_template.md",
    "agents/pl-references/learning_progress_template.md",
    "agents/pl-references/learning_report_template.md",
    "agents/pl-references/project_map_template.md",
    "agents/pl-references/resource_library_template.md",
    "agents/pl-references/support_log_template.md",
    "agents/pl-references/test_analysis_template.md",
    "agents/pl-references/archive_audit_checklist_template.md",
    "registry/agent_skill_registry.json",
    "tools/validate_copilot_assets.py"
]

SKIP_LINK_PREFIXES = (
    "http://",
    "https://",
    "mailto:",
    "file://",
    "vscode:",
    "{{AAS_HOME}}/"
)


def load_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def iter_markdown_files() -> Iterable[Path]:
    for path in REPO_ROOT.rglob("*.md"):
        if "/.git/" in path.as_posix():
            continue
        yield path


def fail(errors: list[str], message: str) -> None:
    errors.append(message)


def check_required_files(errors: list[str]) -> None:
    for relative_path in REQUIRED_FILES:
        if not (REPO_ROOT / relative_path).exists():
            fail(errors, f"Missing required file: {relative_path}")


def check_registry(errors: list[str]) -> dict:
    if not REGISTRY_PATH.exists():
        fail(errors, f"Registry file not found: {REGISTRY_PATH.relative_to(REPO_ROOT)}")
        return {"agents": [], "skills": []}

    try:
        registry = json.loads(load_text(REGISTRY_PATH))
    except json.JSONDecodeError as exc:
        fail(errors, f"Registry JSON is invalid: {exc}")
        return {"agents": [], "skills": []}

    names: set[str] = set()
    for group_name in ("agents", "skills"):
        entries = registry.get(group_name)
        if not isinstance(entries, list):
            fail(errors, f"Registry field '{group_name}' must be a list")
            continue
        for entry in entries:
            for key in ("name", "path", "suite", "sharedRules", "outputs"):
                if key not in entry:
                    fail(errors, f"Registry entry in '{group_name}' is missing key '{key}': {entry}")
                    continue
            name = entry.get("name")
            path = entry.get("path")
            suite = entry.get("suite")
            if not isinstance(name, str) or not name:
                fail(errors, f"Registry entry has invalid name: {entry}")
                continue
            if name in names:
                fail(errors, f"Duplicate registry name: {name}")
            names.add(name)
            if not isinstance(path, str):
                fail(errors, f"Registry entry has invalid path for {name}: {path}")
                continue
            target_path = REPO_ROOT / path
            if not target_path.exists():
                fail(errors, f"Registry target does not exist for {name}: {path}")
                continue
            if suite == "pd" and entry.get("sharedRules") != "agents/pd-references/AGENTS.md":
                fail(errors, f"Registry sharedRules mismatch for {name}: {entry.get('sharedRules')}")
            if suite == "pl" and entry.get("sharedRules") != "agents/pl-references/AGENTS.md":
                fail(errors, f"Registry sharedRules mismatch for {name}: {entry.get('sharedRules')}")

            text = load_text(target_path)
            if not FRONTMATTER_RE.match(text):
                fail(errors, f"Missing or malformed frontmatter: {path}")
            if "name:" not in text or "description:" not in text:
                fail(errors, f"Frontmatter missing name/description: {path}")

            expected_runtime_ref = PD_RUNTIME_REF if suite == "pd" else PL_RUNTIME_REF
            if expected_runtime_ref not in text:
                fail(errors, f"Missing shared runtime AGENTS reference in {path}")

            if "## Superpowers 技能集成" not in text:
                fail(errors, f"Missing Superpowers section in {path}")
            if "superpowers:" not in text:
                fail(errors, f"Missing explicit superpowers identifier in {path}")

    entry_names = names
    for entry in registry.get("agents", []) + registry.get("skills", []):
        for rel_key in ("delegatesTo", "handoffTo", "assistsWith", "usedBy"):
            for related_name in entry.get(rel_key, []):
                if related_name not in entry_names:
                    fail(errors, f"Registry relation '{rel_key}' in {entry['name']} points to unknown entry '{related_name}'")

    return registry


def check_index_coverage(errors: list[str], registry: dict) -> None:
    if not INDEX_PATH.exists():
        fail(errors, f"Missing total index document: {INDEX_PATH.relative_to(REPO_ROOT)}")
        return
    index_text = load_text(INDEX_PATH)
    for entry in registry.get("agents", []) + registry.get("skills", []):
        name = entry.get("name")
        if isinstance(name, str) and name not in index_text:
            fail(errors, f"Total index is missing entry name: {name}")


def check_markdown_links(errors: list[str]) -> None:
    for markdown_path in iter_markdown_files():
        text = load_text(markdown_path)
        for raw_target in LINK_RE.findall(text):
            target = raw_target.strip()
            if not target or target.startswith("#"):
                continue
            if target.startswith(SKIP_LINK_PREFIXES):
                continue
            if target.startswith("git@"):
                continue
            clean_target = unquote(target.split("#", 1)[0])
            candidate = (markdown_path.parent / clean_target).resolve()
            if not candidate.exists():
                fail(errors, f"Broken markdown link in {markdown_path.relative_to(REPO_ROOT)} -> {target}")


def check_versioned_docs(errors: list[str]) -> None:
    allowed_archive_markers = (
        "/PRD/",
        "/Architecture/",
        "/QualityCheck/",
        "/TestCases/",
        "/TestReport/",
        "/PLAN/",
        "/MAP/",
        "/PATH/",
        "/REPORTS/HISTORY/",
        "/Other/",
        "/DEEP_DIVE/",
        "/FLOWS/"
    )
    for markdown_path in iter_markdown_files():
        if markdown_path.name == "CHANGELOG.md":
            continue
        if VERSIONED_MD_RE.search(markdown_path.name):
            normalized = markdown_path.as_posix()
            if not any(marker in normalized for marker in allowed_archive_markers):
                fail(errors, f"Version-suffixed markdown is outside an archive folder: {markdown_path.relative_to(REPO_ROOT)}")


SKILL_TEMPLATE_PAIRS = [
    ("skills/pl-analyze-deps/dependency_map_template.md", "agents/pl-references/dependency_map_template.md"),
    ("skills/pl-build-kb/knowledge_base_template.md", "agents/pl-references/knowledge_base_template.md"),
    ("skills/pl-gen-tests/test_analysis_template.md", "agents/pl-references/test_analysis_template.md"),
    ("skills/pl-scan-project/project_map_template.md", "agents/pl-references/project_map_template.md"),
    ("skills/pl-trace-flow/flow_template.md", "agents/pl-references/flow_template.md"),
]

PL_NON_CANONICAL_PATHS = {
    "LEARNING_PLAN.md": ("LEARNINGS/", "LEARNINGS/LEARNING_PLAN.md"),
    "LEARNING_PROGRESS.md": ("LEARNINGS/", "LEARNINGS/LEARNING_PROGRESS.md"),
    "PROJECT_MAP.md": ("LEARNINGS/", "LEARNINGS/PROJECT_MAP.md"),
    "DEPENDENCY_MAP.md": ("LEARNINGS/", "LEARNINGS/DEPENDENCY_MAP.md"),
    "LEARNING_PATH.md": ("LEARNINGS/", "LEARNINGS/LEARNING_PATH.md"),
    "KNOWLEDGE_BASE/INDEX.md": ("LEARNINGS/", "LEARNINGS/KNOWLEDGE_BASE/INDEX.md"),
    "RESOURCES/RESOURCE_LIBRARY.md": ("LEARNINGS/", "LEARNINGS/RESOURCES/RESOURCE_LIBRARY.md"),
    "SUPPORT/SUPPORT_LOG.md": ("LEARNINGS/", "LEARNINGS/SUPPORT/SUPPORT_LOG.md"),
    "REPORTS/LEARNING_REPORT.md": ("LEARNINGS/", "LEARNINGS/REPORTS/LEARNING_REPORT.md"),
    "TEST_ANALYSIS_<module>.md": ("LEARNINGS/TESTS/", "LEARNINGS/TESTS/TEST_ANALYSIS_<module>.md"),
}

DOC_REQUIRED_PATH_SNIPPETS = {
    "Doc/README(project-director).md": [
        "Agent_doc/PRD.md",
        "Agent_doc/System_Architecture_and_Task_Breakdown.md",
        "Agent_doc/pd-developer-doc/README_<模块名>.md",
        "Agent_doc/pd-qa-tester-doc/Test_Cases_<任务标识>.md",
        "Agent_doc/pd-qa-tester-doc/Test_Report_<任务标识>.md",
    ],
    "Doc/Agent_Skill_Index.md": [
        "Agent_doc/pd-qa-tester-doc/Test_Cases_<任务标识>.md",
        "Agent_doc/pd-qa-tester-doc/Test_Report_<任务标识>.md",
        "LEARNINGS/TESTS/TEST_ANALYSIS_<module>.md",
    ],
}

TARGETED_FORBIDDEN_PATH_PATTERNS = {
    "agents/pd-architect-task-planner.md": [
        (r"(?<!Agent_doc/)PRD\.md", "Agent_doc/PRD.md"),
        (r"(?<!Agent_doc/)System_Architecture_and_Task_Breakdown\.md", "Agent_doc/System_Architecture_and_Task_Breakdown.md"),
    ],
    "agents/pd-developer.md": [
        (r"(?<!Agent_doc/)System_Architecture_and_Task_Breakdown\.md", "Agent_doc/System_Architecture_and_Task_Breakdown.md"),
    ],
    "Doc/README(project-director).md": [
        (r"(?<!Agent_doc/)PRD\.md", "Agent_doc/PRD.md"),
        (r"(?<!Agent_doc/)System_Architecture_and_Task_Breakdown\.md", "Agent_doc/System_Architecture_and_Task_Breakdown.md"),
    ],
}


def check_skill_template_consistency(errors: list[str]) -> None:
    for skill_path, canonical_path in SKILL_TEMPLATE_PAIRS:
        skill_file = REPO_ROOT / skill_path
        canonical_file = REPO_ROOT / canonical_path
        if not skill_file.exists():
            fail(errors, f"Skill-local template missing: {skill_path}")
            continue
        if not canonical_file.exists():
            fail(errors, f"Canonical template missing: {canonical_path}")
            continue
        if load_text(skill_file) != load_text(canonical_file):
            fail(errors, f"Skill template diverged from canonical: {skill_path} != {canonical_path}")


def check_canonical_doc_paths(errors: list[str]) -> None:
    for markdown_path in iter_markdown_files():
        if markdown_path.name == "CHANGELOG.md":
            continue
        text = load_text(markdown_path)
        for non_canonical, (allowed_prefix, canonical) in PL_NON_CANONICAL_PATHS.items():
            pattern = re.compile(rf"(?<!{re.escape(allowed_prefix)}){re.escape(non_canonical)}")
            if pattern.search(text):
                fail(
                    errors,
                    f"Non-canonical documented path in {markdown_path.relative_to(REPO_ROOT)}: '{non_canonical}' should be '{canonical}'"
                )

    for relative_path, snippets in DOC_REQUIRED_PATH_SNIPPETS.items():
        text = load_text(REPO_ROOT / relative_path)
        for snippet in snippets:
            if snippet not in text:
                fail(errors, f"Missing canonical documented path in {relative_path}: '{snippet}'")

    for relative_path, patterns in TARGETED_FORBIDDEN_PATH_PATTERNS.items():
        text = load_text(REPO_ROOT / relative_path)
        for pattern_text, canonical in patterns:
            if re.search(pattern_text, text):
                fail(errors, f"Non-canonical documented path in {relative_path}: should use '{canonical}'")


def main() -> int:
    errors: list[str] = []
    check_required_files(errors)
    registry = check_registry(errors)
    check_index_coverage(errors, registry)
    check_markdown_links(errors)
    check_versioned_docs(errors)
    check_skill_template_consistency(errors)
    check_canonical_doc_paths(errors)

    if errors:
        print("Validation failed:")
        for item in errors:
            print(f"- {item}")
        return 1

    print("Validation passed:")
    print(f"- registry: {REGISTRY_PATH.relative_to(REPO_ROOT)}")
    print(f"- total index: {INDEX_PATH.relative_to(REPO_ROOT)}")
    print("- shared AGENTS references, Superpowers sections, markdown links, canonical documented paths, skill template consistency, and required files are consistent")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())