// modified from https://rosettacode.org/wiki/100_doors#Go

fn main() {
	//use an array of 101, because 0 is not used
    mut doors := [101]bool{}

    // the 100 passes called for in the task description
    for pass := 1; pass < 101; pass++ {
        for door := pass; door < 101; door += pass {
            doors[door] = !doors[door]
        }
    }

    // one more pass to answer the question
    for i in 1..101 {
    	if doors[i] {
    		print("1")
    	} else {
    		print("0")
    	}
    
        if i%10 == 0 {
            println("")
        } else {
            print(" ")
        }
    }
}