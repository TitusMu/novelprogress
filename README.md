# novelprogress
Emacs function to show daily progress when writing a novel

For me, one thing that is important other than the technical aspects (and Emacs most certainly helps me to work faster and more efficiently on my novels) is the question of self-motivation. To help me with that, I have made a little function that shows me the current progress I have made today when I press s-#.

It even has a "graphical" aspect to it, the color changes bit by bit from gray to green, and it simulates a "bar" that fills up. The number of characters/pages needed for my daily goal to be done is in a variable I have in my init file.

I add a picture of the Minibuffer a few times during the day, to give you some idea of what I mean. It is in German, the translation would be: 92.791 characters, 30 pages, equals 56 percent [today new: 0/2] Current page 93 percent, scene 1 page, chapter 1 page.

In the modeline, I also show what "page" I am on. It just divides the length of the Buffer through the average number of characters on a standard page (3000 characters). Must seem like a very un-Emacsy way of doing things to you, but it helps me to get a feeling of getting things done somehow. :)
