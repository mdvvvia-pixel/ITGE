# First Principles Framework (FPF) — Compact Guide for AI Reasoning

**Source:** FPF-Spec.md by Anatoly Levenchuk et al., December 2025

This is a compact operational guide (~4k tokens) for applying FPF principles to structured thinking and problem-solving.

---

## 1. What is FPF?

FPF is an **operating system for thought** — a pattern language for constructing and evolving ideas with:
- **Auditability** — every claim traces back to evidence
- **Evolvability** — continuous improvement without chaos
- **Creativity** — systematic generation of novel hypotheses
- **Cross-scale coherence** — same logic from component to system-of-systems

**Key insight:** FPF treats creativity as **governed search** and assurance as **repeatable reckoning**. Both work together for responsible innovation.

---

## 2. The Eleven Pillars (Constitutional Invariants)

Every artifact, decision, and pattern must honor these:

| ID | Pillar | Essence |
|----|--------|---------|
| **P-1** | Cognitive Elegance | Highlight decisive structure, eliminate ornamental formalism |
| **P-2** | Didactic Primacy | Human comprehension outranks theoretical purity |
| **P-3** | Scalable Formality | Single artifact matures step-by-step from informal to formal |
| **P-4** | Open-Ended Kernel | Core contains only meta-concepts; domains live in architheories |
| **P-5** | Plug-in Layering | Extensions are modular, replaceable without destabilizing core |
| **P-6** | Lexical Stratification | Every concept expressible in 4 registers: plain/technical/formal/symbol |
| **P-7** | Pragmatic Utility | Real-world objectives matter; falsification over confirmation |
| **P-8** | Cross-Scale Consistency | Composition rules work the same at all scales |
| **P-9** | State Explicitness | Every artifact declares its state; transitions are traceable |
| **P-10** | Open-Ended Evolution | Everything can evolve indefinitely; cycles must be cheap and safe |
| **P-11** | SoTA Alignment | Track reliable contemporary knowledge; update when SoTA advances |

**Precedence:** Gov > Arch > Epist > Prag > Did

---

## 3. Strict Distinction — The Clarity Lattice (A.7)

Prevents category errors that corrupt reasoning:

### 3.1 Role vs Function
- **Role** = contextual position/mask a system can bear (e.g., CoolingCirculatorRole)
- **Function/Behavior** = what a system actually does when bearing a role (Method → Work)

**Guard:** Use "Role" for the mask; "Method/Work" for behavior. Role ≠ function.

### 3.2 MethodDescription vs Method vs Work
- **MethodDescription** = design-time description (algorithm, SOP, recipe)
- **Method** = order-sensitive capability the system can enact
- **Work** = dated run-time occurrence (what actually happened)

**Guard:** Never use MethodDescription as evidence of Work.

### 3.3 System vs Episteme
- **System** = the only holon kind that can bear behavioral roles and enact Work
- **Episteme** = knowledge content; cannot act; changed via carriers by a system

**Guard:** "The document decided..." is a violation. Documents don't decide; systems do.

### 3.4 Episteme vs Carrier
- **Episteme** = knowledge content (claim, model, requirement)
- **Carrier** = physical/digital sign that carries the episteme (file, dataset)

**Guard:** When you say "we updated the spec", specify which carriers changed.

### 3.5 I/D/S Layers (not "planes")

Three-layer stratification with a formal gate between D and S:

| Layer | Type | What it is |
|-------|------|------------|
| **I (Intension)** | Non-epistemic | The thing itself (U.Role, U.Method). Does NOT contain documents or checklists |
| **D (Description)** | Epistemic KU | Context-local characterization: labels, glosses, RCS/RSG, checklists |
| **S (Specification)** | Epistemic KU | Testable invariants bound to acceptance harness |

**Spec-gate:** Use "-Spec" suffix ONLY when ALL conditions hold:
1. Formality F ≥ F4 (checkable predicates)
2. Verifiable invariants stated
3. Linked acceptance harness (SCR/RSCR)
4. Explicit context anchoring

If any condition fails → must be "-Description", not "-Spec".

**Guard:** I/D/S layers are orthogonal to publication surfaces (PlainView, TechCard, AssuranceLane).

---

## 4. Trust & Assurance Calculus — F-G-R (B.3)

Every claim has an **assurance tuple**: `⟨F_eff, G_eff, R_eff, Notes⟩`

### 4.1 The Core Characteristics

**Node characteristics (on holons):**

| Char | Meaning | Scale | Direction |
|------|---------|-------|-----------|
| **F (Formality)** | How constrained by proof-grade structure | Ordinal F0-F3 | Higher = better |
| **G (ClaimScope)** | How broadly the result applies | Coverage/span | Larger = better |
| **R (Reliability)** | How likely the claim holds | Ratio [0,1] | Higher = better |

**Derived scores (from TA/VA/LA):**

| Score | Source | Meaning |
|-------|--------|---------|
| **FV (Formal Verifiability)** | VA | Strength of logical/formal verification |
| **EV (Empirical Validability)** | LA | Strength of real-world testing evidence |

