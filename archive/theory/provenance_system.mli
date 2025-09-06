
type ('a, 'b) prod =
| Pair of 'a * 'b

val fst : ('a1, 'a2) prod -> 'a1

val length : 'a1 list -> int

val add : int -> int -> int

val mul : int -> int -> int

val eqb : int -> int -> bool

val leb : int -> int -> bool

val divmod : int -> int -> int -> int -> (int, int) prod

val div : int -> int -> int

val forallb : ('a1 -> bool) -> 'a1 list -> bool

val filter : ('a1 -> bool) -> 'a1 list -> 'a1 list

type ascii =
| Ascii of bool * bool * bool * bool * bool * bool * bool * bool

type string =
| EmptyString
| String of ascii * string

type claim = string

type evidence = string

type confidence = int

type evidenceRecord = { content : evidence; source_url : string;
                        verified : bool; timestamp : int }

type provenanceChain = evidenceRecord list

type config = { confidence_threshold : confidence; require_verification : bool }

type evidenceDB = claim -> provenanceChain

val all_verified : provenanceChain -> bool

val has_evidence : provenanceChain -> bool

val calc_confidence : provenanceChain -> confidence

val verify_claim : config -> evidenceDB -> claim -> bool

val lookup_evidence : claim -> provenanceChain

val check_claim : claim -> (bool, string) prod

val example_verified_claim : (bool, string) prod

val example_unverified_claim : (bool, string) prod
