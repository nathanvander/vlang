//HuntTheWumpus
import rand
import readline { read_line }
import strconv

const rooms = [[1, 4, 7],   [0, 2, 9],   [1, 3, 11],   [2, 4, 13], [0, 3, 5],
		[4, 6, 14],  [5, 7, 16],   [0, 6, 8],   [7, 9, 17],   [1, 8, 10],
		[9, 11, 18], [2, 10, 12], [11, 13, 19],  [3, 12, 14],  [5, 13, 15],
  		[14, 16, 19], [6, 15, 17],  [8, 16, 18], [10, 17, 19], [12, 15, 18] ] 

fn is_room_adjacent(roomA int, roomB int) bool {
	for j in 0..3 {
		if rooms[roomA][j] == roomB {
			return true
		}
	}
	return false
}

// roomA must be 0..19, index must be 0..2
fn get_adjacent_room(roomA int, index int) int {
	return rooms[roomA][index]
}

fn get_random(range int) int {
	i := rand.intn(range) or {panic(err)}
	return i
}

//input a number.  Return 0 if err
fn input_number(prompt string) int {
	input := read_line(prompt) or {panic(err)}
	i := strconv.atoi(input) or {return 0	}
	return i
	
}
//================================================
fn print_instructions() {
    	println(" Welcome to 'Hunt the Wumpus'! ");
    	println(" The wumpus lives in a cave of 20 rooms. Each room has 3 tunnels leading to");
    	println(" other rooms. (Look at a dodecahedron to see how this works - if you don't know");
    	println(" what a dodecahedron is, ask someone).");
    	println(" ");
    	println(" Hazards:");
    	println(" Bottomless pits - two rooms have bottomless pits in them. If you go there, you ");
    	println(" fall into the pit (& lose!)");
    	println(" Super bats - two other rooms have super bats.  If you go there, a bat grabs you");
    	println(" and takes you to some other room at random. (Which may be troublesome). Once the");
    	println(" bat has moved you, that bat moves to another random location on the map.");
		println(" ");
    	println(" Wumpus:");
    	println(" The wumpus is not bothered by hazards (he has sucker feet and is too big for a");
    	println(" bat to lift).  Usually he is asleep.  Two things wake him up: you shooting an");
    	println(" arrow or you entering his room. If the wumpus wakes he moves one room or ");
    	println(" stays still. After that, if he is where you are, he eats you up and you lose!");
		println(" ");
    	println(" You:");
    	println(" Each turn you may move, save or shoot an arrow using the commands move, save, & shoot.");
    	println(" Moving: you can move one room (thru one tunnel).");
    	println(" Arrows: you have 3 arrows. You lose when you run out. You aim by telling the");
    	println(" computer the rooms you want the arrow to go to.  If the arrow can't go that way");
    	println(" (if no tunnel), the arrow will not fire.");
		println(" ");
    	println(" Warnings:");
    	println(" When you are one room away from a wumpus or hazard, the computer says:");
		println(" Warnings:");
    	println(" Wumpus: 'I smell a wumpus'");
    	println(" Bat: 'Bats nearby'");
    	println(" Pit: 'I feel a draft'");
		println(" Warnings:");
    	println(" ");
    	println("Press 1 to return to the main menu.");
    	input_number(">");
	}


//=================================================
struct WumpusGame {
mut:
	num_rooms int
    current_room int  
    starting_position int 
    wumpus_room int 
    bat1_room int 
    bat2_room int 
    pit1_room int 
    pit2_room int // Stores the room numbers of the respective
    wumpus_start int 
    bat1_start int 
    bat2_start int
    player_alive bool 
    wumpus_alive bool // Are the player and wumpus still alive? True or false.
    num_arrows int //store arrow count
}

//constructor
fn new_game() &WumpusGame {
	mut w := &WumpusGame{}
	w.num_rooms = 20
	w.wumpus_start = -1
	w.bat1_start = -1
	w.bat2_start = -1
	return w
}

fn (mut w WumpusGame) place_wumpus() {
	random_room := get_random(19) + 1
	w.wumpus_room = random_room
	w.wumpus_start = random_room
}

fn (mut w WumpusGame) place_bats() {
  	mut valid_room := false
  	for !valid_room {
      	w.bat1_room = get_random(19) + 1
      	if w.bat1_room != w.wumpus_room {
         	valid_room = true
       	}
  	}

  	valid_room = false
  	for !valid_room {
  		w.bat2_room = get_random(19) + 1
  		if w.bat2_room != w.wumpus_room && w.bat2_room != w.bat1_room {
  			valid_room = true
  		}
  	}
  	w.bat1_start = w.bat1_room
  	w.bat2_start = w.bat2_room
}

fn (mut w WumpusGame) place_pits() {
	w.pit1_room = get_random(19) + 1
   	w.pit2_room = get_random(19) + 1
}

