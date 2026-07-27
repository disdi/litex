# Official RISC-V debug for VexRiscv-SMP (privileged debug / DebugModule).
# DTM is behind JTAG tunnel IR 0x23 — requires riscv use_bscan_tunnel.
# From: https://github.com/enjoy-digital/litex/wiki/JTAG-GDB-Debugging-with-VexRiscv-SMP-NaxRiscv-VexiiRiscv-CPUs

set _CHIPNAME riscv
set _TARGETNAME $_CHIPNAME.cpu
set cpu_count 1
if [info exists env(RISCV_COUNT)] {
    set cpu_count $::env(RISCV_COUNT)
}

if { [info exists TAP_NAME] } {
    set _TAP_NAME $TAP_NAME
} else {
    set _TAP_NAME $_TARGETNAME
}

adapter speed 500

# Direct CPU TAP (sim jtagremote or external PMOD cable)
if {$_TAP_NAME eq $_TARGETNAME} {
    jtag newtap $_CHIPNAME cpu -irlen 6 -ignore-version -expected-id 0x10003fff
}

for {set i 0} {$i < $cpu_count} {incr i} {
    target create $_TARGETNAME.$i riscv -coreid $i -chain-position $_TAP_NAME
    riscv use_bscan_tunnel 6 1
}

for {set i 0} {$i < $cpu_count} {incr i} {
    targets $_TARGETNAME.$i
    init
    halt
}

echo "Ready for Remote Connections"