**Edge characteristic — CL (Congruence Level):** how well two parts fit:
- CL0 = weak guess
- CL1 = plausible mapping
- CL2 = validated mapping
- CL3 = verified equivalence

### 4.2 Universal Aggregation Rules

1. **F_eff = min(F_i)** — weakest link caps formality
2. **G_eff = SpanUnion constrained by support** — only supported scope counts
3. **R_eff = max(0, min(R_i) − Φ(CL_min))** — reliability penalized by worst integration

**Key insight:** Poor integration (low CL) destroys R even if parts are individually strong.

### 4.3 Assurance Subtypes (TA/VA/LA)

Three pillars of trust — each answers a different question:

| Subtype | Code | Question | Improves |
|---------|------|----------|----------|
| **Typing Assurance** | TA | "Does artifact faithfully represent its concept?" | CL (Congruence) |
| **Verification Assurance** | VA | "Is it logically correct under stated assumptions?" | FV (Formal Verifiability) |
| **Validation Assurance** | LA | "Does it work correctly in the real world?" | EV (Empirical Validability) |

### 4.4 Assurance Levels (Computed)

Levels are **derived from evidence**, not assigned manually:

| Level | Name | Criteria |
|-------|------|----------|
| **L0** | Unsubstantiated | No `verifiedBy` or `validatedBy` evidence |
| **L1** | Substantiated | At least one evidence link + Typing Assurance (TA) |
| **L2** | Axiomatic | Verified by proof OR Γₘ constructive narrative; FV ≥ threshold; for safety-critical: also requires LA |

**Key insight:** You cannot reach L2 by validation alone — formal verification (VA) is required.

---

## 5. Canonical Reasoning Cycle — ADI Loop (B.5)

The cognitive engine: **Abduction → Deduction → Induction**

### 5.1 Abduction (Hypothesis Generation)
- **Question:** "What is the most plausible new explanation?"
- **Action:** Propose a new hypothesis (conjecture). Creates L0 artifact.
- **This is where innovation happens.**

### 5.2 Deduction (Consequence Derivation)
- **Question:** "If this hypothesis is true, what logically follows?"
- **Action:** Derive testable predictions. Find contradictions.
- **Raises F (Formality) and prepares falsifiable claims.**

### 5.3 Induction (Empirical Evaluation)
- **Question:** "Do the predicted consequences match reality?"
- **Action:** Test against evidence. Corroborate or refute.
- **Raises R (Reliability) based on evidence.**

### 5.4 Development States

| State | Activity | Reasoning Phase | Assurance |
|-------|----------|-----------------|-----------|
| **Explore** | Generate possibilities | Abduction | L0 |
| **Shape** | Define coherent form | Deduction | L0→L1 |
| **Evidence** | Test against reality | Induction | L1→L2 |
| **Operate** | Use in production | - | L2 |

---

## 6. Holonic Foundation (A.1)

Everything is a **holon** — simultaneously a whole and a part of a larger whole.

### 6.1 Types of Holons
- **U.System** — can act, bear behavioral roles, enact Work
- **U.Episteme** — knowledge; cannot act; is used by systems

### 6.2 Bounded Context (A.1.1)
- Local CWA (Closed World Assumption) island
- Within a context: specific models, rules, invariants are authoritative
- Crossing contexts requires Bridges with CL penalties

---

## 7. Role–Method–Work Alignment (A.15)

The quartet that connects intention to action:

```
System (in TransformerRole)
    ↓ uses
MethodDescription (design-time recipe)
    ↓ describes
Method (capability)
    ↓ enacted as
Work (run-time occurrence)
```

**External Transformer Principle (A.12):** Every change is performed by an external system bearing TransformerRole. No "self-magic" — systems don't modify themselves without an external transformer.

---

## 8. Aggregation Algebra — Γ (B.1)

Conservative composition with invariants:

| Γ-flavor | What it composes |
|----------|------------------|
| Γ_sys | System properties (physical, conservation laws) |
| Γ_epist | Knowledge artifacts (provenance, trust) |
| Γ_method | Methods (order-sensitive composition) |
| Γ_work | Resource spend (costs, time) |
| Γ_time | Temporal histories |

