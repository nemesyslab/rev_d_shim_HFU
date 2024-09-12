# 'make' builds everything
# 'make clean' deletes everything except source files and Makefile
#
# You need to set NAME, PART and PROC for your project.
# NAME is the base name for most of the generated files.

NAME = led_blinker
PART = xc7z010clg400-1
PROC = ps7_cortexa9_0

FILES = $(wildcard projects/$(NAME)/cores/*.v)
CORES = $(FILES:projects/$(NAME)/%.v=%)

VIVADO = vivado -nolog -nojournal -mode batch
XSCT = xsct
RM = rm -rf

.PRECIOUS: tmp/cores/% tmp/%.xpr tmp/%.xsa tmp/%.bit

all: tmp/$(NAME).bit boot.bin boot-rootfs.bin

cores: $(addprefix tmp/, $(CORES))

xpr: tmp/$(NAME).xpr

bit: tmp/$(NAME).bit

tmp/cores/%: cores/%.v
	mkdir -p $(@D)
	$(VIVADO) -source scripts/core.tcl -tclargs $* $(PART)

tmp/%.xpr: projects/% $(addprefix tmp/, $(CORES))
	mkdir -p $(@D)
	$(VIVADO) -source scripts/project.tcl -tclargs $* $(PART)

tmp/%.xsa: tmp/%.xpr
	mkdir -p $(@D)
	$(VIVADO) -source scripts/hwdef.tcl -tclargs $*

tmp/%.bit: tmp/%.xpr
	mkdir -p $(@D)
	$(VIVADO) -source scripts/bitstream.tcl -tclargs $*

clean:
	$(RM) tmp
	$(RM) .Xil
