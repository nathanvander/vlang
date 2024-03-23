// Hamurabi
// For background see: https://en.wikipedia.org/wiki/Hamurabi_(video_game)
// 
// Note that the game has only 1 m, because they had to fit it into 8 characters
// but the historical king had 2 mm's

import rand
import readline { read_line }
import strconv

fn get_random(range int) int {
	i := rand.intn(range) or {panic(err)}
	return i
}

//input a number.  Return -1 if err
fn input_number(prompt string) int {
	input := read_line(prompt) or {panic(err)}
	i := strconv.atoi(input) or {
		println("$input isn't a valid number")
		return -1 
	}
	return i
}

fn get_number(prompt string) int {
	mut n := -1
	n = input_number(prompt)
	//loop unti we get a valid number
	for n < 0  {
		n = input_number("Please enter a number")
	}
	return n
}

fn jest(message string) {
	println("$ogh, surely you jest!")
    println(message)
}
	
//---------------------------
const ogh = "O Great Hammurabi!"

//Sumeria class
struct Sumeria {
mut:
	year int
	population int 
	grain int 
	acres int 
	land_value int 
	starved int 
	percent_starved int 
	plague_victims int 
	immigrants int 
	grain_harvested int 
	harvest_per_acre int 
	amount_eaten_by_rats int 
	grain_fed_to_people int 
	acres_planted int 
}

fn new_sumeria() &Sumeria {
	return &Sumeria{}
}

// Initialize all instance variables for start of game.
// I use 'g' for either global or game
fn (mut g Sumeria) init() {
	g.year = 1
    g.population = 100
    g.grain = 3800		//2800;
    g.acres = 1000
    //make this dynamic
    g.update_land_value()
    
    g.starved = 0
    g.plague_victims = 0
    g.immigrants = 5
    g.grain_harvested = 4000
    g.harvest_per_acre = 4
    g.amount_eaten_by_rats = 200
}

fn (mut g Sumeria) print_summary() {
        println("___________________________________________________________________")
        println(ogh)
        println("You are in year $g.year of your ten year rule.")
        if g.plague_victims > 0 {
            println("A horrible plague killed $g.plague_victims people.")
        }
        println("In the previous year $g.starved people starved to death,")
        println("and $g.immigrants people entered the kingdom.")
        println("Sumeria now has $g.population people.")
        println("We harvested $g.grain_harvested bushels at $g.harvest_per_acre bushels per acre.")
        if g.amount_eaten_by_rats > 0 {
            println("*** Rats destroyed $g.amount_eaten_by_rats bushels, leaving $g.grain bushels in storage.")
            //reset
            g.amount_eaten_by_rats = 0
        } else {
            println("We have $g.grain bushels of grain in storage.")
        }
        println("The city owns $g.acres acres of land.")
        println("Land is currently worth $g.land_value bushels per acre.")
        println("___________________________________________________________________")
}

fn (mut g Sumeria) buy_land() {
	mut acres_to_buy := 0
    question := "How many acres of land will you buy? "
	acres_to_buy = get_number(question)
	mut cost := g.land_value * acres_to_buy
	for cost > g.grain {
    	jest("We have but $g.grain bushels of grain, not $cost !")	
		acres_to_buy = get_number(question)
		cost = g.land_value * acres_to_buy
	}
	g.grain = g.grain - cost
    g.acres = g.acres + acres_to_buy
    println("$ogh,  you now have $g.acres acres of land")
    println("and $g.grain bushels of grain.")
}

fn (mut g Sumeria) sell_land() {
	mut acres_to_sell := 0
	question := "How many acres of land will you sell? "
	acres_to_sell = get_number(question)
	mut proceeds := g.land_value * acres_to_sell
	for acres_to_sell > g.acres {
    	jest("We have but $g.acres acres!")
        acres_to_sell = get_number(question)
        proceeds = g.land_value * acres_to_sell
    }
	g.grain = g.grain + proceeds
    g.acres = g.acres - acres_to_sell
  	println("$ogh,  you now have $g.acres acres of land")
   	println("and $g.grain bushels of grain.")
}

fn (mut g Sumeria) feed_people() {
    question := "How much grain will you feed to the people? "
    mut suggested := g.population * 20
    if suggested > g.grain - g.calc_optimum_grain_to_plant() {
    	suggested = g.grain - g.calc_optimum_grain_to_plant()
    }
    
	println(question)
    println("(Suggested amount: $suggested)")
    g.grain_fed_to_people = get_number("?")
	for g.grain_fed_to_people > g.grain {
		jest("We have but $g.grain bushels!")
    	g.grain_fed_to_people = get_number(question)
    }
    
    if g.grain_fed_to_people < g.population * 20 {
    	shortfall := g.population * 20 - g.grain_fed_to_people
    	will_starve := shortfall / 20
    	println("($ogh you will let $will_starve people starve to death.)")
    }
    
    g.grain = g.grain - g.grain_fed_to_people
    println("$ogh, $g.grain bushels of grain remain.")
}

fn (mut g Sumeria) calc_optimum_grain_to_plant() int {
	//ideally plant this much
	mut sugg := g.acres * 2
	//but if not enough people plant less
	if g.population < g.acres / 10 {
		sugg = g.population *20 
	}
	//limited by the amount of grain left
	if sugg > g.grain {
		sugg = g.grain
	}
	return sugg
}

