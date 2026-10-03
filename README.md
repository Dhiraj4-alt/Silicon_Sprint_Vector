# Silicon Sprint — 4-Requester Round-Robin Arbiter

A synthesizable **4-requester round-robin arbiter** implemented in Verilog-2001 for the Silicon Sprint VLSI Hackathon.

The design uses a **2-bit priority pointer** to maintain arbitration order and provides fair access to continuously requesting clients.

## Features

- 4 requesters
- One-hot or zero grant
- `grant_valid` output
- 2-bit round-robin priority pointer
- Circular arbitration with wrap-around
- Dynamic request handling
- Fairness for persistent requests
- Active-low asynchronous reset
- Initial priority: requester 0
- Pure synthesizable Verilog-2001
- Self-checking verification testbench

## Architecture

The arbiter searches requesters in circular order starting from the current priority:

```text
Priority 0: 0 → 1 → 2 → 3
Priority 1: 1 → 2 → 3 → 0
Priority 2: 2 → 3 → 0 → 1
Priority 3: 3 → 0 → 1 → 2

After a successful grant, priority moves to the requester immediately following the granted requester. If no request is active, the priority remains unchanged.

##Verification

Simulation was performed using Icarus Verilog:

iverilog -g2001 -o arbiter_sim rr_arbiter.v tb_rr_arbiter.v
vvp arbiter_sim

###Result:

========================================
     SILICON SPRINT VERIFICATION
========================================
Tests  : 53
Errors : 0
RESULT : PASS
========================================

The testbench covers reset, single and multiple requests, persistent requests, dynamic patterns, withdrawal, wrap-around, fairness, and illegal grant conditions.

##Yosys Synthesis

####RTL was analyzed using:

yosys -p "read_verilog rr_arbiter.v; hierarchy -top rr_arbiter; proc; opt; check; stat"

####Yosys reported:

Found and reported 0 problems.

Synthesis Statistics

Metric	Result

Wires	66
Wire bits	141
Public wires	9
Public wire bits	20
Memories	0
Processes	0
Cells	61
$adffe	1
$mux	48
$pmux	3


The complete raw Yosys output is available in:

yosys_synthesis_output.txt

##Project Structure
'''
Silicon_Sprint_Vector/
├── rr_arbiter.v
├── tb_rr_arbiter.v
├── README.md
└── yosys_synthesis_output.txt
'''
###Tools

Verilog-2001

Icarus Verilog

Yosys

Git / GitHub

Ubuntu Linux


###Status

RTL: Complete
Simulation: 53 tests / 0 errors / PASS
Yosys Check: 0 problems
Synthesis Statistics: Generated
