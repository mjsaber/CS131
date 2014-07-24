type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal	;;

let rec subset a b = 
	match a with
	|[]->true
	|x::res->if List.mem x b then subset res b
			else false;;

let equal_sets a b = 
	subset a b && subset b a;;

let proper_subset a b =
	subset a b && not (equal_sets a b);;

let rec set_diff a b =
	match a with
	|[] -> []
	|x::res -> if List.mem x b then set_diff res b
				else x::set_diff res b;;

let rec computed_fixed_point eq f x =
	if eq (f x) x then x
else computed_fixed_point eq f (f x);;

let compose f g = fun x -> f (g x);;

let rec power f n = 
  	if n = 1 then f
  	else compose f (power f (n-1));;

(* let computed_periodic_point eq f p x = 
	if p = 0 then x
	else computed_fixed_point eq (power f p) x;; *)

let rec computed_periodic_point eq f p x = 
	if p = 0 then x
	else if eq (power f p x) x then x
    else computed_periodic_point eq f p (f x);;

let predicteExists elem = function
	|fst,snd -> if fst = elem then true
				else false;;

let rec rhsIsT rhs rules = 
	match rhs with
	|[] -> true
	|h::res -> match h with				
				|N e -> if List.exists (predicteExists e) rules then rhsIsT res rules
						else false
				|T _ -> rhsIsT res rules;;

let rec addToTlist rules tlist =
	match rules with
	|[] -> tlist
	|h::res -> match h with
				|_,rhs -> if rhsIsT rhs tlist && not (List.mem h tlist) then h::addToTlist res tlist
							else addToTlist res tlist ;;

let rec reorderList oldrules newrules rules =
	match rules with
	|[] -> newrules
	|h::res -> if List.mem h oldrules then h::reorderList oldrules newrules res
				else reorderList oldrules newrules res;;

let filter_blind_alleys g =
	match g with
	|exp,rules -> exp,reorderList (computed_fixed_point equal_sets (addToTlist rules) []) [] rules;;
