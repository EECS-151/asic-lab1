SHELL                   := $(shell which bash) -o pipefail
ABS_TOP                 := $(shell pwd)

SIM_RTL                 := $(shell find $(ABS_TOP)/sim -type f -name "*.sv")
SIM_TARGETS             := $(shell realpath --relative-to $(ABS_TOP) $(SIM_RTL))

IVERILOG                := iverilog
IVERILOG_OPTS           := -D IVERILOG=1 -g2012 -gassertions -Wall -Wno-timescale
IVERILOG_TARGETS        := $(SIM_TARGETS:%.sv=%.fst)
VVP                     := vvp
RTL                     := $(ABS_TOP)/src/d_flip_flop.sv

.PHONY: FORCE

sim/%.vvp: sim/%.sv FORCE
	cd sim && $(IVERILOG) $(IVERILOG_OPTS) -o $*.vvp $*.sv $(RTL) ../src/$(patsubst %_tb.sv,%.sv,$(notdir $<))

# special case where one tb depends on two sources
sim/decoder_4_to_16_tb.vvp: sim/decoder_4_to_16_tb.sv FORCE
	cd sim && $(IVERILOG) $(IVERILOG_OPTS) -o decoder_4_to_16_tb.vvp decoder_4_to_16_tb.sv $(RTL) ../src/line_decoder.sv ../src/$(patsubst %_tb.sv,%.sv,$(notdir $<))

$(IVERILOG_TARGETS): sim/%.fst: sim/%.vvp FORCE
	cd sim && $(VVP) $*.vvp -fst

sim-all: 
	make sim/one_bit_comparator_structural_tb.fst 
	make sim/one_bit_comparator_behavioral_tb.fst 
	make sim/one_bit_comparator_always_tb.fst 
	make sim/four_bit_comparator_always_tb.fst 
	make sim/shift_register_structural_tb.fst 
	make sim/shift_register_behavioral_tb.fst 
	make sim/simple_counter_tb.fst 
	make sim/decoder_4_to_16_tb.fst 

clean: FORCE
	rm -rf ./build $(junk) *.daidir sim/output.txt \
	sim/*.tb sim/*.daidir sim/csrc \
	sim/ucli.key sim/*.vpd sim/*.vcd \
	sim/*.tbi sim/*.fst sim/*.jou sim/*.log sim/*.out \
	sim/*.fsdb sim/*.vvp
