type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal	;;

let rec combine_one rules nt  = 
	match rules with
	|[] -> []
	|(expr,rule)::tails -> if nt = expr then rule::(combine_one tails nt)
						 else combine_one tails nt

let convert_grammar g =
	match g with
	|e,rules -> e, (combine_one rules)


let accept_all derivation string = Some (derivation, string)
let accept_empty_suffix derivation = function
   | [] -> Some (derivation, [])
   | _ -> None

let rec match_terminate make_a_matcher g rhs accept d frag =
	match rhs with
	|[] -> accept d frag
	|head::tails-> match frag with
    		| [] -> None
    		| h::t -> match head with
    			|N x -> make_a_matcher g x (g x) (match_terminate make_a_matcher g tails accept) d frag
    			|T x -> if h = x then (match_terminate make_a_matcher g tails accept d t)
    					else None

let rec or_matcher g nt rhs accept d frag = 
	match rhs with 
	|[] -> None
	|head::tail -> 
		let head_matcher = match_terminate or_matcher g head accept (d@[(nt, head)]) frag 
		and tail_matcher = or_matcher g nt tail accept d frag
		in match head_matcher with
			|Some ok -> Some ok
			|None -> tail_matcher

let parse_prefix (s,g) accept frag =
	or_matcher g s (g s) accept [] frag