# Project-Scoped Rules & Behavioral Constraints

## Version Upgrade Enforcement for Main Branch Merges
- **RULE**: Any pull request or merge into the `main` (or `master`) branch MUST include a version upgrade in `pubspec.yaml` (e.g., bumping `version: 1.0.0+1` to `1.0.1+2` or higher).
- **ENFORCEMENT**: Before creating a commit or merging to main, verify that the `version` field in `pubspec.yaml` has been incremented compared to the target branch. Never merge without bumping the app version.
