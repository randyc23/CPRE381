# Control Hazard Avoidance (Part 2c)

Signal names are the ones in `src/RISCV_Processor.vhd`. Stage suffixes: none = combinational output of that stage, `_ID` = IF/ID register, `_EX` = ID/EX, `_MEM` = EX/MEM, `_WB` = MEM/WB.

Design choices (following the assignment's advice):
- **No prediction.** The pipeline keeps fetching PC + 4, which in effect predicts every branch not taken.
- **No delay slots.** Wrong-path instructions are flushed, never executed.

Facts about this datapath the analysis depends on:

- `G_BRANCH_LOGIC` (taken / not taken), `G_ADDER2` (PC + imm) and `G_ALU` (rs1 + imm for jalr) are all in **EX**.
- `Fetch_Ctrl_IF` takes its redirect inputs straight from EX: `s_pcsrc`, `s_add2out`, `s_aluresult`, `s_jump_EX` and `s_jumpreg_EX`. So the PC changes at the clock edge that **ends the EX cycle** of the branch or jump.
- Branch and jalr operands go through the forwarding muxes (`s_rs1_fwd_EX`, `s_rs2_fwd_EX`), so the decision always uses current values. Load-use stalls are handled by part (b) before the branch reaches EX.

## i. Instructions that may update the PC non-sequentially

| Instructions | When the PC is not PC + 4 | Detected in | Signals that decide it | New PC (signal) | PC updated at |
|---|---|---|---|---|---|
| beq, bne, blt, bge, bltu, bgeu | condition true | **EX** | `s_branch_EX`, `s_Inst_EX[14:12]`, `s_rs1_fwd_EX`, `s_rs2_fwd_EX` → `G_BRANCH_LOGIC` → `s_pcsrc` | `s_add2out` = `s_PC_EX` + `s_immgen_EX` | end of EX |
| jal | always | **EX** | `s_jump_EX` | `s_add2out` = `s_PC_EX` + `s_immgen_EX` | end of EX |
| jalr | always | **EX** | `s_jumpreg_EX` | `s_aluresult` & ~1 = (`s_rs1_fwd_EX` + imm) & ~1 (`jalr_target` in `Fetch_Ctrl_IF`) | end of EX |
| wfi (halt) | always: PC stops | **WB** | `s_Halt` (= `s_Halt_WB` out of `G_WB`) | PC holds (stall through `G_PC_STALL`) | when wfi reaches WB |

Notes:
- **wfi** doesn't redirect fetch; it freezes it. The instructions behind it in the pipeline are never written back in a way that matters, because the testbench stops on `s_Halt`. So wfi needs **no flush**, only the PC stall it already has.
- **jal** needs no register, so it *could* be resolved in ID for a 1-cycle penalty. It's resolved in EX like the others to keep a single redirect point. The trade-off is listed below.
- Every other instruction (R-type, I-type, loads, stores, lui, auipc) always continues at PC + 4.

## ii. Stages to stall and to squash, relative to the instruction's stage

The control instruction (call it **C**) is in **EX** when its outcome is known.

| C, in EX | PC | IF/ID (holds C+2, from PC+8) | ID/EX (gets C+1, from PC+4) | EX/MEM (gets C) | MEM/WB | Stalls | Penalty |
|---|---|---|---|---|---|---|---|
| branch, **taken** | load target (`s_add2out`) | **flush** | **flush** | normal | normal | none | 2 cycles |
| branch, not taken | PC + 4 (normal) | normal | normal | normal | normal | none | 0 |
| jal | load target (`s_add2out`) | **flush** | **flush** | normal | normal | none | 2 cycles |
| jalr | load target (`s_aluresult` & ~1) | **flush** | **flush** | normal | normal | none | 2 cycles |
| wfi (in WB) | **stall** | — | — | — | — | PC | — (program ends) |

Relative to C:
- the stage **1 behind** C (ID, which holds C+1) is squashed by flushing **ID/EX**;
- the stage **2 behind** C (IF, which holds C+2) is squashed by flushing **IF/ID**.

C itself and everything ahead of it continue normally. No stage needs to be *stalled* for a control hazard, because the target and the decision are both ready at the end of EX.

### Pipeline timing for a taken branch

| Cycle | 1 | 2 | 3 | 4 | 5 | 6 |
|---|---|---|---|---|---|---|
| `beq` (taken) | IF | ID | **EX** | MEM | WB | |
| C+1 (PC + 4) | | IF | ID | *bubble* | *bubble* | *bubble* |
| C+2 (PC + 8) | | | IF | *bubble* | *bubble* | *bubble* |
| target | | | | IF | ID | EX |

At the end of cycle 3:
- PC ← target
- IF/ID ← nop (flush)
- ID/EX ← nop and zeroed control (flush)
- EX/MEM ← the beq

The flushed instructions have `RegWr = 0`, `DMemWr = 0`, `branch = jump = jumpreg = 0` and `halt = 0`, so they can't write anything, redirect fetch or stop the processor.

## iii. Generalized list: every control case by stage

For each instruction that can change the PC, what the hazard logic must do while that instruction is in each stage:

| Instruction ↓ / its stage → | IF | ID | EX | MEM | WB |
|---|---|---|---|---|---|
| branch (taken) | — | — | **redirect PC; flush IF/ID, ID/EX** | — | — |
| branch (not taken) | — | — | — | — | — |
| jal | — | — | **redirect PC; flush IF/ID, ID/EX** | — | — |
| jalr | — | — | **redirect PC; flush IF/ID, ID/EX** | — | — |
| wfi | — | — | — | — | **stall PC** |

How control and data hazard actions combine:

| Situation | Result |
|---|---|
| Branch or jalr that depends on a load immediately before it | Part (b) load-use stall happens first: PC and IF/ID hold, ID/EX gets a bubble. Next cycle the branch is in EX with forwarded operands and resolves normally. |
| Load-use stall and taken branch in the same cycle | **Can't happen.** Both need their instruction in EX in the same cycle (a load for load-use, the branch for the redirect). |
| Flush and stall on the same register | Flush wins (`WE = not stall or flush`). Kept as a safety net. |
| Taken branch with a wfi on the wrong path (C+1 or C+2) | The wfi is flushed before WB, so `s_Halt` never fires. |
| wfi in WB while a younger branch is in EX | PC stays stalled; nothing after the wfi matters. |

## iv. Values each stage must keep for control hazard avoidance

| Stage register | Values needed | Needed for | New? |
|---|---|---|---|
| IF/ID | `s_PC_ID`, `s_Inst_ID` | target adder input and branch fields later | no |
| ID/EX | `s_branch_EX`, `s_jump_EX`, `s_jumpreg_EX`, `s_PC_EX`, `s_immgen_EX`, `s_Inst_EX[14:12]` (funct3), rs1/rs2 (forwarded in EX) | deciding and computing the redirect in EX | no |
| ID/EX | `s_Halt_EX` → … → `s_Halt_WB` | wfi stops the PC from WB | no |
| EX/MEM | `pcsrc`, `add2out`, `jump`, `jumpreg` | **no longer needed.** They still travel through EX/MEM but nothing in MEM reads them, so they can be removed. | can remove |

New combinational signals:

| Signal | Stage | Meaning |
|---|---|---|
| `s_ctrl_taken` | EX | `s_pcsrc + s_jump_EX + s_jumpreg_EX` |
| `s_IF_ID_flush` | (from EX) | squash the instruction in IF (C+2) |
| `s_ID_EX_flush` | (from EX/ID) | squash the instruction in ID (C+1) **or** insert the load-use bubble |

## v. Logic equations

```
ctrl_taken  = pcsrc_EX + jump_EX + jumpreg_EX           (pcsrc = branch_EX · condition)

PC_stall    = Halt_WB + loadUse
IF_ID_stall = loadUse
IF_ID_flush = ctrl_taken
ID_EX_flush = ctrl_taken + loadUse
ID_EX_stall = EX_MEM_stall = EX_MEM_flush = MEM_WB_stall = MEM_WB_flush = PC_flush = 0

PC_next     = jumpreg_EX            ? (aluresult & ~1)
            : (jump_EX + pcsrc_EX)  ? add2out
            :                         PC + 4             (Fetch_Ctrl_IF, unchanged)
```

These are implemented in `src/Hazard/hazard_detection.vhd`, which now also takes `i_pcsrc_EX`, `i_jump_EX` and `i_jumpreg_EX`. `RISCV_Processor.vhd` already computes `s_ctrl_taken` itself and drives the IF/ID and ID/EX flushes from it. Once the hazard unit is wired in, its outputs replace those two assignments.

### Testing

`test/tb_hazard_detection.vhd` adds control cases to the load-use cases:
- taken branch, jal and jalr each flush IF/ID and ID/EX without stalling;
- not-taken branch does nothing;
- `ID_EX_flush` is the OR of load-use and ctrl_taken.

For the full processor:
- the unscheduled `Proj1_mergesort.s` and `grendel.s` should match RARS with no NOPs added;
- the `_sw` versions should still pass, because their extra NOPs are flushed or run harmlessly.

### Performance

- Each taken branch, jal or jalr costs **2 cycles**; not-taken branches cost nothing.
- The longest path is now in EX: forwarding mux → ALU / branch compare → `Fetch_Ctrl_IF` muxes → PC.
- Options for later, if CPI matters more than clock period:
  - resolve jal in ID (1-cycle penalty, no new data hazards);
  - move branches to ID (1-cycle penalty, but new branch stalls; see the earlier trade-off discussion);
  - add a branch predictor.