fn (mut w WumpusGame) place_player() {
	w.starting_position = 0
	w.current_room = w.move_player(0)
}

//move player to new room and return room number
//I don't know why this is a separate method, I am just translating the code
//it is called on startup, when player moves, and when bats move him
fn (w WumpusGame) move_player(r int) int {
	println("[move_player] Player is moving from ${w.current_room} to room $r")
	return r
}

fn (mut w WumpusGame) action_move() {
	println("Which room? ");
   	new_room := input_number("?")
    if  new_room < 0 || new_room > 19 {
        	println("You cannot move there.")
    } else {
      	// Check if the user inputted a valid room id, then simply move player there.
        if w.is_valid_move(new_room)
        {
        	w.current_room = w.move_player(new_room)
            w.inspect_current_room()
		}
        else
        {
         	println("There are no tunnels that lead there");
        }
	}
}

fn (w WumpusGame) is_valid_move(roomid int) bool {
	if roomid < 0 {return false }
	if roomid > w.num_rooms {return false}
	if !is_room_adjacent(w.current_room, roomid) {return false}
	return true
}

fn (mut w WumpusGame) shoot() {
        if w.num_arrows < 1 {
        	println("You do not have any arrows!")
        	return
        }
		println("Which room? ")
		new_room := input_number("?")
       	if new_room < 0 || new_room > 19 {
       		println("You cannot shoot there.")
        	return
        }        	

        if w.is_valid_move(new_room) {
        	println("You shoot an arrow from ${w.current_room} to $new_room")
        	w.num_arrows--;
           	if new_room == w.wumpus_room {
            	println("ARGH.. Splat!")
                println("Congratulations! You killed the Wumpus! You Win.")
                println("Awesome job dude!!!")
                println("Please don't ever play this stupid game again")
                println("Press 1 to return to the main menu.")
                w.wumpus_alive = false
                input_number("?")
            }
            else
            {
            	rando := get_random(2)
            	//there is 50% chance Wumpus will move
            	if rando == 1 {
            		println("You miss! But you startled the Wumpus")
                	w.move_startled_wumpus(w.wumpus_room)
                	println("Arrows Left: ${w.num_arrows}")
                	if w.wumpus_room == w.current_room {
                		println("The wumpus attacked you! You've been killed.")
                		println("That's what you get for trying to shoot at the mighty Wumpus")
                	    println("Game Over!");
                	    w.player_alive = false
                	    w.play_again()
                	} else {
                		println("The Wumpus moved to a new room.  Be careful")
                	}
                } else {
                	println("The Wumpus ignores your pitiful attempt to shoot at him")
                }
            }
		} else {
			println("You cannot shoot there.")
		}
}

fn (mut w WumpusGame) inspect_current_room() {
		println("You arrive in room ${w.current_room} and look around");
		//check to see if wumpus lives there
	    if w.current_room == w.wumpus_room
	    {
	    	rando := get_random(2)
	    	if rando==0 {
	    		println("You wake up the angry Wumpus")
	        	println("The Wumpus ate you!!!")
	        	println("LOSER!!!")
	        	println("You die a painful death")
	        	w.player_alive = false
	        	w.play_again()
	        } else {
	        	println("You scared the wumpus so he runs away from you")
	        	w.move_startled_wumpus(w.wumpus_room)
	        }
	    }
	    //check for bats
	    else if w.current_room == w.bat1_room || w.current_room == w.bat2_room
	    {
	        room_bats_left := w.current_room
	        mut valid_new_bat_room := false
	        mut is_current_room_bat_free := false
	        println("Snatched by superbats!!")
	        if w.current_room == w.pit1_room || w.current_room == w.pit2_room {
	            println("Luckily, the bats saved you from the bottomless pit!!")
	        }
	        
	        for !is_current_room_bat_free {
	            w.current_room = w.move_player(get_random(20))
	            println("The bats move you to room ${w.current_room}");
	            if w.current_room != w.bat1_room && w.current_room != w.bat2_room {
	            	//break out of loop
	                is_current_room_bat_free = true
	            } else {
	            	println("The superbats snatch you again!!")
	            }
	        }
	        println("The bats moved you to room ${w.current_room}");
	        w.inspect_current_room();

			//move bat1 if necessary
	        if room_bats_left == w.bat1_room {
	            for !valid_new_bat_room {
	                w.bat1_room = get_random(19) + 1
	                println("(bat1 moving to ${w.bat1_room})")
	                if w.bat1_room != w.wumpus_room && w.bat1_room != w.current_room {
	                    valid_new_bat_room = true
	                }
	            }
	        }
	        //move bat2 if necessary
	        valid_new_bat_room = false
	        if room_bats_left == w.bat2_room {
	        	for !valid_new_bat_room {
	                w.bat2_room = get_random(19) + 1
	                println("(bat2 moving to ${w.bat2_room})")
	                if w.bat2_room != w.wumpus_room && w.bat2_room != w.current_room {
	                    valid_new_bat_room = true
	                }
	            }
	        }
	    }
	    //check for pits
	    else if w.current_room == w.pit1_room || w.current_room == w.pit2_room
	    {
	    	println("You enter room ${w.current_room}")
	        println("YYYIIIIIEEEEE.... fell in a pit!!!")
	        println("GAME OVER LOSER!!!")
	        println("You die a painful death")
	        w.player_alive = false
	        w.play_again()
	    }
	    //move to new room
	    else
	    {
	        println("You are in room ${w.current_room}")
	        if is_room_adjacent(w.current_room, w.wumpus_room) {
	            println("You smell a horrid stench...")
	        }
	        if is_room_adjacent(w.current_room, w.bat1_room) || is_room_adjacent(w.current_room, w.bat2_room) {
	            println("Bats nearby...")
	        }
	        if is_room_adjacent(w.current_room, w.pit1_room) || is_room_adjacent(w.current_room, w.pit2_room){
	            println("You feel a draft...")
	        }
	        println("Tunnels lead to rooms ")
	        for j in 0..3 
	        {
	        	k := get_adjacent_room(w.current_room,j)
	            println("$k");
	        }
	        //debugging
	        println("(Psst. The wumpus is in room ${w.wumpus_room} )")
	    }
}

