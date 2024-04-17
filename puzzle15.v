//modified from https://rosettacode.org/wiki/15_puzzle_game#Go

import rand
import strings
import readline { read_line }

//right before left is in the Go code
enum Move {
	up
	down
	right
	left
}

fn (mv Move) display() string {
	match mv {
		.up {return "up"}
		.down {return "down"}
		.right {return "right"}
		.left {return "left"}
	}
}

const u = u8(85)	//U
const d = u8(68)	//D
const r = u8(82)	//R
const l = u8(76)	//L
const q = u8(81)	//Q

const solved_board =  [int(1), 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 0]

fn rand_move() Move {
	i := rand.intn(4) or {panic(err)}
	m := match i {
		0 { Move.up}
		1 { Move.down}
		2 { Move.right}
		3 { Move.left }
		else { 
			println("Unexpected result $i in Move()")
			Move.up
		}
	}
	return m
}

//the type of board is []int, but it must have 16 elements
fn board_to_string(board []int) string {
	mut buf := strings.new_builder(48)
	for i in 0..16 {
		c := board[i]
		if c == 0 {
			buf.write_string("  .")
		} else {
			buf.write_string(" ${c:3}")
		}
		if i%4 == 3 {
			buf.writeln("")
		}
	}
	return buf.str()
}

//empty is the empty cell and has a number from 0..15
struct Puzzle {
mut: 
	board []int
	empty int
	moves int
	quit bool
}

fn new_puzzle() &Puzzle {
	mut p := &Puzzle{
		board: solved_board.clone(),
		empty: 15,
	}
	// Could make this configurable, 10==easy, 50==normal, 100==hard
	p.shuffle(50)
	//reset number of moves
	p.moves=1
	return p
}

fn (mut p Puzzle) shuffle(moves int) {
	println("shuffling $moves moves")
	for i := 0; i < moves; {
		if p.do_move(rand_move()) {
			i++
			//println("moved $i times")
		}
	}
	println("finished shuffling")
}

//Vlang can return multiple values
fn (p Puzzle) is_valid_move(m Move) (int, bool) {
	match m {
		.up {return p.empty - 4, p.empty/4 > 0}
		.down {return p.empty + 4, p.empty/4 < 3}
		.right { return p.empty + 1, p.empty%4 < 3}
		.left {return p.empty - 1, p.empty%4 > 0}
	}
}

fn (mut p Puzzle) do_move(m Move) bool {
	i := p.empty
	j, ok := p.is_valid_move(m)
	println("moving $m.display()")
	if ok {	
		p.board[i], p.board[j] = p.board[j], p.board[i]
		p.empty = j
		p.moves++
		//println("---------------")
		//println(board_to_string(p.board))
		//println("---------------")
	} 
	else {
		println("from $i , $m.display() is not a valid move")
	}
	return ok
}

fn (mut p Puzzle) play() {
	//println("Starting board:")
	//println("--------------- starting")
	//println(board_to_string(p.board))
	//println("--------------- solved")
	//	println(board_to_string(solved_board))
	//	println("---------------")		
	for p.board != solved_board && !p.quit {
		println("---------------")
		println(board_to_string(p.board))
		println("---------------")
		p.play_one_move()
		
	}
	if p.board == solved_board {
		println("You solved the puzzle in $p.moves moves.")
	}
}

fn (mut p Puzzle) play_one_move() {
	//this is an endless loop. There are two ways out
	//	1. enter Q for quit
	//	2. enter a valid move
	for {
		prompt := "Enter move # $p.moves (U, D, L, R, or Q): "
        mut input := read_line(prompt) or {
        	println("empty line")
        	continue
        }   
        input = input.trim_space()
		
		mut m := Move.up
		
		match input[0] {
			u { m = Move.up}
			d { m = Move.down}
			r { m = Move.right}
			l { m = Move.left }
			q { p.quit = true
				println("Quiting after $p.moves moves")
				return
				}
			else { println("Try again. Enter U, D, L, R, or Q")
				continue
			}
		}
		
		if !p.do_move(m) {
			println("That is not a valid move at the moment.")
			continue
		} else {
			return
		}
	}
}

fn main() {
	println("Puzzle Game")
	mut p := new_puzzle()
	p.play()
}
