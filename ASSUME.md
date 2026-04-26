# assume(spec) for Black

Black's reflective tower lets any level modify the evaluator below it via `EM` — `eval` is havoc. This adds a verification gate: modifications must pass a spec check before installation.

## The mechanism

`examples/assume.blk` — loaded at the meta-level — provides `modify-base-apply!`, which takes a **guard** and a **handler**:

```scheme
(modify-base-apply! guard handler)
```

This wraps `base-apply` with a new case:

```scheme
(lambda (operator operand env cont)
  (if (guard operator)
      (handler operator operand env cont)
      (original operator operand env cont)))
```

Before installing, it checks that the guard is **disjoint** from all cases where the original `base-apply` succeeds. It tests the guard against witness values — a host procedure (`+`) and a closure (`(list lambda-tag ...)`). If the guard fires on any witness, the modification is rejected.

This is the `havoc; assume(spec); install` pattern:
- **havoc**: someone (human or LLM) produces a guard + handler
- **assume(spec)**: `disjoint-guard?` checks the guard against witnesses
- **install**: `set!` on `base-apply` only if the check passes

## Files

- `examples/assume.blk` — the gate mechanism (`apply-witnesses`, `disjoint-guard?`, `modify-base-apply!`)
- `examples/multn-checked.blk` — the multn modification through the gate (accepted)
- `examples/bad-checked.blk` — a bad modification through the gate (rejected)

## Session

```
$ cd black && echo '...' | chez --quiet

0-1> (+ 1 2)
0-1: 3

0-2> (exec-at-metalevel (load "examples/assume.blk"))
0-2: done

0-3> (exec-at-metalevel (load "examples/multn-checked.blk"))
INSTALLED (guard is disjoint)
0-3: done

0-4> (2 3 4)
0-4: 24

0-5> (+ 1 2)
0-5: 3

0-6> (exec-at-metalevel (load "examples/bad-checked.blk"))
  CONFLICT: guard fires on existing case
REJECTED (guard overlaps)
0-6: done

0-7> (+ 1 2)
0-7: 3
```

## Why it's sound (informally)

`base-apply` dispatches on the operator:
1. `(procedure? operator)` → handle as primitive or host function
2. `(pair? operator) ∧ (car operator) = lambda-tag` → handle as closure
3. else → error

If a guard is disjoint from cases 1 and 2 — the guard returns `#f` for any procedure and any closure — then the wrapped function's `else` branch (the original) handles all previously-successful cases identically. The new guard only fires on values that would have errored. Old behavior is preserved.

The Lean formalization (`lean-black/`) aims to prove this argument: disjointness of the guard is *sufficient* for conservative extension.

## Limitations

- The witness list is finite — it covers the two structural cases (`procedure?` and `lambda-tag`) but a richer evaluator might have more. The check is sound only if the witnesses cover all success cases.
- The guard is tested pointwise on witnesses, not proved universally. A guard that happens to return `#f` on `+` but `#t` on `-` would pass the check but violate conservative extension. A more thorough version would test against all primitives, or use a type-level argument.
- This is behavioral checking, not formal verification. The Lean proof would close the gap.
