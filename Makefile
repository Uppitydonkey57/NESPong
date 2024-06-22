main_name = main
output_name = game
all:
	cc65 -Oirs src/$(main_name).c --add-source -o bin/$(main_name).s
	cc65 -Oirs src/nesmacros.c --add-source -o bin/nesmacrosc.s
	ca65 src/init.s -o bin/init.o
	ca65 bin/$(main_name).s -o bin/$(main_name).o
	ca65 src/nesmacros.s -o bin/nesmacros.o
	ca65 bin/nesmacrosc.s -o bin/nesmacrosc.o
	ld65 bin/init.o bin/nesmacros.o bin/nesmacrosc.o bin/$(main_name).o -o bin/$(output_name).nes nes.lib -C nesrom.cfg -Ln bin/label.txt 
