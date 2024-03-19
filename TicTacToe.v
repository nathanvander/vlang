// Tic-Tac-Toe in V
import rand
import readline { read_line }
import strconv

fn contains(list []string, item string) bool {
	return item in list
}
	
//-------------------------------------
// IntList class
// This is strongly influenced by java ArrayList<Integer>
// I do not put objects on the heap because none of them live longer
// than a single function
// Note on terminology:
//	  iarr.len is the same as what I call capacity
//	  iarr.cap could be bigger as it is the amount of memory space reserved
//			I don't use this
struct IntList {
mut:
	iarr []int
	capacity int
	ptr int
}

//constructor
fn new_int_list(capacity int) IntList {
	mut il := IntList{}
	il.capacity = capacity
	//ptr is the current size, also it is the next slot open
	il.ptr = 0
	//create a new int array with capacity number of elements
	il.iarr = []int{len: capacity, init: 0}
	return il
	
}

fn (il IntList) size() int {
	return il.ptr
}

fn (mut il IntList) add(e int) bool {
	//can only add if ptr is less than capacity
	//the actual slots are numbered 0..capacity-1
	//if they are the same size then the list is full
	if il.ptr < il.capacity {
		il.iarr[il.ptr] = e
		il.ptr++
		return true
	} else {
		return false
	}
}

fn (il IntList) get(x int) int {
	return il.iarr[x]
}

fn (il IntList) contains(e int) bool {
	return e in il.iarr
}
//------------------------------------

fn get_random(range int) int {
	i := rand.intn(range) or {panic(err)}
	return i
}

//input a number.  Return 0 if err
fn input_number(prompt string) int {
	input := read_line(prompt) or {panic(err)}
	i := strconv.atoi(input) or {return 0}
	return i
}

fn print_board(list []string) {
	if list.len != 9 {
		println("[print_board] list has ${list.len} elements; unable to print")
	} else {
		println("${list[0]} | ${list[1]} | ${list[2]}")
		println("${list[3]} | ${list[4]} | ${list[5]}")
		println("${list[6]} | ${list[7]} | ${list[8]}")
	}
}

//There must be a better way of checking this instead of building and comparing strings
//especially since this is called multiple times each turn
//oh well I am just converting the code
fn win_condition(c []string, k string) bool {
	cha := "${k}${k}${k}"
	row1:= "${c[0]}${c[1]}${c[2]}"
	row2:= "${c[3]}${c[4]}${c[5]}"
	row3:= "${c[6]}${c[7]}${c[8]}"
	col1:= "${c[0]}${c[3]}${c[6]}"
	col2:= "${c[1]}${c[4]}${c[7]}"
	col3:= "${c[2]}${c[5]}${c[8]}"
	//diagonal
	slash:= "${c[0]}${c[4]}${c[8]}"
	backslash:= "${c[2]}${c[4]}${c[6]}"

    if row1 == cha || row2 == cha || row3 == cha {
    	return true
    }
    if col1 == cha || col2 == cha || col3 == cha { 
    	return true
    } 
    if slash == cha || backslash == cha {
    	return true
    }
    return false
}

//this kind of feels like a method
fn set_letter(mut b []string, pos int, letter string) {
	if pos < 0 || pos > 8 {
		println("[set_letter] $pos is out of range")
	} else {
		position := b[pos]
		if position == " " {
			b[pos]=letter
		} else {
			println("[set_letter] $pos is not empty")
		}
	}
}
	
//---------

fn main() {
	mut board := [' ',' ',' ',' ',' ',' ',' ',' ',' ']
	board_num := ['1','2','3','4','5','6','7','8','9']
	print_board(board_num)
	
	for {
		//check if board is full
		if contains(board,' ') == false {
			println("Cat's Game")
			input_number('?')
			break
		} else if win_condition(board, "x") == true {
			println("You Win!!")
			input_number('?')
			break			
		} else if win_condition(board, "o") == true {
			println("You Lose!!")
			input_number('?')
			break
		} else {
			println("Please pick a square!: ")
            choice := input_number("?") - 1
            set_letter(mut board, choice, "x")
            cpu_pos := cpu_move(board)
            set_letter(mut board, cpu_pos, "o")
        }
        print_board(board)
	}
}

fn cpu_move(board []string) int {
	mut move := 0

	//gather list of possible moves	
	mut cpu := new_int_list(10)
	for i in 0 .. board.len {
		if board[i] == " " {
			cpu.add(i)
		}
	}

	//check self win condition
	for i in 0 .. cpu.size() {
		choice := cpu.get(i)
		mut copy := board.clone()
		copy[choice] = "o"
		if win_condition(copy, "o") == true {
			move = cpu.get(i)
			return move
		}
	}

	//check for player win condition
	for i in 0 .. cpu.size() {
		choice := cpu.get(i)
		mut copy := board.clone()
		copy[choice] = "x"
		if win_condition(copy, "x") == true {
			move = cpu.get(i)
			return move
		}
	}

	//check corners
	mut corners_open := new_int_list(10)
	mut corners := new_int_list(10)
	corners.add(0)
	corners.add(2)
	corners.add(6)
	corners.add(8)

	for i in 0 .. cpu.size() {
		choice := cpu.get(i)
		if corners.contains(choice) == true {
        	corners_open.add(cpu.get(i))
        }
    }
            
    if corners_open.size() > 0 {
    	r := get_random( corners_open.size())
        move = corners_open.get(r)
        return move
    }

    // CPU Center
    if cpu.contains(4) == true {
    	move = 4
        return move
    }

    // CPU Edge
	mut edge_open := new_int_list(10)
	mut edge := new_int_list(10)
    edge.add(1)
    edge.add(3)
    edge.add(5)
    edge.add(7)
    for i in 0 .. cpu.size() {
    	choice := cpu.get(i)
        if edge.contains(choice) == true {
        	edge_open.add(cpu.get(i))
        }
    }
    if edge_open.size() > 0 {
    	r := get_random( edge_open.size())
        move = edge_open.get(r)
        return move
    }

	//this will never be called
    return move
}
