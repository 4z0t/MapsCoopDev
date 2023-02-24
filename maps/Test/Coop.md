# Intro

Creation of Coop mission is a complex procedure with 3 main stages each taking huge amount of time and requiring specific skills and knowledge:

1. Map design
2. Scripting
3. Testing and Balancing

Of course don't forget about whole **Idea** of the mission with its own plot and structure of objectives.

## Map design

Maps in Coop are not the same as in competitive games. Those are lacking symmetry to be realistic and entertaining. Map structure is usually made so each new expansion during the mission reveals new areas. This is why world border sometimes breaks this mystery of next map expansion. Map should be simple but at the same time providing different ways of completing an objective.

I'm not a designer and have made few maps to be that experienced in this craft. But I'm still gonna use map editor to combine all of things I'll get with **[Gaea](https://quadspinner.com/)**.

Basically it is a lego for creating natural and realistic terrains for games. It is a long talk about this tool so I'll keep it for next time. Main idea I'll make map for mission with this one not touching map editor at all, but for base design and setting up some stuff for *scripting*...

## Scripting

I'll tell you a secret, everything is trying to kill you is scripted to kill you on missions. There is no AI that thinks what to do actually. Script is a determined sequence of actions to keep track of all things players do and good scripts mean good flow of the mission.

However, I find it a problem. Current state of Coop missions scripts is very disappointing. Imagine good looking house from outside but having inside a total mess upside down furniture. Well, you still can live there except having issues with finding things and having troubles walking around the house. If you will get used to it, it doesn't mean others can.

Studying for Software Engineer made me hate bad code, so, I decided to create better foundation for scripting of coop missions at this point. An another long talk for demo of **[Oxygen](https://github.com/4z0t/Oxygen)** framework.


## Testing and Balancing

Testing and Balancing is very important. Mission must entertain casual players at lower difficulties but give a challenge for experienced players on higher difficulties. Mission mustn't be a hellhole where you suffer (ofc If player wants, he finds the way).

Scripts are allowing everything to tune according to difficulty: amount of units, amount of resources, amount of time for objectives, conditions based on players' progress, and so on. Map is about base positions, their setup depending on difficulty, terrain, resources distribution and paths for *"AI"*.

# What do I want?

To share my experience! I'm doing that for fun and to challenge myself. Ofc if you are interested, you can always help me or suggest things :P