# Shared SystemVerilog workflow (WSL / Ubuntu)
# Examples: make sim PROJECT=taskmaster MODULE=alu SIMULATOR=verilator
#           make sim PROJECT=taskmaster MODULE=alu SIMULATOR=iverilog
PROJECT ?= .
MODULE ?=
SIMULATOR ?= verilator

SV_FILES := $(sort $(wildcard $(PROJECT)/*.sv))
PKG_FILES := $(filter %_pkg.sv,$(SV_FILES))
TB_FILES := $(filter %_tb.sv,$(SV_FILES))
DESIGN_FILES := $(filter-out $(PKG_FILES) $(TB_FILES),$(SV_FILES))
TB := $(PROJECT)/$(MODULE)_tb.sv
COMPILE_FILES := $(PKG_FILES) $(DESIGN_FILES) $(TB)

TOP := $(MODULE)_tb
VVP := $(PROJECT)/$(MODULE).vvp
OBJ_DIR := $(PROJECT)/obj_dir_$(MODULE)
VERILATOR_EXE := $(OBJ_DIR)/V$(TOP)
VCD := $(PROJECT)/$(MODULE).vcd
LOG := $(PROJECT)/$(MODULE).log

.PHONY: all check list compile sim wave clean
all: sim

check:
	@test -n "$(MODULE)" || { echo 'ERROR: Specify MODULE=name'; exit 1; }
	@test -d "$(PROJECT)" || { echo 'ERROR: Project folder not found: $(PROJECT)'; exit 1; }
	@test -f "$(TB)" || { echo 'ERROR: Testbench not found: $(TB)'; exit 1; }
	@case "$(SIMULATOR)" in verilator|iverilog) ;; *) echo 'ERROR: SIMULATOR must be verilator or iverilog'; exit 1;; esac

list: check
	@echo 'Project: $(PROJECT)'
	@echo 'Module: $(MODULE)'
	@echo 'Simulator: $(SIMULATOR)'
	@echo 'Top: $(TOP)'
	@echo 'Ordered sources:'
	@printf '  %s\n' $(COMPILE_FILES)
	@echo 'Waveform: $(VCD)'
	@echo 'Log: $(LOG)'

compile: check
ifeq ($(SIMULATOR),verilator)
	verilator --binary --timing --trace-vcd --assert -Wall -Wno-fatal \
		--top-module "$(TOP)" --Mdir "$(abspath $(OBJ_DIR))" \
		$(COMPILE_FILES)
else
	iverilog -g2012 -Wall -s "$(TOP)" -o "$(VVP)" $(COMPILE_FILES)
endif

# Compile once; log both compilation and simulation, preserving exit status.
sim: check
	@bash -o pipefail -c '{ \
		$(MAKE) --no-print-directory compile PROJECT="$(PROJECT)" MODULE="$(MODULE)" SIMULATOR="$(SIMULATOR)" && \
		$(if $(filter verilator,$(SIMULATOR)),cd "$(PROJECT)" && "./obj_dir_$(MODULE)/V$(TOP)" +VCD="$(MODULE).vcd",cd "$(PROJECT)" && vvp "$(MODULE).vvp" +VCD="$(MODULE).vcd"); \
	} 2>&1 | tee "$(LOG)"'

wave: check
	@test -f "$(VCD)" || { echo 'ERROR: $(VCD) not found. Run make sim first.'; exit 1; }
	gtkwave "$(VCD)"

clean: check
	rm -f "$(VVP)" "$(VCD)" "$(LOG)"
	rm -rf "$(OBJ_DIR)"