fn (mut w WumpusGame) move_startled_wumpus(room_num int){
	//rando is a number from 0..2
	rando := get_random(3)
	if rando <0 || rando>2 {
		println("[move_startled_wumpus] rando = $rando")
	}
	w.wumpus_room = get_adjacent_room(room_num,rando)
}

// This restarts the map from the beginning without resetting the locations
fn (mut w WumpusGame) play_again(){
	mut reply := 0
	println("Would you like to replay the same map? Enter 1 to play again.")
	reply = input_number("?")
	if reply == 1 {
		w.current_room = w.starting_position
		w.player_alive = true
	    w.wumpus_room = w.wumpus_start
	    w.bat1_room = w.bat1_start
	    w.bat2_room = w.bat2_start
	  
	    println("Try not to die this time.")
	    w.inspect_current_room()
	    
	} else {
		w.player_alive = false
		println("Hahaha the Wumpus is laughing at you as you despair of ever beating him")
	}
}

fn (mut w WumpusGame) play_game() {
	mut choice := 0 
	mut valid_choice := false	

	println("Running the game...");

  	// Initialize the game
	w.place_wumpus()
	w.place_bats()
	w.place_pits()
	w.place_player()

	// game set up
	w.player_alive = true
	w.wumpus_alive = true
	w.num_arrows = 3

    //Inspects the initial room
    w.inspect_current_room()

    // Main game loop.
    for (w.player_alive && w.wumpus_alive) {
   		println("Enter an action choice.")
    	println("1) Move")
    	println("2) Shoot")
    	println("3) Quit")
    	println("Please make a selection: ")
    	choice = input_number("?")
    	valid_choice = false
    	
		for !valid_choice {
	    	valid_choice = true	        
	        match choice {
	        	1 { w.action_move() }
	        	2 { w.shoot() }
				3 {
				    println("Quitting the current game.")
        			w.player_alive = false
        			break;
	               }
				else {	                  
	            	valid_choice = false
	                println("Invalid choice. Please try again.")
	                choice = input_number("?")
	            }
	    	}
		} 
	}
}

//----------------------------------------

fn main() {
	mut w := new_game();
	start_game(mut w);
}

// this function begins the game loop
fn start_game(mut w WumpusGame) {
	mut choice := 0
  	mut valid_choice := false
  	mut keep_playing := true
  	
  	for keep_playing {
  		//the only way to break out of this endless loop is by entering 3 (quit)
      	println("Welcome to Hunt The Wumpus.")
      	println("1) Play Game")
      	println("2) Print Instructions")
      	println("3) Quit")
      	println("Please make a selection: ")
      	choice = input_number("?")
      	//println("(choice '${choice}')")
      	valid_choice = false
      	
		for !valid_choice {
			//the only way to break out of this endless loop is by:
			//entering 3 (quit) or entering a valid number	
        	valid_choice = true	//assume innocent until proven guilty
       		match choice {
       			1 	{ w.play_game()
       					//could do "break" here
       				}
        	    2	{ print_instructions()
        	    	}
        	    3	{
        	    		keep_playing = false
              			println("Quitting.")
              			
              			break
           			}
           		else {  
           				valid_choice = false
           				println("Invalid choice. Please try again.")
           				choice = input_number("?")
           			}	
       		}	//end match 
		} 	//end !valid_choice
	}	//end keep playing
}	//end fn