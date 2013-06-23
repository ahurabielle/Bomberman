
LST = flammes.lst player1.lst player2.lst sprites.lst wall.lst

all: $(LST)

%.lst: %.png
	./gen_sprites.py $<

%.png: %.xcf
	xcf2png $< -o $@


