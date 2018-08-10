============================================================================
SHA-3 proposal BLAKE v2
Authors: Jean-Philippe Aumasson, Luca Henzen, Willi Meier, Raphael C.-W. Phan
Date: December 13, 2010

PUBLIC VHDL CODE v2
============================================================================

http://131002.net/blake/

----------------------------------------------------------------------------
tree
.
|-- readme.txt
|-- simvectors
|   |-- blake256_expresp_1G.asc
|   |-- blake256_expresp_1Gh.asc
|   |-- blake256_expresp_4G.asc
|   |-- blake256_expresp_8G.asc
|   |-- blake256_stimuli_1G.asc
|   |-- blake256_stimuli_1Gh.asc
|   |-- blake256_stimuli_4G.asc
|   |-- blake256_stimuli_8G.asc
|   |-- blake512_expresp_1G.asc
|   |-- blake512_expresp_1Gh.asc
|   |-- blake512_expresp_4G.asc
|   |-- blake512_expresp_8G.asc
|   |-- blake512_stimuli_1G.asc
|   |-- blake512_stimuli_1Gh.asc
|   |-- blake512_stimuli_4G.asc
|   `-- blake512_stimuli_8G.asc
`-- sourcecode
    |-- 1Gcore
    |   |-- blake.vhd
    |   |-- blake256Pkg.vhd
    |   |-- blake512Pkg.vhd
    |   |-- controller.vhd
    |   |-- gcomp256.vhd
    |   |-- gcomp512.vhd
    |   `-- roundreg.vhd
    |-- 1Ghcore
    |   |-- blake.vhd
    |   |-- blake256Pkg.vhd
    |   |-- blake512Pkg.vhd
    |   |-- controller.vhd
    |   |-- hgcomp256.vhd
    |   |-- hgcomp512.vhd
    |   `-- roundreg.vhd
    |-- 4Gcore
    |   |-- blake.vhd
    |   |-- blake256Pkg.vhd
    |   |-- blake512Pkg.vhd
    |   |-- controller.vhd
    |   |-- gcomp256.vhd
    |   |-- gcomp512.vhd
    |   `-- roundreg.vhd
    |-- 8Gcore
    |   |-- blake.vhd
    |   |-- blake256Pkg.vhd
    |   |-- blake512Pkg.vhd
    |   |-- controller.vhd
    |   |-- gcomp256.vhd
    |   |-- gcomp512.vhd
    |   `-- roundreg.vhd
    |-- finalization.vhd
    `-- initialization.vhd

6 directories, 50 files

----------------------------------------------------------------------------

ARCHITECTURES:

The 'sourcecode' directory contains the vhdl code of the four architectures described in Sec. 3.2 (BLAKE-256/512).
The 8G, 4G, 1G, and 1Gh cores investigates the hardware efficiency of the BLAKE compression function by
reducing the number of implemented G modules and further by modifying the structure of a single G function.   
 
----------------------------------------------------------------------------

TEST VECTORS:

The 'simvectors' directory contains the test vectors and the expected responses of the BLAKE compression function
for the four implementations.

The sequence of test vectors is:
1.      All-zeros {message (MxDI), chain value (HxDI), salt (SxDI), counter (TxDI)}- input set,
2.      All-ones  {message (MxDI), chain value (HxDI), salt (SxDI), counter (TxDI)}- input set,
3.      Appendix C, One-block {message (MxDI), chain value (HxDI), salt (SxDI), counter (TxDI)}- set,
4...53. Random {message (MxDI), chain value (HxDI), salt (SxDI), counter (TxDI)}- input set.

In total, every stimuli file contains 53 test message blocks.

!!!! Although, InEnxSI is asserted for only one clock cycle, MxDI, HxDI, SxDI, and TxDI must by kept constant as inputs until the hash value is computed !!!!


The structure of the stimuli files is:

|Reset Signals (active low)
|
| |InEnxSI 
| |
| | |MxDI
| | |        |HxDI
| | |        |        |SxDI
| | |        |        |        |TxDI
| | |        |        |        |
0 0 000...00 000...00 000...00 000...00
0 0 000...00 000...00 000...00 000...00
1 0 000...00 000...00 000...00 000...00
1 0 000...00 000...00 000...00 000...00
1 1 XXX...XX XXX...XX XXX...XX XXX...XX
1 0 XXX...XX XXX...XX XXX...XX XXX...XX
. . ........ ........ ........ ........
. . ........ ........ ........ ........
. . ........ ........ ........ ........