fn (mut g Sumeria) plant_grain() {
	mut amount_to_plant := 0
    question := "How many bushels will you plant? "
    mut suggested := g.calc_optimum_grain_to_plant()
	mut good_answer := false
	println(question)
	println("(Suggested amount: $suggested)")
	amount_to_plant = get_number("?")
	
	for !good_answer {
		//the first time through we just use a question mark and assume the answer is good
		good_answer = true		
		if amount_to_plant > g.grain {
        	jest("We have but $g.grain bushels left!")
        	good_answer = false
        } else if amount_to_plant > 2 * g.acres {
        	jest("We have but $g.acres acres available for planting!")
        	good_answer = false
        } else if amount_to_plant > 20 * g.population {
            jest("We have but $g.population people to do the planting!")
            good_answer = false
        } 
        if !good_answer {
        	println("$ogh, please try again - $question")
        }
     }
     g.acres_planted = amount_to_plant / 2
     g.grain = g.grain - amount_to_plant
     println("$ogh, we now have $g.grain bushels of grain in storage.")
}

fn (mut g Sumeria) check_for_plague() {
	chance := get_random(100)
    if chance < 15 {
        println("*** A horrible plague kills half your people! ***")
        g.plague_victims = g.population / 2
        g.population = g.population - g.plague_victims
     } else {
        g.plague_victims = 0
     }
}

fn (mut g Sumeria) count_starved_people() {
	people_fed := g.grain_fed_to_people / 20
	if people_fed >= g.population {
		g.starved = 0
        g.percent_starved = 0
        println("Your people are well fed and happy.")
    } else {
        g.starved = g.population - people_fed
        println("$g.starved people starved to death.")
        g.percent_starved = (100 * g.starved) / g.population
        g.population = g.population - g.starved
    }
}

fn (mut g Sumeria) count_immigrants() {
	if g.starved > 0 {
    	g.immigrants = 0;
     } else {
     	g.immigrants = (20 * g.acres + g.grain) / (100 * g.population) + 1
        g.population += g.immigrants
     }
}

fn (mut g Sumeria) take_in_harvest() {
	g.harvest_per_acre = get_random(5) + 1
    g.grain_harvested = g.harvest_per_acre * g.acres_planted
    g.grain = g.grain + g.grain_harvested
}

//there is a 40% chance of a rat infestation
fn (mut g Sumeria) check_for_rats() {
    if get_random(100) < 40 {
    	percent_eaten_by_rats := 10 + get_random(21)
    	println("*** Rats eat $percent_eaten_by_rats percent of your grain! ***");
        g.amount_eaten_by_rats = g.grain * percent_eaten_by_rats / 100
        println("$g.amount_eaten_by_rats bushels of grain are gone")
        g.grain = g.grain - g.amount_eaten_by_rats
     } else {
     	g.amount_eaten_by_rats = 0
     }
}

fn (mut g Sumeria) update_land_value() {
	g.land_value = 17 + get_random(9)
}

fn (mut g Sumeria) print_final_score() {
     mut score := g.acres
     if 20 * g.population < score {
     	score = 20 * g.population
     }

    if g.starved >= (45 * g.population / 100) {
    	println("O Once-Great Hammurabi")
		println("$g.starved of your people starved during the last year of your")
		println("incompetent reign! The few who remain have stormed the palace")
        println("and bodily evicted you!")
        println("Your final score: ${score} . Your final rating: TERRIBLE.")
        return
     }

     if score < 600 {
            println("Congratulations, $ogh")
            println("You have ruled wisely but not well; you have led your people")
            println("through ten difficult years, but your kingdom has shrunk")
            println("to a mere $g.acres acres.")
            println("Your final score: ${score} .  Your final rating: ADEQUATE.")
     } else if score < 800 {
            println("Congratulations, $ogh .  You have ruled wisely and adequately and")
            println("shown the ancient world that a stable economy is possible.")
            println("Your final score: ${score} . Your final rating: GOOD.")
     } else {
            println("Congratulations, $ogh .  You have ruled wisely and very well and")
            println("expanded your holdings while keeping your people happy.")
            println("Altogether, a most impressive job!")
            println("Your final score: ${score} . Your final rating: SUPERB.")
     }
}


//-----------------------------------
	//main method
fn main() {
	intro()
	play_game()
}

	//starts with an homage to the basic source code
fn intro() {
	text := ("
HAMURABI 
CREATIVE COMPUTING  MORRISTOWN, NEW JERSEY.

Congratulations! You are the newest ruler of ancient Samaria,
elected for a ten year term of office. Your duties are to
dispense food, direct farming, and buy and sell land as
needed to support your people. Watch out for rat infestations
and the plague! Grain is the general currency, measured in
bushels.

The following will help you in your decisions:                
   * Each person needs at least 20 bushels of grain per year to survive
   * Each person can farm at most 10 acres of land
   * It takes 2 bushels of grain to farm an acre of land
   * The market price for land fluctuates yearly
     
Rule wisely and you will be showered with appreciation at the
end of your term. Rule poorly and you will be kicked out of office!
		")
	println(text)
}

	//--------------------------------
	//play the game
fn play_game() {
		mut g := new_sumeria()
   	 	mut still_in_office := true

        g.init()
        g.print_summary()
        for g.year < 10 && still_in_office {
        	g.year = g.year + 1
            g.buy_land()
            g.sell_land()
            g.feed_people()
            g.plant_grain()

            g.check_for_plague()
            g.count_starved_people()
            if g.percent_starved >= 45 {
                still_in_office = false
            }
            g.count_immigrants()
            g.take_in_harvest()
            g.check_for_rats()
            g.update_land_value()
            g.print_summary()
        }
        g.print_final_score()
}

