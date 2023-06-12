# ARVES

Another RISC-V Educational Softcore written in VHDL for fun and education.

## Motivation

Some time ago, I was playing in [nandgame](https://nandgame.com) where you need to build your own processor and some low-level software for it.
I was so “vibing” with that game, so after I've finished it, I decided to try to implement some “real” CPU in some “real” tooling.
So here we are…

## Architectural decisions

Before diving into implementation, I took several key decisions I never should change:

- One cycle instructions. Any machine instruction must take exactly one clock cycle in order to execute.
- No optimizations. We all know about pipe lining, buffer registers, out-of-order execution and so on and so forth. In order to simplify the implementation, I decided to have sequential in-order execution.
- Harvard's architecture. Another key decision that mostly driven by “one cycle instructions”, because we can't have simultaneous access to data and instruction buses in the von Neumann architecture. Hence, data and instruction memories and their buses are separate units.

So, as you see, the important key point here is—simplicity. Simplicity in the implementation itself, the minimum required for the core to operate, but simple enough to understand the core principles behind how it works.

## How to run?

In order to run the CPU and give it some program, you need to make the following:

### Compiling the program

I've implemented the base “I” extension here, so the target for your toolchain must be RV32I.
The resulting machine code (hex dump) must be saved to the file “firmware.hex” separated by one byte in big-endian order.

Here is an example of a program:

```asm
.global _boot
.text

_boot:                    /* x0  = 0    0x000 */
    /* Test ADDI */
    addi x1 , x0,   1000  /* x1  = 1000 0x3E8 */
    addi x2 , x1,   2000  /* x2  = 3000 0xBB8 */
    addi x3 , x2,  -1000  /* x3  = 2000 0x7D0 */
    addi x4 , x3,  -2000  /* x4  = 0    0x000 */
    addi x5 , x4,   1000  /* x5  = 1000 0x3E8 */
```

Compiled via RISC-V assembler to RV32I and formatted in a way I described above and stored in the file “firmware.hex”:

```text
3e
80
00
93
7d
00
81
13
c1
81
01
93
83
01
82
13
3e
82
02
93
```

### Running the simulation

I'm using the open source VHDL simulator GHDL.
Having the firmware in “firmware.hex” file, you can analyze and run the simulation via ghdl:

```shell
ghdl analyze -fsynopsys rtl/*.vhdl
ghdl run -fsynopsys soc_tb --wave=wave.ghw
```

After the simulation you will get the file “wave.ghw” where you will find the waveform of your CPU signals and can investigate all the data and inner workings of the CPU.

## Components

The system itself comprises several components that are responsible for executing RISC-V instructions or gluing together other components.

### ALU (Arithmetic Logic Unit)

[📝](rtl/alu.vhdl)

It is responsible for making arithmetic and logic operations.
The most simple component of all here.
It is just a combinatorial circuit that accepts inputs to determine the type of calculation to perform and operands to operate on.
The result of the operation is passed to the output for other components to get.

![Arithmetic Logic Unit](https://github.com/ghaiklor/type-challenges-solutions/assets/3625244/4b380de0-0ec7-4da4-86ba-7f1aebc42a1d)

### Register File

[📝](rtl/register_file.vhdl)

This one is a stateful component that is responsible for storing the state of the CPU.
It has 32 registers named x0-x32.
There are some inputs that allow to choose what register to activate for read or write and the data buses to pass data in or out.

![Register File](https://github.com/ghaiklor/type-challenges-solutions/assets/3625244/77552d4c-7e04-4cc7-8704-2fb93bdb3d31)

### Decoder

[📝](rtl/decoder.vhdl)

While the ALU and Register File can operate in a vacuum, but those are the components that are hidden from the developer.
However, what the developer has is RISC-V machine instructions that he can use to communicate with the machine and tell her what to do.

The responsibility of the decoder is to decode the machine instruction and set other components of the system in the desired state to perform the expected operation.

E.g., when passed the RISC-V instruction to add two numbers together, the decoder sets the ALU in the state of adding two numbers; the register file in the state that gives those operands to the ALU; sets the register where the result must be stored in the write mode.

![Decoder](https://github.com/ghaiklor/type-challenges-solutions/assets/3625244/bb688d3b-bb45-415f-9bea-86bc7e94c4b3)

### Hart

[📝](rtl/hart.vhdl)

In the RISC-V terminology, hart is “hardware thread” or how I'd like to call it “just a core”.
It is the component that glues together the decoder, ALU, Register File and other components like RAM or ROM via data and instruction buses.

It does nothing specific, just combines different components of the system in the proper way so all of them work in sync with each other.

If you want to get started unraveling the logic behind the system here, hart is the most appropriate place to begin with.

![Hart](https://github.com/ghaiklor/type-challenges-solutions/assets/3625244/b4a85139-f330-4b95-aace-080b5d18b44e)

### ROM

[📝](rtl/rom.vhdl)

Read-Only Memory made here to have a place where machine instructions can be stored.
The only interface here is an address of the instruction and the instruction bus to send the instruction over the wire out from memory.

![Read Only Memory](https://github.com/ghaiklor/type-challenges-solutions/assets/3625244/ec07665e-bea7-4860-932d-1bb53d874038)

### Program Counter

[📝](rtl/program_counter.vhdl)

Since Read-Only Memory requires knowing at which address the machine instruction must be fetched, we need to place where we can store the address of the instruction.
That's the responsibility of the program counter component.
It is the register in the processor, but not like the usual registers x0-x32, but with the specific meaning – it always stores the address of the current instruction to execute and nothing else.

![Program Counter](https://github.com/ghaiklor/type-challenges-solutions/assets/3625244/fe8f8ed9-d40f-4f06-88c2-78181a750cda)

### RAM

[📝](rtl/ram.vhdl)

When the CPU is working, it requires not only the machine instructions to know what to do, but also the place where it can store the results of operations – data.

That's what Random Access Memory is for.
Its interface has an address for choosing the active cell we work with and control buses to choose the mode we are operating in: read mode or write mode.

![Random Access Memory](https://github.com/ghaiklor/type-challenges-solutions/assets/3625244/03858798-a77a-44fe-87c2-2cf5ed465470)

### SoC

[📝](rtl/soc.vhdl)

Putting all these harts, read-only memory and random access memory together, we could name it SoC (System on Chip).
It is the place where data and instruction buses combines and wires the hart and instruction memory and data memory.

It has no outputs because it is the top-level entity that only accepts the drivers like clock signal and reset signal to set the system in the initial state.
Yes, this implementation has no I/O at all.

![System on Chip](https://github.com/ghaiklor/type-challenges-solutions/assets/3625244/f24fd817-6820-4f25-becb-9034e8345b22)
