SHELL                   := $(shell which bash) -o pipefail
ABS_TOP                 := $(shell pwd)

SIM_RTL                 := $(shell find $(ABS_TOP)/sim -type f -name "*.sv")
SIM_TARGETS             := $(shell realpath --relative-to $(ABS_TOP) $(SIM_RTL))

VCS                     := /share/instsww/synopsys-new/vcs/Y-2026.03-SP1/bin/vcs -full64
VERDI_HOME              := /share/instsww/synopsys-new/verdi/Y-2026.03-SP1
VCS_OPTS                := -notice -line +lint=all,noVCDE,noNS,noSVA-UA -sverilog -timescale=1ns/1ps -debug_access+all -kdb +vcs+fsdbon
VCS_TARGETS             := $(SIM_TARGETS:%.sv=%.fsdb)
IVERILOG                := iverilog
IVERILOG_OPTS           := -D IVERILOG=1 -g2012 -gassertions -Wall -Wno-timescale
IVERILOG_TARGETS        := $(SIM_TARGETS:%.sv=%.fst)
VVP                     := vvp
RTL						:= $(ABS_TOP)/src/d_flip_flop.sv

.PHONY: FORCE

sim/%.tb: sim/%.sv FORCE
	cd sim && $(VCS) $(VCS_OPTS) -o $*.tb $*.sv $(RTL) ../src/$(patsubst %_tb.sv,%.sv,$(notdir $<))

# special case where one tb depends on two sources
sim/decoder_4_to_16_tb.tb: sim/decoder_4_to_16_tb.sv FORCE
	cd sim && $(VCS) $(VCS_OPTS) -o decoder_4_to_16_tb.tb decoder_4_to_16_tb.sv $(RTL) ../src/line_decoder.sv ../src/$(patsubst %_tb.sv,%.sv,$(notdir $<))
# 	$(VPD2FSDB) decoder_4_to_16_tb.vpd -o decoder_4_to_16_tb.fsdb

$(VCS_TARGETS): sim/%.fsdb: sim/%.tb FORCE
	cd sim && ./$*.tb +verbose=1 +fsdbfile+$*.fsdb

sim/%.vvp: sim/%.sv FORCE
	cd sim && $(IVERILOG) $(IVERILOG_OPTS) -o $*.vvp $*.sv $(RTL) ../src/$(patsubst %_tb.sv,%.sv,$(notdir $<))

# special case where one tb depends on two sources
sim/decoder_4_to_16_tb.vvp: sim/decoder_4_to_16_tb.sv FORCE
	cd sim && $(IVERILOG) $(IVERILOG_OPTS) -o decoder_4_to_16_tb.vvp decoder_4_to_16_tb.sv $(RTL) ../src/line_decoder.sv ../src/$(patsubst %_tb.sv,%.sv,$(notdir $<))

$(IVERILOG_TARGETS): sim/%.fst: sim/%.vvp FORCE
	cd sim && $(VVP) -n $*.vvp -fst

sim-all: $(IVERILOG_TARGETS)

sim-all-vcs: 
	make sim/one_bit_comparator_structural_tb.fsdb 
	make sim/one_bit_comparator_behavioral_tb.fsdb 
	make sim/one_bit_comparator_always_tb.fsdb 
	make sim/four_bit_comparator_always_tb.fsdb 
	make sim/shift_register_structural_tb.fsdb 
	make sim/shift_register_behavioral_tb.fsdb 
	make sim/simple_counter_tb.fsdb 
	make sim/decoder_4_to_16_tb.fsdb 

clean: FORCE
	rm -rf ./build $(junk) *.daidir sim/output.txt \
	sim/*.tb sim/*.daidir sim/csrc \
	sim/ucli.key sim/*.vpd sim/*.vcd \
	sim/*.tbi sim/*.fst sim/*.jou sim/*.log sim/*.out \
	sim/*.fsdb sim/*.vvp
