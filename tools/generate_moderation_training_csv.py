#!/usr/bin/env python3
"""Create a split-isolated synthetic moderation dataset for development.

This data is useful for pipeline testing and pre-training only.  It is never a
substitute for a consented, human-reviewed production evaluation set.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
from pathlib import Path


DEFAULT_ROWS = 500_000
POLICIES = (
    "clean", "toxic", "harassment", "hate_speech", "violence", "self_harm",
    "nsfw", "adult_ungated", "spam", "misinformation", "medical_claim",
    "undisclosed_sponsor", "impersonation", "custom",
)
SOURCE_TYPES = ("post", "comment", "profile_bio", "direct_message", "workout_caption", "meal_plan", "live_chat")
LOCALES = ("en-KE", "en-US", "en-GB", "sw-KE")
WORKOUTS = ("strength session", "morning run", "yoga flow", "cycling class", "mobility routine", "HIIT circuit", "recovery walk", "meal-prep plan")
AUDIENCES = ("beginners", "our running group", "my training partner", "the community", "new members", "weekend athletes")
SPLIT_CONTEXTS = {
    "train": ("after my usual session", "in our weekday check-in", "during a group discussion", "in a progress update"),
    "validation": ("while replying to a member", "in a weekend thread", "after reviewing a routine", "during an event chat"),
    "test": ("in a fresh community conversation", "while discussing a different plan", "in a new member's post", "during a live-session recap"),
}


def split_for(group: int) -> str:
    """Assign a whole semantic group to one split, never individual rows."""
    bucket = (group * 37) % 100
    return "train" if bucket < 80 else "validation" if bucket < 90 else "test"


def text_for(policy: str, group: int, split: str) -> str:
    """Create varied, non-graphic examples without split-crossing text."""
    workout = WORKOUTS[group % len(WORKOUTS)]
    audience = AUDIENCES[(group // 5) % len(AUDIENCES)]
    context = SPLIT_CONTEXTS[split][(group // 17) % len(SPLIT_CONTEXTS[split])]
    phrases = {
        "clean": (f"I completed a {workout} and adjusted the pace gradually for {audience}.", f"Rest and hydration helped after my {workout}; sharing the change with {audience}."),
        "toxic": ("That suggestion is useless, and you clearly do not understand the topic.", "Your advice is awful; stop acting like an expert."),
        "harassment": ("I will keep contacting you until you leave this group.", "Reply to me now or I will keep posting about you."),
        "hate_speech": ("People in a protected group should be excluded from this community.", "This post attacks a protected group instead of discussing the topic."),
        "violence": ("I want to physically hurt someone who disagrees with me.", "This argument makes me want to attack the other person."),
        "self_harm": ("I feel unsafe with myself and need immediate support.", "I am overwhelmed and afraid I may hurt myself; I need help."),
        "nsfw": ("Send explicit sexual material to this public fitness thread.", "This caption requests explicit sexual content outside a suitable context."),
        "adult_ungated": ("Mature material was posted publicly without an age gate.", "This adult-oriented discussion belongs behind the platform's mature-content gate."),
        "spam": ("Click example.invalid for instant rewards; this offer is posted everywhere.", "Buy followers today at example.invalid; unrelated bulk promotion."),
        "misinformation": ("This unsupported nutrition claim is guaranteed to work for everyone.", "Ignore evidence-based guidance; this misleading fitness claim is certainly true."),
        "medical_claim": ("This meal plan can cure a medical condition without clinical care.", "This exercise routine diagnoses and treats a health condition by itself."),
        "undisclosed_sponsor": ("Use my affiliate code; I earn commission but have not disclosed it.", "A brand sent me this product and I am promoting it without a clear ad disclosure."),
        "impersonation": ("I am the official account for this gym, although I have no authorization.", "I am posting as a named trainer even though I am not that person."),
        "custom": ("This content needs moderator review under a platform-specific safety rule.", "A non-standard community-rule concern requires manual review."),
    }
    base = phrases[policy][(group // 3) % 2]
    # Split-specific contextual language makes complete utterances disjoint.
    return f"{context.capitalize()}, {base} This relates to {workout} for {audience}."


def label_details(policy: str, index: int) -> tuple[str, str, str, int]:
    if policy == "clean":
        return "approve", "none", "low", 0
    if policy in {"self_harm", "violence"}:
        return "escalate", "safety_risk", "critical", 1
    if policy in {"nsfw", "adult_ungated", "hate_speech"}:
        return "remove", "content_policy", "high", 1
    if policy in {"medical_claim", "misinformation", "undisclosed_sponsor", "impersonation", "custom"}:
        return "flag", "policy_review", "medium" if policy != "medical_claim" else "high", 1
    if policy in {"toxic", "harassment"}:
        return "flag", "abusive_language", "high" if policy == "harassment" else "medium", 1
    return "flag", "commercial_spam", "medium", 1


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, default=Path("data/synthetic/moderation_training_data.csv"))
    parser.add_argument("--rows", type=int, default=DEFAULT_ROWS)
    args = parser.parse_args()
    if args.rows < 1:
        parser.error("--rows must be positive")
    args.output.parent.mkdir(parents=True, exist_ok=True)
    columns = [
        "record_id", "text", "policy_label", "is_violation", "enforcement_action",
        "review_queue", "severity", "label_confidence", "source_type", "locale",
        "dataset_split", "content_hash", "synthetic_variant", "annotation_version",
        "data_provenance", "promotion_eligible",
    ]
    with args.output.open("w", newline="", encoding="utf-8") as handle:
        output = csv.DictWriter(handle, fieldnames=columns, lineterminator="\n")
        output.writeheader()
        for index in range(1, args.rows + 1):
            policy = POLICIES[(index - 1) % len(POLICIES)]
            group = (index - 1) // len(POLICIES)
            split = split_for(group)
            text = text_for(policy, group, split)
            action, queue, severity, violation = label_details(policy, index)
            confidence = 0.99 if policy == "clean" else 0.94 + (index % 6) / 100
            # Variant is intentionally separated from the learning text to avoid
            # leaking a row identity into the model input.
            output.writerow({
                "record_id": f"MOD{index:08d}", "text": text,
                "policy_label": policy, "is_violation": violation,
                "enforcement_action": action, "review_queue": queue,
                "severity": severity, "label_confidence": f"{confidence:.2f}",
                "source_type": SOURCE_TYPES[(index // len(POLICIES)) % len(SOURCE_TYPES)],
                "locale": LOCALES[(group // 31) % len(LOCALES)], "dataset_split": split,
                "content_hash": hashlib.sha256(text.encode("utf-8")).hexdigest(),
                "synthetic_variant": f"v{index:08d}", "annotation_version": "2.0",
                "data_provenance": "synthetic_development_only", "promotion_eligible": "false",
            })
    print(f"Generated {args.rows:,} synthetic moderation records at {args.output}")


if __name__ == "__main__":
    main()
