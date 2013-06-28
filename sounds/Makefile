OBJS = tictac.raw explosion.raw pick_item.raw ouch.raw cri.raw
DEST = sounds.lst
DAT = $(patsubst %.lst,%.dat,$(DEST))

all: $(DEST)

$(DAT) : $(OBJS)
	cat $^ > $@

%.lst : %.dat
	arm-none-eabi-objcopy -I binary -O verilog $^ $@

clean:
	rm -f $(DEST) $(DAT) *~
