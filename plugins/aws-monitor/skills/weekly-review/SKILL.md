---
name: weekly-review
description: Compare AWS spend trends and measure optimization impact
invoke: manual
---

# Weekly Review

Compare last 7 days vs previous 7 days to measure whether cost optimizations are working.

## Workflow

1. **Get current period data**:
   - Call `waste_report` and `bedrock_spend` with default dates (last 7 days)
   - Note total waste, Bedrock spend, and breakdown by category

2. **Get previous period data**:
   - Call `waste_report` with `days=14` to get 14-day totals
   - Call `bedrock_spend` with appropriate date range for comparison
   - Subtract current period from 14-day totals to get previous week

3. **Calculate trends**:
   - Waste reduction: Did cold cache rewrites or 150K+ sessions decrease?
   - Spend change: Is total Bedrock spend up or down?
   - Impact: If changes were made (from optimize-setup), did they help?

4. **Report findings**:
   - Absolute dollars saved or spent
   - Percentage changes
   - Specific improvements (e.g., "Cold cache waste down 40%")
   - Recommendations for next week

## Example output

```
Week over week comparison:
- Total Bedrock: $45 → $32 (29% reduction)
- Cold cache waste: $12 → $5 (58% reduction)
- Subagent spend: $18 → $14 (22% reduction)
- 150K+ sessions: 3 → 1

Impact: Disabling unused MCP servers saved ~$8/week
```
