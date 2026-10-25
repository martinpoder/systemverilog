# Shared SystemVerilog workflow
#
# Examples:
#   make list PROJECT=my_project
#   make compile PROJECT=my_project MODULE=cpu
#   make sim PROJECT=my_project MODULE=cpu
#   make wave PROJECT=my_project MODULE=cpu
#   make clean PROJECT=my_project MODULE=cpu
# 
# Testbenches should use following VCD filename 
#
# string vcd_file;
#
# initial begin
#    if (!$value$plusargs("VCD=%s", vcd_file))
#        vcd_file = "simulation.vcd";
#
#    $dumpfile(vcd_file);
#    $dumpvars(0, cpu_tb);
#
# end
# 
# Can be used together with .vscode/tasks.json to run them 
# from keyboard shortcut (Ctrl + Shift + P)

PROJECT ?= .
MODULE ?=

# All SV files in this project folder
SV_FILES := $(wildcard $(PROJECT)/*.sv)
TB_FILES := $(wildcard $(PROJECT)/*_tb.sv)

# Exclude all testbenches except the selected one
DESIGN_FILES := $(filter-out $(TB_FILES),$(SV_FILES))
TB := $(PROJECT)/$(MODULE)_tb.sv

# Outputs named after the selected module
SIM := $(PROJECT)/$(MODULE).vvp
VCD := $(PROJECT)/$(MODULE).vcd
LOG := $(PROJECT)/$(MODULE).log

.PHONY: all check list compile sim wave clean

all: sim

check:
	@test -n "$(MODULE)" || \
		(echo "ERROR: Specify MODULE=name"; exit 1)
	@test -d "$(PROJECT)" || \
		(echo "ERROR: Project folder not found: $(PROJECT)"; exit 1)
	@test -f "$(TB)" || \
		(echo "ERROR: Testbench not found: $(TB)"; exit 1)

list: check
	@echo "Project: $(PROJECT)"
	@echo "Module:  $(MODULE)"
	@echo "Top:     $(MODULE)_tb"
	@echo "Sources:"
	@printf '  %s\n' $(DESIGN_FILES) "$(TB)"
	@echo "Binary:  $(SIM)"
	@echo "Waveform: $(VCD)"
	@echo "Log:      $(LOG)"

compile: check
	iverilog -g2012 -Wall \
		-s "$(MODULE)_tb" \
		-o "$(SIM)" \
		$(DESIGN_FILES) "$(TB)"

sim: compile
	@bash -o pipefail -c '{ \
		$(MAKE) compile PROJECT="$(PROJECT)" MODULE="$(MODULE)" && \
		cd "$(PROJECT)" && \
		vvp "$(MODULE).vvp" +VCD="$(MODULE).vcd"; \
	} 2>&1 | tee "$(LOG)"'

wave: check
	@test -f "$(VCD)" || \
		(echo "ERROR: $(VCD) not found. Run make sim first."; exit 1)
	gtkwave "$(VCD)"

clean: check
	rm -f "$(SIM)"