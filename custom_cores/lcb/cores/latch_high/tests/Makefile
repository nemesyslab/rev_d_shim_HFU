-include latch_high_test_setup.txt
SIM ?= verilator
TOPLEVEL_LANG ?= verilog
VERILOG_SOURCES += $(PWD)/../latch_high.v

# Default values for latch_high parameters
WIDTH ?= 32

# Enable waveform dumping for Verilator, ignore warnings and set parameters for DUT, read from latch_high_test_setup.txt
# If the file does not exist, use default values
EXTRA_ARGS += --trace --trace-structs -Wno-fatal --timing \
	-pvalue+WIDTH=$(WIDTH)

latch_high_test:
	$(MAKE) sim MODULE=latch_high_test TOPLEVEL=latch_high

clean_test:
	rm -rf __pycache__ results.xml sim_build dump.vcd latch_high_coverage.xml latch_high_coverage.yaml

include $(shell cocotb-config --makefiles)/Makefile.sim