vpath %.sv ../src

SRC = background.sv controleur.sv DE2_fpga.sv flame.sv gene_clk.sv gene_reset.sv keyboard.sv maze.sv mixer.sv player1.sv player2.sv seven_seg.sv synchro.sv wall.sv top.sv

TAGS = $(patsubst %.sv,.%.tag,$(SRC))

all: $(TAGS)

work:
	vlib work

.%.tag: %.sv | work
	vlog -64 +acc $^
	touch $@

simu: $(TAGS) | work
	vsim top
