# Software-Scheduled Pipeline: Test Programs

Files: `Proj2_mergesort_sw.s`, `grendel_sw.s` (originals left untouched).

## Hazard rules for this datapath

| Hazard | Rule | Why |
|---|---|---|
| Data (any RAW, including load-use) | consumer must be at least 3 instructions after the producer → **max 2 NOPs** | no forwarding; register file writes on the falling edge (G_REG_CLK), so ID can read a value in the same cycle WB writes it |
| Control (every branch, `j`, `jal`, `jalr`/`ret`) | **exactly 3 NOPs** after it | PC is redirected from EX/MEM values, so the 3 instructions behind it are always fetched and executed (no flush) |

Delay slots must be NOPs: anything else would execute in hardware but not in RARS, and the toolflow compares register and memory writes against RARS (writes to x0 are ignored, so NOPs are free).

`wfi` must stay the **last instruction** in the file. In the toolflow's RARS, `wfi` doesn't halt anything; the program ends only by "dropping off the bottom."

## Verification

Both programs were assembled with `RARS_CPRE3810.jar` and checked with a cycle model of this pipeline (no forwarding, 3 always-executed slots, write-before-read register file):

| Program | Result | RARS trace vs. pipeline model | Single-cycle instructions (original) | Pipeline cycles (scheduled) |
|---|---|---|---|---|
| mergesort | `[-42, -5, -1, 0, 3, 8, 17, 17, 21, 34, 56, 99]`, s0 = 1 | 760 / 760 writes identical | 1347 | ~1841 |
| grendel | `res = [3, 0, 2, 1]` | 1644 / 1644 writes identical | 2129 | ~3475 |

With a 5-stage clock period roughly ¼–⅕ of the single-cycle period, both programs finish faster than on the single-cycle design.

## Scheduling techniques used

- **`la` split into `lui %hi` / `addi %lo`** with independent instructions between the two halves (instead of `lasw`, whose NOPs can't be filled).
- **Hoisting** dead-temporary work above branches, e.g. `add t2, a1, a2` and `sw ra, -4(sp)` above `blt` in `mergesort`, and `lw t4, 24(fp)` above `beq` in grendel's `trucks`/`new`.
- **Old-sp addressing:** frame stores use offsets from the old `sp`, before `addi sp`, so they don't wait on the new `sp`.
- **Tail call:** `mergesort` restores `ra` and does `j merge`, so `merge`'s `ret` returns straight to mergesort's caller. This removes a `jal`, its 3 NOPs, a `ret` and its 3 NOPs per call.
- **Do-while loops** (branch at the bottom) in `merge`, the check loop, and grendel's `look`/`example`/`justify`. This removes a `j` and its 3 NOPs per iteration.
- **`beq …; j X` → `bne … X`** in grendel. This removes a jump and its 3 NOPs.
- **`la ra, L; j F; L:` → `jal ra, F`** in grendel.
- **Software-pipelined loads** in `merge`: the next element is loaded in the same block that stores the current one.

## Waveform guide (mergesort)

Signals to add: `iCLK`, `s_PC`, `s_Inst`, `s_Inst_ID`, `s_Inst_EX`, `s_Inst_MEM`, `s_Inst_WB`, `s_RegWr`, `s_RegWrAddr`, `s_RegWrData`, `s_DMemWr`, `s_DMemAddr`, `s_DMemData`, `s_Halt`.

**Two recursions:** `mergesort` starts at `0x00400038`. Find the first two times `s_PC = 0x00400038`: the call from `main` (`j` at `0x00400028`) and the first recursive `jal` at `0x0040006c`. In WB you should see `sw ra/a1/a2/t2` hit DMem at `sp-4 … sp-16`, `sp` drop by 16 (`s_RegWrAddr = 2`), and `a2` take the new midpoint.

**Examples where fewer than the maximum NOPs were needed:**

1. **Data flow, 0 NOPs instead of 2:** `merge` setup at `0x004000c8`. `lui t6, %hi(temp)` is followed by two independent `slli` (`0x004000cc`, `0x004000d0`), so `addi t6, t6, %lo(temp)` at `0x004000d4` is already 3 instructions behind its producer. Show `lui` in WB in the same cycle the `addi` is in ID.
2. **Data flow, 0 NOPs instead of 2:** take-left block at `0x00400110`. `addi a4, a4, 4` → `sw t4` → `addi a6` → `lw t4, 0(a4)` (`0x0040011c`). The two unrelated instructions fill the load's dependency gap.
3. **Control flow, 0 NOPs before the branch instead of 2:** `blt t0, a1, MS_RET` at `0x00400044` depends on `addi t0, a2, -2` at `0x00400038`. `add t2, a1, a2` and `sw ra, -4(sp)` were moved above the branch to fill the gap. Both are harmless if the branch is taken.
4. **Control flow, a jump's NOPs also cover a data hazard:** `addi sp, sp, -16` (`0x00400068`) is directly before `jal ra, mergesort`. The callee's `sw ra, -4(sp)` reads `sp` 7 instructions later, so it needs no extra data NOPs. The 3 jump NOPs already provide the distance.
