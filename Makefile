SHELL                   := $(shell which bash) -o pipefail
ABS_TOP                 := $(shell pwd)

SIM_RTL                 := $(shell find $(ABS_TOP)/sim -type f -name "*.sv")
SIM_TARGETS             := $(shell realpath --relative-to $(ABS_TOP) $(SIM_RTL))

VCS                     := /share/instsww/synopsys-new/vcs/T-2022.06-SP2-9/bin/vcs -full64
VPD2FSDB				:= /share/instsww/synopsys-new/verdi/T-2022.06-SP2/bin/vpd2fsdb
VCS_OPTS                := -notice -line +lint=all,noVCDE,noNS,noSVA-UA -sverilog -timescale=1ns/1ps -debug_access+all -kdb
VCS_TARGETS             := $(SIM_TARGETS:%.sv=%.vpd)
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

$(VCS_TARGETS): sim/%.vpd: sim/%.tb FORCE
	cd sim && ./$*.tb +verbose=1 +vpdfile+$*.vpd
	cd sim && $(VPD2FSDB) ./$*.vpd -o ./$*.fsdb

sim-all: 
	make sim/one_bit_comparator_structural_tb.vpd 
	make sim/one_bit_comparator_behavioral_tb.vpd 
	make sim/one_bit_comparator_always_tb.vpd 
	make sim/four_bit_comparator_always_tb.vpd 
	make sim/shift_register_structural_tb.vpd 
	make sim/shift_register_behavioral_tb.vpd 
	make sim/simple_counter_tb.vpd 
	make sim/decoder_4_to_16_tb.vpd

clean: FORCE
	rm -rf ./build $(junk) *.daidir sim/output.txt \
	sim/*.tb sim/*.daidir sim/csrc \
	sim/ucli.key sim/*.vpd sim/*.vcd \
	sim/*.tbi sim/*.fst sim/*.jou sim/*.log sim/*.out \
	sim/*.fsdb