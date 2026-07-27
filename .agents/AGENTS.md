# Project-Scoped Rules & Behavioral Constraints

## Compulsory Systematic Debugging
- **RULE**: For any error or crash that is not a trivial syntax error, it is compulsory to use the Systematic Bugfix Skill (`.agents/skills/systematic_bugfixes/SKILL.md`) before attempting a fix. You must map out the component flow, identify precisely where the state breaks, and formulate a root-cause hypothesis instead of blindly guessing or immediately generating code.

## Typography Rule
- **RULE**: The app strictly uses a 3-font system via local `.ttf` files:
  - **Space Grotesk**: Used for big headings (e.g., Display, Headline).
  - **DM Sans**: Used for section headings, medium text, and buttons (e.g., Title, Label).
  - **DM Mono**: Used for general/body text (e.g., Body, small prints).
- **ENFORCEMENT**: When generating UI code or updating themes, always apply these fonts according to their respective textual hierarchy.
