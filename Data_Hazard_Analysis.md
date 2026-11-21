# Data Hazard Avoidance (Part 2b)

Signal names are the ones in `src/RISCV_Processor.vhd`. Stage suffixes: none = IF/ID-stage combinational output, `_ID` = IF/ID register, `_EX` = ID/EX, `_MEM` = EX/MEM, `_WB` = MEM/WB.

Facts about this datapath that the analysis depends on:

- The register file writes on the **falling edge**, so an instruction in ID reads a value WB writes in the same cycle. Distance-3 dependencies need nothing.
- Branch compare (`G_BRANCH_LOGIC`) and the jalr target (`G_ALU`) are computed in **EX**, so branches and jalr consume registers in EX like any ALU instruction.
- Taken branches and jumps **redirect fetch from EX**: `s_pcsrc`, `s_add2out`, `s_aluresult`, `s_jump_EX` and `s_jumpreg_EX` go straight to `G_IF`. `s_ctrl_taken = s_pcsrc + s_jump_EX + s_jumpreg_EX` flushes IF/ID and ID/EX, so the penalty is 2 cycles (it was 3 when the redirect came from EX/MEM).
- DMem is read and written in **MEM**; load data (`s_Ld_Data`) exists only at the end of MEM.
- The full instruction travels down the pipe (`s_Inst_ID/_EX/_MEM/_WB`), so rs1 = `[19:15]`, rs2 = `[24:20]`, rd = `[11:7]` are available in every stage.

## i. Instructions that produce values

| Instructions | Value produced | Signals carrying it, by stage | Destination address |
|---|---|---|---|
| R-type: add, sub, and, or, xor, sll, srl, sra, slt, sltu | ALU result | EX: `s_aluresult` → MEM: `s_aluresult_MEM` (also `s_DMemAddr`) → WB: `s_aluresult_WB` → `s_RegWrData` | `s_Inst_EX[11:7]`, `s_Inst_MEM[11:7]`, `s_Inst_WB[11:7]` = `s_RegWrAddr` |
| I-type ALU: addi, andi, ori, xori, slti, sltiu, slli, srli, srai | ALU result | same as R-type | same |
| lui (ALU A = 0) | imm | same as R-type | same |
| auipc (ALU A = PC) | PC + imm | same as R-type | same |
| Loads: lb, lh, lw, lbu, lhu | memory data | MEM: `s_DMemOut` → `G_MEM/GLOAD` → `s_Ld_Data` → WB: `s_Ld_Data_WB` → `s_RegWrData` | same |
| jal, jalr | PC + 4 (link) | IF: `s_PCplus4` → `s_PCplus4_ID` → `s_PCplus4_EX` → `s_PCplus4_MEM` → `s_PCplus4_WB` → `s_RegWrData` | same |
| Stores: sb, sh, sw | memory word | MEM: `s_DMemData`, `s_DMemAddr`, `s_DMemBE`, `s_DMemWr` → DMem | (memory, not a register) |

Notes:
- The link value (PC+4) is known from IF onward, so it can be forwarded from any stage.
- Stores produce memory values, but they never cause a pipeline hazard. Loads and stores both access DMem only in MEM, in program order, so a `sw` is always finished before a later `lw` reads.
- Branches and wfi produce nothing (`RegWr = 0`).

## ii. Instructions that consume values

| Instructions | Operand | Where it is consumed | Signals |
|---|---|---|---|
| R-type | rs1, rs2 | EX, ALU | `s_rd1_EX` → `G_MUX4T1_ALUA` D0; `s_rd2_EX` → `G_MUX2T1_ALUB` D0 |
| I-type ALU | rs1 | EX, ALU | `s_rd1_EX` → `G_MUX4T1_ALUA` D0 |
| Loads | rs1 (address) | EX, ALU | `s_rd1_EX` → ALU → `s_aluresult_MEM` = `s_DMemAddr` |
| Stores | rs1 (address) | EX, ALU | as loads |
| Stores | **rs2 (data)** | **MEM**, DMem write data | `s_rd2_EX` → `s_rd2_MEM` → `GSTORE` → `s_DMemData` |
| Branches | rs1, rs2 | EX, compare | `s_rd1_EX`, `s_rd2_EX` → `G_BRANCH_LOGIC` i_A / i_B (result `s_pcsrc` → `Fetch_Ctrl_IF`) |
| jalr | rs1 | EX, ALU (target) | `s_rd1_EX` → ALU → `s_aluresult` → `Fetch_Ctrl_IF` |
| lui, auipc, jal, wfi | none | — | bits [24:15] are immediate bits, not registers |

