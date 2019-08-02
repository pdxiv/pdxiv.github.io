# Action reference

## Condition descriptions

Name | Description
---- | -----------
parameter | Always passes. The number may be used as a parameter for the commands in this action entry. See the commands for the uses of parameters.
carried | Passes is the player is carry the numbered object. It fails if the numbered object is in this room or any other room.
here | Passes if the player is in the room with the numbered object. It fails if the numbered object is in any other room or is being carried.
present | Passes if the player has the numbered object available either because he is carrying it or it is in the same room. It fails if the numbered object is in any other room.
at | Passes if the player is in the numnbered room. It fails if the player is in any other room.
not here | Fails if the player is in the same room as the numbered object. It passes if the player is carrying the object or the object is in any other room.
not carried | Fails if the player is carrying the numbered object. It passes if the object is in the same room as the player or any other room.
not at | Fails if the player is in the numbered room. It passes if the player is in any other room.
flag | Passes if the numbered flag-bit is set. It fails if the flag-bit is cleared. See the description later for flag-bits.
not flag | Fails if the numbered flag-bit is set. It passes if the flag-bit is cleared. See the description later for flag-bits.
loaded | Passes if the player is carrying any objects at all. It fails if the player is carrying no objects.
not loaded | Fails if the player is carrying any objects at all. It passes if the player is carrying no objects.
not present | Fails if the numbered object is available either because the player is carrying it or it is in the same room. It passes if the object is in any other room.
exists | Fails if the numbered object is in room 0 (the storeroom). It passes if the object is in any other room.
not exists | Passes if the numbered object is in room 0 (the storeroom). It fails if the object is in any other room.
counter le | Passes if the counter is less than or equal to the number. It fails if the counter is greater than the number. See the description of the counter later.
counter gt | Passes if the counter is greater than the number. It fails if the counter is less than or equal to the number. See the description of the counter later.
not moved | Passes if the numbered object is in the room it originally started in. It fails if the object is being carried or is in any other room.
moved | Fails if the numbered object is in the room it originally started in. It passes if the object is being carried or is in any other room.
counter eq | Passes if the counter is equal to the number. It fails if the counter is not equal to the number.

## Command descriptions

Name | Description
---- | -----------
get | Pick up the parameter 1 object unless he already is carrying the limit. The object may be in this room or in any other room.
drop | Drop the parameter 1 object in the current room. The object may be carried or may be in another room.
goto | Move the player to the parameter 1 room. This command should be followed by a DspRM command. Also, this may need to be followed by a DAY/NIGHT command.
destroy | Move the parameter 1 object to room 0 (the storeroom).
set dark | Set the darkness flag-bit (15). It will be dark if the artificial light source is not available, so this should be followed by a DspRM command.
clear dark | Clear the darknes flag-bit (15). This should be follwed by a DspRM command.
set flag | Set the parameter 1 flag-bit.
clear flag | This clears the parameter 1 flag-bit.
die | Tell the player he is dead, goto the last room (usually some form of limbo), make it DAY and display the room.
put | Move the parameter 1 object to the parameter 2 room. This will automatically display the room if the object came from or went to the current room.
game over | Tell the player the game is over and ask if he wants to play again.
look | Display the current room. This checks if the darknes flag-bit (15) is set and the artificial light (object 9) is not available. If there is light, it displays the room description, the objects in the room and any obvious exits.
score | Tells the player how many treasures he has collected by getting them to the treasure room and what his percentage of the total is.
inventory | Tells the player what objects he is carrying.
set flag0 | Sets the flag-bit numbered 0. (This may be convenient because no parameter is used.)
clear flag0 | Clears the flag-bit numbered 0. (This may be convenient because no parameter is used.)
refill lamp | Re-fill the artificial light source and clear flag-bit 16 which indicates that it was empty. This also picks up the artificial light source (object 9). This command should be followed by a x->RM0 to store the unlighted light source. (These are two different objects.)
clear | This command cleared the screen on the BASIC version of ADVENTURE. It does nothing in the machine language version.
save game | This command saves the game to tape or disk, depending on which version is used. It writes some user variables such as time limit and the current room and the current locations of all objects out as a saved game.
swap | This command exchanges the room locations of the parameter 1 object and the parameter 2 object. If the objects in the current room change, the new description will be displayed.
continue | This command sets a flag to allow more than four commands to be executed. When all the commands in this action entry have been performed, the commands in the next action entry will also be executed if the verb and noun are both zero. The condition fields of the new action entry will contain the parameters for the commands in the new action entry. When an action entry with a non-zero verb or noun is encountered, the continue flag is cleared.
superget | Always pick up the parameter 1 object, even if that would cause the carry limit to be exceeded. Otherwise, this is like command 52, GETx.
put with | Put the parameter 2 object in the same place as the parameter 1 object. If the parameter 2 object is being carried, this will pick up the parameter 1 object too, regardless of the carry limit. If this changes the objects in the current room, the room will be displayed again.
dec counter | This subtracts 1 from the counter value.
print counter | This displays the current value of the counter.
set counter | This sets the counter to the parameter 1 value.
swap room | This exchanges the values of the current room register with the alternate room register 0. This may be used to save the room a player came from in order to put him back there later. This should be followed by a GOTOy command if the alternate room register 0 had not already been set.
select counter | This command exchanges the values of the counter and the parameter 1 alternate counter. There are eight alternate counters numbered from 0 to 7. Also, the time limit may be accessed as alternate counter 8.
add to counter | This adds the parameter 1 value to the counter.
subtract from counter | This subtracts the parameter 1 value from the counter.
print noun | This says the noun (second word) input by the player.
println noun | This says the noun (second word) input by the player and starts a new line.
println | This just starts a new line on the display.
swap specific room | This exchanges the values of the current room register with the parameter 1 alternate room register. This may be used to remember more than one room. There are six alternate room registers numbered from 0 to 5.
pause | This command delays about 1 second before going on to the next command.
