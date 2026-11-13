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

# All SystemVerilog files in the project
SV_FILES := $(sort $(wildcard $(PROJECT)/*.sv))

# Identify packages and testbenches
PKG_FILES := $(filter %_pkg.sv,$(SV_FILES))
TB_FILES  := $(filter %_tb.sv,$(SV_FILES))

# Exclude packages and testbenches from design files
DESIGN_FILES := $(filter-out $(PKG_FILES) $(TB_FILES),$(SV_FILES))

# Selected testbench
TB := $(PROJECT)/$(MODULE)_tb.sv

# Compilation order: packages -> design -> testbench
COMPILE_FILES := $(PKG_FILES) $(DESIGN_FILES) $(TB)

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
	@printf '  %s\n' $(COMPILE_FILES)
	@echo "Binary:  $(SIM)"
	@echo "Waveform: $(VCD)"
	@echo "Log:      $(LOG)"

compile: check
	iverilog -g2012 -Wall \
		-s "$(MODULE)_tb" \
		-o "$(SIM)" \
		$(COMPILE_FILES)

sim: check
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