**Invariant Quintet:**
- **IDEM** — idempotence where applicable
- **COMM/LOC** — commutativity or locality
- **WLNK** — weakest-link (aggregate ≤ weakest part)
- **MONO** — monotonicity (more evidence can't reduce assurance)

---

## 9. Bitter Lesson Preference (BLP) — E.2

When lawful approaches compete, prefer:
1. **General methods** over domain-specific heuristics
2. **Compute/data-scalable** over hand-tuned
3. **Rules-as-prohibitions (RoC)** over step-by-step scripts (IoP)

**RoC = Rule of Constraints:** Declare what must NOT happen and what budgets apply; let agents choose HOW to act within bounds.

**Heuristic Debt:** Any admitted hand-tuned rule must be registered with expiry and replacement plan.

---

## 10. Evidence & Traceability (A.10)

Every claim must be traceable to evidence via:

- **SCR (Symbol-Carrier Register)** — tracks physical carriers of epistemes
- **RSCR** — for remote/distributed sets
- **Evidence Graph** — DAG linking claims to supporting evidence

**Guard:** A claim without evidence anchor is L0 (Unsubstantiated). For decisions, it is not trusted.

---

## 11. Design-Time vs Run-Time (A.4)

Strict separation to prevent "chimeras":

| Design-Time | Run-Time |
|-------------|----------|
| MethodDescription | Work |
| WorkPlan | Actual execution |
| Specification | Observation |

**Guard:** Never compose design-time assurance with run-time evidence into a single score.

---

## 12. Creativity Architecture (C.17-C.19)

Not a black box — structured creative generation:

### 12.1 NQD Characteristics
- **Novelty** — is it new?
- **Quality/Use-Value** — is it useful?
- **Diversity** — does it expand the solution space?
- **ConstraintFit** — does it satisfy non-negotiable constraints?

### 12.2 Explore-Exploit Governor (E/E-LOG)
- Declare exploration quotas
- Define selection lenses
- Policy governs when to roam vs. when to focus

### 12.3 Creative Abduction with NQD (B.5.2.1)
- Generate hypothesis portfolio
- Score on NQD dimensions
- Select Pareto-optimal candidates

---

## 13. Practical Application Checklist

When reasoning about any problem:

### Before Acting
- [ ] What is the **Bounded Context**? What assumptions are authoritative?
- [ ] What **Role** am I (or the system) playing?
- [ ] Is this **design-time** (planning) or **run-time** (execution)?

### During Analysis
- [ ] Am I confusing **MethodDescription** with **Work**?
- [ ] Am I treating an **episteme** as if it can act?
- [ ] What is the **F-G-R** tuple for my claims?
- [ ] Where are the **evidence anchors**?

### For Decisions
- [ ] Have I done **Abduction** first (generated hypothesis)?
- [ ] Have I done **Deduction** (derived consequences)?
- [ ] Have I done **Induction** (tested against evidence)?
- [ ] Is my reasoning traceable via **DRR** (Design-Rationale Record)?

### For Integration
- [ ] What is the **CL** (Congruence Level) between parts?
- [ ] Does **WLNK** (weakest-link) apply?
- [ ] Are **Cross-context bridges** needed? What CL penalty?

---

## 14. Anti-Patterns to Avoid

| Anti-Pattern | What It Looks Like | FPF Prevention |
|--------------|-------------------|----------------|
| **Agency Misplacement** | "The document decided..." | A.7: Only systems can act |
| **Plan-Reality Conflation** | Using specs as evidence of work | A.4: Strict design/run split |
| **Trust Inflation** | Averaging heterogeneous quality scores | B.3: WLNK, proper aggregation |
| **Premature Convergence** | Skipping hypothesis generation | B.5: Abductive primacy |
| **Scope Drift** | Mixing design and run-time assurance | B.3: Separate tuples |
| **Category Collapse** | "Process" meaning method, work, and role | A.7: Clarity Lattice |

---

## 15. Key Terms Quick Reference

| Term | Meaning |
|------|---------|
| **Holon** | Part-whole unit; can be System or Episteme |
| **System** | Holon that can act and bear behavioral roles |
| **Episteme** | Knowledge content; cannot act |
| **Carrier** | Physical/digital sign carrying an episteme |
| **Role** | Contextual position/mask |
| **Method** | Capability to be enacted |
| **Work** | Actual run-time occurrence |
| **F-G-R** | Formality, ClaimScope, Reliability |
| **CL** | Congruence Level (integration quality) |
| **TA/VA/LA** | Typing/Verification/Validation Assurance |
| **FV/EV** | Formal Verifiability / Empirical Validability |
| **L0/L1/L2** | Unsubstantiated / Substantiated / Axiomatic |
| **Γ** | Aggregation operator family |
| **DRR** | Design-Rationale Record |
| **SCR** | Symbol-Carrier Register |
| **RoC** | Rule of Constraints (prohibitions over scripts) |
| **ADI** | Abduction-Deduction-Induction cycle |
| **NQD** | Novelty-Quality-Diversity |
| **I/D/S** | Intension / Description / Specification layers |
| **Spec-gate** | Formal criteria for using "-Spec" suffix |

---

## 16. Summary: FPF in One Paragraph

FPF is a structured framework for rigorous thinking that separates **what things are** (System vs Episteme), **what they do** (Role → Method → Work), and **how we know** (F-G-R assurance with evidence trails). It mandates **Abduction-first reasoning** (propose hypotheses before testing), **conservative aggregation** (weakest-link bounds), and **design/run-time separation** (plans ≠ evidence). Every claim must trace to evidence, every change must have a transformer, and every crossing between contexts must account for congruence loss. The result is thinking that is auditable, evolvable, and systematically creative.
