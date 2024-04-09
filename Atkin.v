// Sieve of Atkin
// see https://en.wikipedia.org/wiki/Sieve_of_Atkin
// This calculates all the prime numbers below the given limit
import os
import strconv
import math

fn sieve_of_atkin(limit int ) []bool {
	root := math.sqrt( f64(limit))
	sqrt_max := int(root) +1
	
	mut barray := []bool{ len: limit, cap: limit, init: false}
		
    for x := 1; x < sqrt_max; x++
    {
        for y := 1; y < sqrt_max; y++
        {
 			//group 1
 			mut k := (4 * x * x) + (y * y)

    		if (k < limit) && ((k % 12 == 1) || (k % 12 == 5)) {
    			barray[k]=!barray[k]
    		}

    		//group 2
      		k = 3 * x * x + y * y;
    		if (k < limit) && (k % 12 == 7) {
    			barray[k]=!barray[k]
    		}

    		//group 3
			if x > y {
				k = 3 * x * x - y * y
			    if (k < limit) && (k % 12 == 11) {
			    	barray[k]=!barray[k]
				}
			}
		}
	}

	//final clean up
	barray[2]=true
	barray[3]=true
	for n := 5; n <= sqrt_max; n++ {
		b := barray[n]
		if b {
			n2 := n * n
	    	for k := n2; k < limit; k += n2 {
	    		barray[k]=false
	    	}
		}
	}
	return barray
}


//==================
fn main() {
	arg1 := os.args[1]
	println("$arg1")
	limit := strconv.atoi(arg1) or {panic(arg1)}
	ba := sieve_of_atkin(limit)

	for i :=2; i<limit; i++ {
		if ba[i] {
			print("$i ")
		}
	}
	println(" ")
}