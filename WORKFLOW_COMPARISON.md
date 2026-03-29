# Traditional Workflow vs targets Pipeline

This document compares the traditional R workflow with the new targets-based pipeline.

## Traditional Workflow (00_main.R)

### How it works:
```r
source('00_main.R')
main()
```

### Characteristics:
- ✓ Simple, single function call
- ✓ Interactive prompts guide the user
- ✗ **Runs everything from scratch every time**
- ✗ **No caching** - even unchanged steps are re-executed
- ✗ **Long wait times** for large datasets
- ✗ Manual user input required (not suitable for batch processing)
- ✗ Hard to debug intermediate steps
- ✗ Difficult to parallelize
- ✗ Results lost if script crashes mid-way

### Example execution time:
```
Total: ~30-60 minutes for medium dataset
- Import & cleanup:        5 min
- Taxonomic assignment:    10 min  ← Re-runs even if data unchanged
- Classification:          15 min  ← Re-runs even if data unchanged
- Clustering:              10 min  ← Re-runs even if data unchanged
- Visualization:           5 min   ← Re-runs even if data unchanged
```

## targets Pipeline Workflow

### How it works:
```bash
Rscript run_targets.R
```

Or from R:
```r
library(targets)
tar_make()
```

### Characteristics:
- ✓ **Automatic caching** - only re-runs changed steps
- ✓ **Fast re-runs** - leverage cached results
- ✓ **Resume from failures** - doesn't lose progress
- ✓ **Reproducible** - same inputs = same outputs
- ✓ **Parallel execution** - can run independent steps simultaneously
- ✓ **Visual pipeline** - see dependencies at a glance
- ✓ **Easy debugging** - inspect any intermediate result
- ✓ **Batch processing friendly** - no manual prompts
- ✓ **Documented dependencies** - clear what depends on what
- ✗ Requires learning targets concepts (small learning curve)

### Example execution time (after initial run):

**Scenario 1: Only visualization changed**
```
Total: ~30 seconds
- Import & cleanup:        SKIPPED (cached)
- Taxonomic assignment:    SKIPPED (cached)
- Classification:          SKIPPED (cached)
- Clustering:              SKIPPED (cached)
- Visualization:           30 sec  ← Only this runs
```

**Scenario 2: Added new clade information**
```
Total: ~10 minutes
- Import & cleanup:        SKIPPED (cached)
- Taxonomic assignment:    SKIPPED (cached)
- Classification:          SKIPPED (cached)
- Clade addition:          5 min   ← Runs
- Clustering:              5 min   ← Runs (depends on clade data)
- Visualization:           30 sec  ← Runs (depends on clustering)
```

**Scenario 3: New FASTA file**
```
Total: ~30-60 minutes (same as traditional)
- All steps run (as expected with new data)
```

## Reproducibility Comparison

### Traditional Approach

**Problem:** Hard to reproduce results months later
```r
# What version of data was used?
# What parameters were set?
# Which intermediate files are still valid?
# Did the script complete successfully?
```

**Solution:** Manual documentation, careful file naming
- Requires discipline
- Error-prone
- Time-consuming

### targets Approach

**Built-in reproducibility:**
```r
# Automatic tracking of:
# - When each step was run
# - What code version was used
# - What inputs produced what outputs
# - Which results are still valid

# View pipeline history
tar_meta()

# Reproduce exact results
tar_make()  # Skips unchanged steps
```

## Debugging Comparison

### Traditional Approach

```r
# To debug step 5 of 10:
# 1. Run steps 1-4 (wait 20 min)
# 2. Debug step 5
# 3. Make changes
# 4. Run steps 1-5 again (wait 25 min)
# 5. Repeat until fixed
```

### targets Approach

```r
# To debug step 5 of 10:
tar_load(step_4_output)  # Load cached input instantly
# Debug step 5 with real data
# Make changes
tar_make()  # Only re-runs step 5 and downstream (1 min)
```

## Parallel Execution

### Traditional Approach
- Sequential only
- Must manually manage parallelization
- Complex to implement

### targets Approach
```r
# Automatic parallel execution (if configured)
tar_make_clustermq(workers = 4)
# Or
tar_make_future(workers = 4)

# Runs independent steps simultaneously
# Example: While getting classification for batch 1,
#          can start clustering batch 2
```

## Collaboration Benefits

### Traditional Approach
```
Colleague: "Can you re-run the analysis with updated data?"
You: "Sure, it will take 45 minutes"
```

### targets Approach
```
Colleague: "Can you re-run with updated data?"
You: "Done - only the affected steps ran, took 3 minutes"
```

## When to Use Each Approach

### Use Traditional (00_main.R) when:
- ✓ First time running the analysis
- ✓ Want to explore the pipeline interactively
- ✓ Need to understand what each step does
- ✓ Running once and don't need to repeat
- ✓ Very small dataset (< 5 minute total runtime)

### Use targets Pipeline when:
- ✓ Running analysis multiple times
- ✓ Working with large datasets (> 10 minute runtime)
- ✓ Need reproducible results
- ✓ Collaborating with others
- ✓ Publishing research (reviewers may request re-runs)
- ✓ Automating analysis (batch processing)
- ✓ Need to debug specific steps
- ✓ Want to parallelize computation

## Migration Path

You can easily switch between approaches:

```r
# Start with traditional to explore:
source('00_main.R')
main()

# Then switch to targets for efficiency:
Rscript run_targets.R

# Both use the same underlying functions!
# The targets pipeline just adds:
# - Dependency tracking
# - Caching
# - Pipeline management
```

## Summary

| Feature | Traditional | targets |
|---------|-------------|---------|
| Initial setup | Easy | Medium |
| First run time | 30-60 min | 30-60 min |
| Subsequent runs | 30-60 min | 1-10 min |
| Reproducibility | Manual | Automatic |
| Debugging | Slow | Fast |
| Collaboration | Difficult | Easy |
| Batch processing | Hard | Easy |
| Learning curve | Low | Medium |
| **Best for** | **Exploration** | **Production** |

## Recommendation

1. **Learning phase**: Use traditional workflow to understand the analysis
2. **Production phase**: Switch to targets for efficiency and reproducibility
3. **Publishing research**: Definitely use targets for reproducible research

The targets pipeline doesn't replace the traditional workflow - it enhances it with modern reproducibility features!
