# Adventshark reference

Documentation is currently a work in process but this is some of the more essential reference information.

## Reserved item locations

Some verbs, nouns and objects need to be in a particular location for things to work correctly. They are as follows.

### Reserved verb locations

Verb location | Verb | Comment
------------- | ---- | -------
0 | AUT | Not used as a verb in actions
1 | GO |
10 | GET |
18 | DROP |

### Reserved noun locations

Noun location | Noun | Comment
------------- | ---- | -------
0 | ANY | Pseudo-noun that means that no noun is used
1 | NORTH |
2 | SOUTH |
3 | EAST |
4 | WEST |
5 | UP |
6 | DOWN |

### Reserved object locations

Object location | Comment
--------------- | -------
9 | Artificial light source in its lighted state

## Action reference

Actions consist of three parts:
- Preconditions
- Conditions
- Commands

### Preconditions

This part defines what type the action has.

Preconditions declare the action type as one of the following types:
- Verb-Noun
- Auto
- Subroutine

#### Verb-Noun

This means that the action is run if the correct two words (verbs and nouns) are input by the player. If the second word (the noun) is set to "ANY", the action only needs the first word (the verb) to match, to execute.

#### Auto

This means that the action has a random chance of running, every time a player makes a move. The chance can be set between 1 (execute 1% of the time) and 100 (execute every time).

#### Subroutine

This is used to make it possible for an action to trigger more than 4 commands. If a Verb-Noun action or Auto action has used the "continue" command, all following subroutine actions will execute. A subroutine action will never execute, unless triggered with a "continue" command.

### Conditions

Conditions do two things: provide arguments for commands and provide conditions which must be met to continue the execution of the action. If one or more of the conditions fail, the action will stop executing and the next action in the list will be evaluated.

Name | Description
---- | -----------
at | Passes if the player is in the selected room. It fails if the player is in any other room.
carried | Passes is the player is carrying the selected object. It fails if the selected object is in this room or any other room.
counter eq | Passes if the counter is equal to the number. It fails if the counter is not equal to the number.
counter gt | Passes if the counter is greater than the number. It fails if the counter is less than or equal to the number.
counter le | Passes if the counter is less than or equal to the number. It fails if the counter is greater than the number. See the description of the counter later.
exists | Fails if the selected object is in room 0 (the storeroom). It passes if the object is in any other room.
flag | Passes if the numbered flag-bit is set. It fails if the flag-bit is cleared. See the description later for flag-bits.
here | Passes if the player is in the room with the selected object. It fails if the selected object is in any other room or is being carried.
loaded | Passes if the player is carrying any objects at all. It fails if the player is carrying no objects.
moved | Fails if the selected object is in the room it originally started in. It passes if the object is being carried or is in any other room.
not at | Fails if the player is in the selected room. It passes if the player is in any other room.
not carried | Fails if the player is carrying the selected object. It passes if the object is in the same room as the player or any other room.
not exists | Passes if the selected object is in room 0 (the storeroom). It fails if the object is in any other room.
not flag | Fails if the numbered flag-bit is set. It passes if the flag-bit is cleared. See the description later for flag-bits.
not here | Fails if the player is in the same room as the selected object. It passes if the player is carrying the object or the object is in any other room.
not loaded | Fails if the player is carrying any objects at all. It passes if the player is carrying no objects.
not moved | Passes if the selected object is in the room it originally started in. It fails if the object is being carried or is in any other room.
not present | Fails if the selected object is available either because the player is carrying it or it is in the same room. It passes if the object is in any other room.
parameter | Always passes. This is used to supply parameters for commands in this action entry.
present | Passes if the player has the selected object available either because he/she is carrying it or it is in the same room. It fails if the selected object is in any other room.

### Commands

Commands are used to manipulate the game world, and to print things on the screen for the player to see. Commands take anything from zero to two arguments, depending on which one is executing. The arguments are provided by the preceding Condition block of the action.

Name | Description
---- | -----------
add to counter | This adds the parameter 1 value to the counter.
clear dark | Clear the darknes flag-bit (15). This should be follwed by a DspRM command.
clear flag | This clears the parameter 1 flag-bit.
clear flag0 | Clears the flag-bit numbered 0. (This may be convenient because no parameter is used.)
clear | This command cleared the screen on the BASIC version of ADVENTURE. It does nothing in the machine language version.
continue | This command allows one or more following subroutine actions to to be executed.
dec counter | This subtracts 1 from the counter value.
destroy | Move the parameter 1 object to room 0 (the storeroom).
die | Tell the player that he/she is dead, goto the last room (usually some form of limbo), make it DAY and display the room.
drop | Drop the parameter 1 object in the current room. The object may be carried or may be in another room.
game over | Tell the player that the game is over and ask if he/she wants to play again.
get | Pick up the parameter 1 object unless he/she already is carrying the limit. The object may be in this room or in any other room.
goto | Move the player to the parameter 1 room. This command should be followed by a DspRM command. Also, this may need to be followed by a DAY/NIGHT command.
inventory | Tells the player what objects he/she is carrying.
look | Display the current room. This checks if the darknes flag-bit (15) is set and the artificial light (object 9) is not available. If there is light, it displays the room description, the objects in the room and any obvious exits.
pause | This command delays about 1 second before going on to the next command.
print counter | This displays the current value of the counter.
print noun | This says the noun (second word) input by the player.
println noun | This says the noun (second word) input by the player and starts a new line.
println | This just starts a new line on the display.
put with | Put the parameter 2 object in the same place as the parameter 1 object. If the parameter 2 object is being carried, this will pick up the parameter 1 object too, regardless of the carry limit. If this changes the objects in the current room, the room will be displayed again.
put | Move the parameter 1 object to the parameter 2 room. This will automatically display the room if the object came from or went to the current room.
refill lamp | Re-fill the artificial light source and clear flag-bit 16 which indicates that it was empty. This also picks up the artificial light source (object 9). This command should be followed by a x->RM0 to store the unlighted light source. (These are two different objects.)
save game | This command saves the game to tape or disk, depending on which version is used. It writes some user variables such as time limit and the current room and the current locations of all objects out as a saved game.
score | Tells the player how many treasures he/she has collected by getting them to the treasure room and what his percentage of the total is.
select counter | This command exchanges the values of the counter and the parameter 1 alternate counter. There are eight alternate counters numbered from 0 to 7. Also, the time limit may be accessed as alternate counter 8.
set counter | This sets the counter to the parameter 1 value.
set dark | Set the darkness flag-bit (15). It will be dark if the artificial light source is not available, so this should be followed by a DspRM command.
set flag | Set the parameter 1 flag-bit.
set flag0 | Sets the flag-bit numbered 0. (This may be convenient because no parameter is used.)
subtract from counter | This subtracts the parameter 1 value from the counter.
superget | Always pick up the parameter 1 object, even if that would cause the carry limit to be exceeded. Otherwise, this is like command 52, GETx.
swap room | This exchanges the values of the current room register with the alternate room register 0. This may be used to save the room a player came from in order to put him back there later. This should be followed by a GOTOy command if the alternate room register 0 had not already been set.
swap | This command exchanges the room locations of the parameter 1 object and the parameter 2 object. If the objects in the current room change, the new description will be displayed.
swap specific room | This exchanges the values of the current room register with the parameter 1 alternate room register. This may be used to remember more than one room. There are six alternate room registers numbered from 0 to 5.
message | This command prints the selected message string
no operation | This command does nothing