All operands are first read in ID (`G_REG_FILE` → `s_rd1`, `s_rd2`) and latched into ID/EX. That ID read is never wrong for distance ≥ 3 because of the write-before-read register file.

**The store edge case:** a store consumes rs2 in a *later* stage (MEM) than it consumes rs1 (EX). The data operand can therefore arrive one cycle later than the address operand. That is what lets a `lw x5; sw x5, 0(x6)` pair run without a stall (see iii).

## iii. Generalized dependencies

Distance *d* = how many instructions after the producer the consumer is (1 = back-to-back). If a consumer is in stage S and its producer is *d* instructions ahead, the producer is *d* stages further down the pipe in the same cycle.

### N: producing signals (from i)

| # | Signal | Stage it sits in | Instructions that put a result on it |
|---|---|---|---|
| P1 | `s_aluresult` | EX | R-type, I-ALU, lui, auipc |
| P2 | `s_PCplus4_EX` | EX | jal, jalr (link) |
| P3 | `s_aluresult_MEM` | MEM (EX/MEM) | R-type, I-ALU, lui, auipc |
| P4 | `s_PCplus4_MEM` | MEM (EX/MEM) | jal, jalr |
| P5 | `s_Ld_Data` | MEM (after DMem + `GLOAD`) | lb, lh, lw, lbu, lhu |
| P6 | `s_aluresult_WB` | WB (MEM/WB) | R-type, I-ALU, lui, auipc |
| P7 | `s_Ld_Data_WB` | WB (MEM/WB) | loads |
| P8 | `s_PCplus4_WB` | WB (MEM/WB) | jal, jalr |
| P9 | `s_RegWrData` | WB (`GMUX2` output) | all of P6–P8, selected by Mem2Reg and andlink |

### M: consuming signals (from ii)

| # | Signal | Stage | Consumed by |
|---|---|---|---|
| C1 | `s_rd1_EX` → `G_MUX4T1_ALUA` D0 | EX | R-type, I-ALU, load/store address, jalr |
| C2 | `s_rd1_EX` → `G_BRANCH_LOGIC` i_A | EX | branches |
| C3 | `s_rd2_EX` → `G_MUX2T1_ALUB` D0 | EX | R-type |
| C4 | `s_rd2_EX` → `G_BRANCH_LOGIC` i_B | EX | branches |
| C5 | `s_rd2_EX` → EX `o_rd2` → EX/MEM | EX | store data (latched) |
| C6 | `s_rd2_MEM` → `GSTORE` i_data | MEM | store data (used) |
| C7 | `G_REG_FILE` reads → `s_rd1`, `s_rd2` | ID | every instruction with rs1/rs2 |

### N × M matrix

Each cell says what happens when the producer and consumer are in those stages in the same cycle.

| Producer ↓ / Consumer → | C1 | C2 | C3 | C4 | C5 | C6 | C7 |
|---|---|---|---|---|---|---|---|
| P1 `s_aluresult` (EX) | — | — | — | — | — | — | L (d=1) |
| P2 `s_PCplus4_EX` (EX) | — | — | — | — | — | — | L (d=1) |
| P3 `s_aluresult_MEM` | **FM** | **FM** | **FM** | **FM** | **FM** | — | L (d=2) |
| P4 `s_PCplus4_MEM` | **FM** | **FM** | **FM** | **FM** | **FM** | — | L (d=2) |
| P5 `s_Ld_Data` (MEM) | **S** | **S** | **S** | **S** | D | — | L (d=2) |
| P6 `s_aluresult_WB` | FW | FW | FW | FW | FW | FWM | RF (d=3) |
| P7 `s_Ld_Data_WB` | FW | FW | FW | FW | FW | FWM | RF (d=3) |
| P8 `s_PCplus4_WB` | FW | FW | FW | FW | FW | FWM | RF (d=3) |
| P9 `s_RegWrData` | FW | FW | FW | FW | FW | FWM | RF (d=3) |

