OBJS = tictac.raw explosion.raw
DEST = sounds.lst
DAT = $(patsubst %.lst,%.dat,$(DEST))

all: $(DEST)

$(DAT) : $(OBJS)
	cat $^ > $@

%.lst : %.dat
	arm-none-eabi-objcopy -I binary -O verilog $^ $@

clean:
	rm -f $(DEST) $(DAT) *~
