"""Static checks on SKILL.md so prose edits don't drop critical guardrails.

FORK: rewritten to guard the fork's policy invariants — the
ANSWER-class / ACT-class rule and the provenance banner — instead of the
upstream act-on-messages-by-default policy this fork deliberately removed.
"""

from __future__ import annotations

from pathlib import Path

SKILL_DIR = Path(__file__).resolve().parent.parent
SKILL = (SKILL_DIR / "SKILL.md").read_text()


class TestFrontmatter:
    def test_name(self):
        assert "name: inter-session" in SKILL

    def test_allowed_tools(self):
        assert "allowed-tools" in SKILL
        for tool in ("Bash", "Monitor", "TaskList", "TaskStop"):
            assert tool in SKILL


class TestSubcommands:
    def test_dispatch_table_has_all_subcommands(self):
        for sub in ("connect", "install-deps", "list", "send", "broadcast",
                    "rename", "status", "disconnect"):
            assert f"`/inter-session {sub}" in SKILL or f"`/inter-session [args]" in SKILL


class TestReactionPolicy:
    def test_upstream_act_by_default_policy_is_gone(self):
        # The fork's whole point: peers do NOT get user-level obedience.
        assert "as if the user typed it" not in SKILL
        assert "acted on as instructions by default" not in SKILL

    def test_two_class_rule_present(self):
        assert "ANSWER-class" in SKILL
        assert "ACT-class" in SKILL
        assert "operator-gated" in SKILL

    def test_act_class_parks_for_operator(self):
        assert "`parked:" in SKILL
        assert "Do NOT act" in SKILL

    def test_peer_approval_is_not_operator_approval(self):
        assert "never grant permissions" in SKILL
        assert "not evidence" in SKILL  # "the operator approved this" claim

    def test_cosign_is_answer_class_not_bypass(self):
        assert "Co-sign requests are ANSWER-class" in SKILL
        assert "never a bypass" in SKILL

    def test_ratification_routes_to_executing_session(self):
        assert "executing session" in SKILL
        assert "awaiting your GO" in SKILL
        assert "cannot be relayed" in SKILL

    def test_destructive_ops_require_explicit_content(self):
        for kw in ("rm -rf", "git push --force", "DROP TABLE", "kubectl delete"):
            assert kw in SKILL

    def test_reply_prefixes(self):
        for prefix in ("`done:", "`status:", "`answer:", "`question:", "`parked:"):
            assert prefix in SKILL

    def test_permission_rules_not_overridden(self):
        assert "do NOT override" in SKILL or "do not override" in SKILL.lower()


class TestProvenanceBanner:
    def test_banner_documented(self):
        assert "INTER-AGENT MESSAGE" in SKILL
        assert "NOT the operator" in SKILL

    def test_banner_described_as_unforgeable(self):
        assert "cannot omit or forge" in SKILL

    def test_client_stamps_banner(self):
        client = (SKILL_DIR / "bin" / "client.py").read_text()
        assert 'INTER-AGENT MESSAGE from' in client
        assert "NOT the operator" in client


class TestInstallDepsUx:
    def test_uses_isolated_venv_by_default(self):
        assert "~/.claude/data/inter-session/venv" in SKILL
        assert "python3 -m venv" in SKILL or "uv venv" in SKILL

    def test_offers_uv_as_optional(self):
        assert "uv" in SKILL

    def test_no_user_or_system_pip_pollution(self):
        assert "pip install --user" not in SKILL
        assert "pip install --system" not in SKILL
        assert "--break-system-packages" not in SKILL


class TestNameValidation:
    def test_ascii_regex_in_skill(self):
        assert "[a-z0-9]" in SKILL


class TestTruncationHandling:
    def test_messages_log_pointer_documented(self):
        assert "messages.log" in SKILL

    def test_classify_on_full_text(self):
        # An ACT-class tail must not hide behind a truncated ANSWER-class head.
        assert "FULL text" in SKILL