| Code | Meaning | Forwarded from → to |
|---|---|---|
| **FM** | Forward, d = 1. `ForwardA/B = "10"`; the value is `s_fwd_MEM` = andlink ? `s_PCplus4_MEM` : `s_aluresult_MEM` | EX/MEM (MEM stage) → EX |
| FW | Forward, d = 2. `ForwardA/B = "01"`; the value is `s_RegWrData` (P6–P8 all reach EX through P9) | MEM/WB (WB stage) → EX |
| FWM | Forward store data, d = 1. `ForwardM = '1'`; the value is `s_RegWrData` | MEM/WB (WB stage) → MEM |
| **S** | **Stall 1 cycle** (load-use): the load data doesn't exist until the end of MEM. After the bubble it becomes FW. | — |
| D | Deferred. The store latches a stale value into EX/MEM, which is fine because C6 fixes it the next cycle with FWM. So no stall. | — |
| RF | No hardware needed. The register file writes on the falling edge, so the ID read gets the new value (d = 3). | — |
| L | The ID read latches a stale value into ID/EX, which is fine because the same dependency becomes FM, FW or S once the consumer reaches EX. | — |
| — | Not a RAW dependency: either the same instruction, or the producer is behind the consumer (d ≤ 0). | — |

Every cell assumes the producer has RegWrite = 1 and rd ≠ x0, and that rd matches the consumer's rs1 (C1, C2) or rs2 (C3–C6). If any of those fails, there's no dependency.

**Memory pair (not a register dependency):** a store produces `s_DMemData`, and a load consumes `s_DMemOut`. Both happen only in MEM, in program order, so a store is always finished before a later load reads. That pair is never a hazard.

### Forwarded dependencies

These are the FM, FW and FWM cells of the matrix.

| Path | From stage → to stage | Value | Used for |
|---|---|---|---|
| ForwardA/B = "10" | EX/MEM → EX | `s_andlink_MEM ? s_PCplus4_MEM : s_aluresult_MEM` | d = 1 from ALU-type, lui, auipc, jal, jalr |
| ForwardA/B = "01" | MEM/WB → EX | `s_RegWrData` | d = 2 from anything that writes rd, including loads |
| ForwardM = '1' | MEM/WB → MEM | `s_RegWrData` | load → store **data**, d = 1 |

### Dependencies that need a stall

Only one, the **S** cells (P5 × C1–C4): a **load followed immediately by an instruction that uses the loaded register in EX**. That covers the operands of R-type, I-type, branch and jalr, plus the *address* (rs1) of a load or store. One bubble is inserted, and then the MEM/WB → EX path supplies the value.

Not stalled:
- load → store **data** (handled by ForwardM)
- anything with rd = x0
- instructions whose bits [24:15] are an immediate (lui, auipc, jal)

## iv. Values each stage must keep for hazard detection and forwarding

| Stage register | Already carried | Needed for | New? |
|---|---|---|---|
| IF/ID | `s_Inst_ID` (rs1 `[19:15]`, rs2 `[24:20]`, opcode) | hazard detection (which registers ID will use) | no |
| ID/EX | `s_Inst_EX` (rs1, rs2, rd), `s_memread_EX` | forwarding unit (rs1/rs2 of the consumer); hazard detection (load in EX + its rd) | no |
| EX/MEM | `s_Inst_MEM` (rd, rs2), `s_RegWr_MEM`, `s_memread_MEM`, `s_DMemWr_MEM`, `s_andlink_MEM`, `s_PCplus4_MEM`, `s_aluresult_MEM` | forwarding source; blocks forwarding a load; ForwardM (store + its rs2) | no |
| MEM/WB | `s_Inst_WB` (rd), `s_RegWr_WB`, `s_RegWrData` | forwarding source for EX and MEM | no |

Because the whole instruction word and every control bit are already pipelined, **no new pipeline register fields are needed**.

The new *combinational* signals to add to the signal map are:

