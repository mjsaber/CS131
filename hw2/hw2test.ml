
type awksub_nonterminals =
   | Expr | Term | Lvalue | Incrop | Binop | Num

type giant_nonterminals =
  | Conversation | Sentence | Grunt | Snore | Shout | Quiet

let giant_grammar =
  (Conversation,
  [Conversation, [N Sentence; T","; N Conversation];
   Conversation, [N Snore];
   Conversation, [N Sentence; N Sentence];
     Sentence, [N Quiet];
   Sentence, [N Grunt];
   Sentence, [N Shout];
   Sentence, [N Snore];
  Snore, [T"ZZZ"];
   Quiet, [T"hmm?"];
   Grunt, [T"khrgh"];
   Shout, [T"aooogah!"]])

let gg = convert_grammar giant_grammar
let test_1 =
	((parse_prefix gg accept_all ["ZZZ";",";"ZZZ";",";"hmm?";"aooogah!"]) 
		= Some
 	([(Conversation, [N Sentence; T ","; N Conversation]);
   (Sentence, [N Snore]); (Snore, [T "ZZZ"]);
   (Conversation, [N Sentence; T ","; N Conversation]);
   (Sentence, [N Snore]); (Snore, [T "ZZZ"]);
   (Conversation, [N Sentence; N Sentence]); (Sentence, [N Quiet]);
   (Quiet, [T "hmm?"]); (Sentence, [N Shout]); (Shout, [T "aooogah!"])],[]))

type english_nonterminals =
  | Expr | Art | Adj | Adv | VerbPh | NounPh | Noun | Verb |Sentence |Period

let eng_grammar =
   (Sentence,
   	[
   	Sentence,[N Expr; T",";N Sentence];
   	Sentence,[N Expr; N Period];
   	Period,[T"."];
   	Expr, [N NounPh; N Verb; N Adj];
   	Expr, [N Adj; N Noun];
    Expr, [N Adj; N NounPh; N VerbPh];
    Expr, [N NounPh; N VerbPh];
    VerbPh, [N Adv; N Verb];
    VerbPh, [N Verb; N Adv];
    VerbPh, [N Verb; N Verb];
    VerbPh, [N Verb];
    NounPh, [N Art; N Noun];
    NounPh, [N Noun];
    Adj, [T "beautiful"];
    Adj, [T "slut"];
    Adj, [N Art; N Adj];
    Art, [T "a"];
    Noun, [T "man"];
    Noun, [T "woman"];
    Verb, [T "love"];
    Verb, [T "make"];
    Verb, [T "listens"];
    Adv, [T "quietly"];
    Adv, [T "loudly"]]
	)

 let eg = convert_grammar eng_grammar

let test_2 = 
 ((parse_prefix eg accept_all ["man";"love";"slut";",";"beautiful";"woman";"."]) = Some
 ([(Sentence, [N Expr; T ","; N Sentence]);
   (Expr, [N NounPh; N Verb; N Adj]); (NounPh, [N Noun]); (Noun, [T "man"]);
   (Verb, [T "love"]); (Adj, [T "slut"]); (Sentence, [N Expr; N Period]);
   (Expr, [N Adj; N Noun]); (Adj, [T "beautiful"]); (Noun, [T "woman"]);
   (Period, [T "."])],
  []))

