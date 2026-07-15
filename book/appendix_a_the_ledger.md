# Appendix A · The Ledger at a Glance

<!-- GENERATED FILE — do not edit by hand.
     Regenerate: python verification/tools/book_ledger.py
     Verified current on every build by verification/tools/book_audit.py. -->

Every chapter of this book carries its status tags inline, next to the
claims they qualify. This appendix is the same information turned
inside out: one row per atlas node the book teaches, so you can see the
whole footprint at once — what is proved, what is contracted, what is
open, and exactly where to go to re-check each one. Nothing here is
hand-written. A tool reads the paper's atlas and the chapter registry
and writes this page; the build fails if this page and its sources ever
disagree. Trust the table exactly as far as that sentence licenses, and
no further.

**How to read a row.** *Ledger* is the paper's own status claim
(P proved, D definitional, S implementation conformance, M modeling
postulate, C measurable contract, O open); a dash means the node's
status lives in prose rather than the ledger table. *Proof* is what the
mechanical audit found in the TeX source. *Taught in* lists every
chapter that cites the node. *Witnessed by* is the executable that
re-checks the chapter's claims about it.

| Atlas id | Statement | Ledger | Proof (paper) | Taught in | Witnessed by |
|---|---|---|---|---|---|
| `def:clauses` | Propositional clauses and deciding sets | — | stated no proof | ch04, appb | `lab04_forcing.py`; `python verification/kernel/model_checker.py` |
| `def:closure` | Admissible deciding closure | — | stated no proof | ch05 | `lab05_generics.py` |
| `def:cond` | Conditions | — | stated no proof | ch01, ch02 | `vitest run src/witness`; `lab02_conditions.py` |
| `def:force` | Forcing relations | — | stated no proof | ch04, appb | `lab04_forcing.py`; `python verification/kernel/model_checker.py` |
| `def:refine` | Refinement order and channel-margin subposet | — | stated no proof | ch02, ch06 | `lab02_conditions.py`; `lab06_margin.py` |
| `def:req` | Sieves and dense requirements | — | stated no proof | ch03 | `lab03_topologies.py` |
| `def:site` | Generated admissible site | **D** (definitional) | stated no proof | ch03 | `lab03_topologies.py` |
| `def:stab` | Stability, atomic | — | stated no proof | ch04 | `lab04_forcing.py` |
| `def:transfer` | Transfer | **D** (definitional) | stated no proof | ch07 | `vitest run src/witness -t residues across the medium` |
| `asm:calibration` | Calibration queue | — | stated no proof | ch03, ch04, ch05, ch08, appb | `lab03_topologies.py`; `lab04_forcing.py`; `lab05_generics.py`; `lab08_contract.py`; `python verification/kernel/model_checker.py` |
| `asm:smooth` | Smoothness contract | **C** (contract) | stated no proof | ch02, ch05, ch06, appb | `lab02_conditions.py`; `lab05_generics.py`; `lab06_margin.py`; `python verification/kernel/model_checker.py` |
| `lem:atomic` | Atomic Truth Lemma | **P** (proved) | proved | ch05, appb | `lab05_generics.py`; `python verification/kernel/model_checker.py` |
| `lem:bdd` | Boundedness yields countability for Rasiowa--Sikorski | **P** (proved) | proved | ch05, appb | `lab05_generics.py`; `python verification/kernel/model_checker.py` |
| `lem:bivalence` | Genericity decides every formula | **P** (proved) | proved | ch05 | `lab05_generics.py` |
| `lem:cauchy` | Cauchy--Forcing Completion | **P** (proved) | proved | ch06, appb | `lab06_margin.py`; `python verification/kernel/model_checker.py` |
| `lem:dec` | Deciding sets are order-dense | **P** (proved) | proved | ch04, ch05, appb | `lab04_forcing.py`; `lab05_generics.py`; `python verification/kernel/model_checker.py` |
| `lem:margin` | Channel-Margin, path form | **P** (proved) | proved | ch06, appb | `lab06_margin.py`; `python verification/kernel/model_checker.py` |
| `lem:ordmet` | Order--Metric Compatibility, atomic | **P** (proved) | proved | appb | `python verification/kernel/model_checker.py` |
| `lem:pers` | Persistence and consistency | **P** (proved) | proved | ch04, appb | `lab04_forcing.py`; `python verification/kernel/model_checker.py` |
| `lem:reach` | Decision Reachability, conditional | **P** (proved) | proved | ch04, ch05, ch08, appb | `lab04_forcing.py`; `lab05_generics.py`; `lab08_contract.py`; `python verification/kernel/model_checker.py` |
| `lem:sitebound` | Site bound | **P** (proved) | proved | ch03, ch04, appb | `lab03_topologies.py`; `lab04_forcing.py`; `python verification/kernel/model_checker.py` |
| `lem:void` | The void is the unique shared point | **P** (proved) | proved | ch01, ch07 | `vitest run src/witness`; `vitest run src/witness -t residues across the medium` |
| `prop:chalked` | Chalked correctness invariant | **S** (conformance) | stated no proof | ch07 | `vitest run src/witness -t residues across the medium` |
| `prop:chi` | Exportability identity, under orthogonality | **P** (proved) | proved | ch07, appb | `vitest run src/witness -t residues across the medium`; `python verification/kernel/model_checker.py` |
| `prop:zeroth` | The shared point is forced to zeroth order | **P** (proved) | proved | ch01 | `vitest run src/witness` |
| `thm:factor` | Factoring, architectural | **D** (definitional) | proved | ch01, ch07 | `vitest run src/witness`; `vitest run src/witness -t residues across the medium` |
| `thm:nonid` | Non-identity of transport, with equality condition | **P** (proved) | proved | ch07, ch08, appb | `vitest run src/witness -t residues across the medium`; `lab08_contract.py`; `python verification/kernel/model_checker.py` |
| `thm:prop` | Propositional Truth Lemma, conditional on calibration | **P** (proved) | proved | ch05, appb | `lab05_generics.py`; `python verification/kernel/model_checker.py` |
| `rem:torsion` | Certificate typing is forcing-theoretic---atomic case only | **P** (proved) | n/a | ch04, ch05 | `lab04_forcing.py`; `lab05_generics.py` |

**Footprint.** The book teaches 29 of the paper's 58 atlas nodes. The remaining 29 (2 conjectures, 3 definitions, 2 lemmas, 3 propositions, 17 remarks, 2 theorem_targets) are the paper's own business — mostly remarks and scaffolding the pedagogy does not need. A node absent here is not a claim the book makes silently; it is a claim the book does not make.
