/**
Mastermind from http://www.rosettacode.org/wiki/Mastermind
Translated from Dlang, which came from Kotlin, which was in turn translated from C++
*/

import rand
import readline { read_line }

//---------------------------
//code to make this similar to kotlin

fn next_int(range int) int {
	i := rand.intn(range) or {panic(err)}
	return i
}

//Kotlin function to make sure num is in the range
fn coerce_in(num int,min int,max int) int {
	if num < min {return min}
	else if num > max {return max}
	else {return num}
}

//take
//Returns a subsequence of this char sequence containing the first n characters from this char sequence, 
//or the entire char sequence if this char sequence is shorter.
fn take(str string,mylen int) string {
	if str.len < mylen {
		return str
	} else {
		return str[0 .. mylen]
	}
}

//-------------------------------------

struct Mastermind {
mut:
    code_len int
    colors_count int
    guess_count int 
    repeat_color bool
    colors string
    combo string 
 	guesses []string
 	results []string
}

// my_code_len:  the number of slots
// my_colors_count: the number of possible colors
// my_guess_count: the maximum number of guesses
// my_repeat_color: can you repeat a color?
fn new_mastermind(my_code_len int, my_colors_count int, my_guess_count int, my_repeat_color bool)  &Mastermind {
	mut mm := &Mastermind{}
	color := "ABCDEFGHIJKLMNOPQRST"
	mm.code_len = coerce_in(my_code_len,4, 10)
	// cl is not a good name for a variable, but this is what the source has
	mut cl := my_colors_count
	if !my_repeat_color && cl < mm.code_len { cl = mm.code_len}
	mm.colors_count = coerce_in(cl, 2, 20)
	mm.guess_count = coerce_in(my_guess_count, 7, 20)
	mm.repeat_color = my_repeat_color
	mm.colors = take(color, mm.colors_count)
	return mm
}

fn (mut m Mastermind) play()  {
	mut win := false
    m.combo = m.get_combo()
    for m.guess_count != 0 {
    	m.show_board()
        if m.check_input(m.get_input()) {
        	win = true
            break
        }
        m.guess_count--
    }
	println("\n\n--------------------------------")
    if win {
    	println("Very well done!\nYou found the code: $m.combo ")
    }
    else {
    	println("I am sorry, you couldn't make it!\nThe code was: $m.combo ")
    }
    println("--------------------------------")
}


fn (m Mastermind) show_board() {
	for x := 0; x < m.guesses.len; x++  {
		//debug
		//db := m.results[x]
		//println("[show_board] results: $db ");	
    	println("\n--------------------------------")
        print(x + 1)
        print(": ")
        for e in m.guesses[x] {
        	f := e.ascii_str()	//convert to string
        	print("$f ")
        }
        print(" :  ")
        for e in m.results[x] {
        	f := e.ascii_str()
        	print("$f ")
        }
        z := m.code_len - m.results[x].len
        if z > 0 {
            for i := 0; i < z; i++  { print("- ")}
        }
	}
    println("")
}


	//check to make sure all letters in input are in the set of colors
	//keep looping until true
fn (m Mastermind) get_input() string {
	for {
    	prompt := "Enter your guess (${m.colors}): "
        input := read_line(prompt) or {
        	println("empty line")
        	continue
        }    
        u := input.to_upper()
        alpha := take(u, m.code_len)
        //println("[get_input()] alpha: $alpha")
        //println("[get_input()] m.colors: $m.colors")
        alpha_bytes := alpha.bytes()
        mut ix := 0
        
        for c in alpha_bytes {
			ix = m.colors.index_u8(c)
        	if ix < 0 {break}
        }
        if ix > -1 {
        	return alpha
        } else {
        	println("Please re-enter your guess")
        }
	} //end for
	//this will never happen
	return "[get_input()] error"
}

fn (mut m Mastermind) check_input(a string) bool {
        //append a to guesses
        m.guesses << a
        mut black := 0
        mut white := 0
        
        mut gmatch := []bool{len: m.code_len, init: false}
        mut cmatch := []bool{len: m.code_len, init: false}
        for i :=0; i<m.code_len;i++ {
        	//byte comparison
        	if a[i] == m.combo[i] {
        		gmatch[i] = true
        		cmatch[i] = true
        		black++
        	}
        }
        for i :=0; i<m.code_len;i++ {
        	if gmatch[i] {continue}
        	for j:=0; j<m.code_len; j++ {
        		if i == j || cmatch[j] {continue}
        		if a[i] == m.combo[j] {
        			cmatch[j] = true
        			white++
        			break
        		}
        	}
        }

		mut r := []rune{}
		for i:=0; i<black;i++ {
			r << `X`	//note backticks for rune
		}
		for i:=0; i<white;i++ {
			r << `O`	//note backticks for rune
		}
		my_result := r.string()
		//println("[check_input] $my_result")
		m.results << my_result
		return black == m.code_len
}

fn (m Mastermind) get_combo() string {
	mut c := []u8{}
	mut my_colors := m.colors.bytes()
	
	for s:=0; s<m.code_len; s++ {
		z := next_int(my_colors.len)
		c << my_colors[z]
		if !m.repeat_color {
			my_colors.delete(z)
		}
	}
	return my_colors.bytestr()
}
 
//--------------------------

fn main() {
	mut mm := new_mastermind(4, 8, 12, false)
	mm.play()
}