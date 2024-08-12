# NESPong

This is Pong for the NES!

It features the main game with a title screen, and palette swapping. I plan to add music and sound effects in the future.

I decided it would be fun to code this game without the use of NESLIB and instead to just code an assembly abstraction layer myself!

the file nesmacros.s creates a set of functions which manipulate the NES hardware and can be used by c files through nesmacros.h

The game uses CA65 and CC65 as compilers

A large portion of init.s was coded using the fourth episode of Micheal Chiaramonte's "the Zero Pages" series (the process of initailizing the NES is really unintuitive so this tutorial really came in handy!): 
https://www.youtube.com/watch?v=JgdcGcJga4w&list=PL29OkqO3wUxzOmjc0VKcdiNPqwliHEuEk&index=1&t