| Signal | Stage | Width | Meaning |
|---|---|---|---|
| `s_ForwardA`, `s_ForwardB` | EX | 2 | forwarding mux selects for rs1 / rs2 |
| `s_rs1_fwd_EX`, `s_rs2_fwd_EX` | EX | 32 | forwarded rs1 / rs2 (replace `s_rd1_EX` / `s_rd2_EX` at the ALU muxes, branch logic and EX `i_rd2` → EX/MEM) |
| `s_fwd_MEM` | MEM | 32 | `s_andlink_MEM ? s_PCplus4_MEM : s_aluresult_MEM` |
| `s_ForwardM` | MEM | 1 | store-data forwarding select |
| `s_rd2_fwd_MEM` | MEM | 32 | forwarded store data into `GSTORE` |
| `s_load_use` | ID | 1 | stall request: drives `s_PC_stall`, `s_IF_ID_stall`, `s_ID_EX_flush` |

## v. Logic equations

Let `rdM = s_Inst_MEM[11:7]`, `rdW = s_Inst_WB[11:7]`, `rs1E = s_Inst_EX[19:15]`, `rs2E = s_Inst_EX[24:20]`, `rs2M = s_Inst_MEM[24:20]`, `rdE = s_Inst_EX[11:7]`, `rs1D = s_Inst_ID[19:15]`, `rs2D = s_Inst_ID[24:20]`.

**Forwarding unit** (`src/Hazard/forwarding_unit.vhd`):

```
memValid = RegWr_MEM · ¬MemRd_MEM · (rdM ≠ 0)
wbValid  = RegWr_WB · (rdW ≠ 0)

ForwardA = "10" if memValid · (rdM = rs1E)
           "01" else if wbValid · (rdW = rs1E)
           "00" otherwise                      (ForwardB: same with rs2E)

ForwardM = DMemWr_MEM · wbValid · (rdW = rs2M)
```

EX/MEM is checked first, so the most recent producer wins when both stages write the same register. `¬MemRd_MEM` stops a load's address from being forwarded as if it were data.

**Hazard detection unit** (`src/Hazard/hazard_detection.vhd`):

```
usesRs1 = opcode ∈ {R-type, I-ALU, load, store, branch, jalr}
usesRs2 = opcode ∈ {R-type, branch}          (store rs2 excluded: ForwardM)

loadUse = MemRd_EX · (rdE ≠ 0) · [ usesRs1·(rdE = rs1D) + usesRs2·(rdE = rs2D) ]

PC_stall = IF_ID_stall = ID_EX_flush = loadUse
```

Compared with the Zybook 4.7 equations, this adds:
- the jal/jalr link value as a forwarding source;
- blocking EX/MEM forwarding when it holds a load;
- the MEM-stage store-data path;
- opcode gating, so immediate bits are never mistaken for a register number.

### Testing (not integrated, per the assignment)

| Testbench | Covers |
|---|---|
| `test/tb_forwarding_unit.vhd` | 20 directed cases (each path, EX/MEM priority, x0, RegWr = 0, load in EX/MEM, jal link, every ForwardM condition), plus 2000 random cases checked against a reference model |
| `test/tb_hazard_detection.vhd` | 18 instruction pairs: load-use on rs1/rs2, I-type immediate that looks like a register, load/store address vs. store data, branch, jalr, jal/lui/auipc/wfi, x0, non-load in EX |

### Integration later (part c / final datapath)

1. In EX, put a 3:1 forwarding mux in front of each operand. The rs1 mux feeds `G_MUX4T1_ALUA` D0 and `G_BRANCH_LOGIC` i_A. The rs2 mux feeds `G_MUX2T1_ALUB` D0, `G_BRANCH_LOGIC` i_B and EX `o_rd2`.
2. In MEM, put a 2:1 mux on `GSTORE` i_data, selected by ForwardM.
3. Drive `s_PC_stall` and `s_IF_ID_stall` from `loadUse`, and set `s_ID_EX_flush = loadUse + s_ctrl_taken` (the control flush is already wired). A load-use stall and a taken branch can't happen in the same cycle, because both need their instruction in EX. Even if they did, flush has priority over stall in every register.
