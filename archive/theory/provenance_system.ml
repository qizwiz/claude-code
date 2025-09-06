
type ('a, 'b) prod =
| Pair of 'a * 'b

(** val fst : ('a1, 'a2) prod -> 'a1 **)

let fst = function
| Pair (x, _) -> x

(** val length : 'a1 list -> int **)

let rec length = function
| [] -> 0
| _::l' -> succ (length l')

(** val add : int -> int -> int **)

let rec add n m =
  (fun fO fS n -> if n=0 then fO () else fS (n-1))
    (fun _ -> m)
    (fun p -> succ (add p m))
    n

(** val mul : int -> int -> int **)

let rec mul n m =
  (fun fO fS n -> if n=0 then fO () else fS (n-1))
    (fun _ -> 0)
    (fun p -> add m (mul p m))
    n

(** val eqb : int -> int -> bool **)

let rec eqb n m =
  (fun fO fS n -> if n=0 then fO () else fS (n-1))
    (fun _ ->
    (fun fO fS n -> if n=0 then fO () else fS (n-1))
      (fun _ -> true)
      (fun _ -> false)
      m)
    (fun n' ->
    (fun fO fS n -> if n=0 then fO () else fS (n-1))
      (fun _ -> false)
      (fun m' -> eqb n' m')
      m)
    n

(** val leb : int -> int -> bool **)

let rec leb n m =
  (fun fO fS n -> if n=0 then fO () else fS (n-1))
    (fun _ -> true)
    (fun n' ->
    (fun fO fS n -> if n=0 then fO () else fS (n-1))
      (fun _ -> false)
      (fun m' -> leb n' m')
      m)
    n

(** val divmod : int -> int -> int -> int -> (int, int) prod **)

let rec divmod x y q u =
  (fun fO fS n -> if n=0 then fO () else fS (n-1))
    (fun _ -> Pair (q, u))
    (fun x' ->
    (fun fO fS n -> if n=0 then fO () else fS (n-1))
      (fun _ -> divmod x' y (succ q) y)
      (fun u' -> divmod x' y q u')
      u)
    x

(** val div : int -> int -> int **)

let div x y =
  (fun fO fS n -> if n=0 then fO () else fS (n-1))
    (fun _ -> y)
    (fun y' -> fst (divmod x y' 0 y'))
    y

(** val forallb : ('a1 -> bool) -> 'a1 list -> bool **)

let rec forallb f = function
| [] -> true
| a::l0 -> if f a then forallb f l0 else false

(** val filter : ('a1 -> bool) -> 'a1 list -> 'a1 list **)

let rec filter f = function
| [] -> []
| x::l0 -> if f x then x::(filter f l0) else filter f l0

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

(** val all_verified : provenanceChain -> bool **)

let all_verified chain =
  forallb (fun e -> e.verified) chain

(** val has_evidence : provenanceChain -> bool **)

let has_evidence = function
| [] -> false
| _::_ -> true

(** val calc_confidence : provenanceChain -> confidence **)

let calc_confidence chain =
  let verified_count = length (filter (fun e -> e.verified) chain) in
  let total_count = length chain in
  if eqb total_count 0
  then 0
  else div
         (mul verified_count (succ (succ (succ (succ (succ (succ (succ (succ
           (succ (succ (succ (succ (succ (succ (succ (succ (succ (succ (succ
           (succ (succ (succ (succ (succ (succ (succ (succ (succ (succ (succ
           (succ (succ (succ (succ (succ (succ (succ (succ (succ (succ (succ
           (succ (succ (succ (succ (succ (succ (succ (succ (succ (succ (succ
           (succ (succ (succ (succ (succ (succ (succ (succ (succ (succ (succ
           (succ (succ (succ (succ (succ (succ (succ (succ (succ (succ (succ
           (succ (succ (succ (succ (succ (succ (succ (succ (succ (succ (succ
           (succ (succ (succ (succ (succ (succ (succ (succ (succ (succ (succ
           (succ (succ (succ (succ
           0)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
         total_count

(** val verify_claim : config -> evidenceDB -> claim -> bool **)

let verify_claim config0 evidence_db claim0 =
  let chain = evidence_db claim0 in
  let has_ev = has_evidence chain in
  let all_ver = all_verified chain in
  let conf = calc_confidence chain in
  let meets_threshold = leb config0.confidence_threshold conf in
  if has_ev then if all_ver then meets_threshold else false else false

(** val lookup_evidence : claim -> provenanceChain **)

let lookup_evidence = function
| EmptyString -> []
| String (a, s) ->
  let Ascii (b, b0, b1, b2, b3, b4, b5, b6) = a in
  if b
  then if b0
       then if b1
            then []
            else if b2
                 then []
                 else if b3
                      then if b4
                           then []
                           else if b5
                                then if b6
                                     then []
                                     else (match s with
                                           | EmptyString -> []
                                           | String (a0, s0) ->
                                             let Ascii (b7, b8, b9, b10, b11,
                                                        b12, b13, b14) =
                                               a0
                                             in
                                             if b7
                                             then if b8
                                                  then []
                                                  else if b9
                                                       then if b10
                                                            then []
                                                            else if b11
                                                                 then []
                                                                 else 
                                                                   if b12
                                                                   then 
                                                                    if b13
                                                                    then 
                                                                    if b14
                                                                    then []
                                                                    else 
                                                                    (match s0 with
                                                                    | EmptyString ->
                                                                    []
                                                                    | String (
                                                                    a1, s1) ->
                                                                    let Ascii (
                                                                    b15, b16,
                                                                    b17, b18,
                                                                    b19, b20,
                                                                    b21, b22) =
                                                                    a1
                                                                    in
                                                                    if b15
                                                                    then []
                                                                    else 
                                                                    if b16
                                                                    then 
                                                                    if b17
                                                                    then 
                                                                    if b18
                                                                    then []
                                                                    else 
                                                                    if b19
                                                                    then 
                                                                    if b20
                                                                    then 
                                                                    if b21
                                                                    then 
                                                                    if b22
                                                                    then []
                                                                    else 
                                                                    (match s1 with
                                                                    | EmptyString ->
                                                                    []
                                                                    | String (
                                                                    a2, s2) ->
                                                                    let Ascii (
                                                                    b23, b24,
                                                                    b25, b26,
                                                                    b27, b28,
                                                                    b29, b30) =
                                                                    a2
                                                                    in
                                                                    if b23
                                                                    then 
                                                                    if b24
                                                                    then []
                                                                    else 
                                                                    if b25
                                                                    then 
                                                                    if b26
                                                                    then []
                                                                    else 
                                                                    if b27
                                                                    then []
                                                                    else 
                                                                    if b28
                                                                    then 
                                                                    if b29
                                                                    then 
                                                                    if b30
                                                                    then []
                                                                    else 
                                                                    (match s2 with
                                                                    | EmptyString ->
                                                                    []
                                                                    | String (
                                                                    a3, s3) ->
                                                                    let Ascii (
                                                                    b31, b32,
                                                                    b33, b34,
                                                                    b35, b36,
                                                                    b37, b38) =
                                                                    a3
                                                                    in
                                                                    if b31
                                                                    then []
                                                                    else 
                                                                    if b32
                                                                    then 
                                                                    if b33
                                                                    then []
                                                                    else 
                                                                    if b34
                                                                    then []
                                                                    else 
                                                                    if b35
                                                                    then 
                                                                    if b36
                                                                    then 
                                                                    if b37
                                                                    then 
                                                                    if b38
                                                                    then []
                                                                    else 
                                                                    (match s3 with
                                                                    | EmptyString ->
                                                                    []
                                                                    | String (
                                                                    a4, s4) ->
                                                                    let Ascii (
                                                                    b39, b40,
                                                                    b41, b42,
                                                                    b43, b44,
                                                                    b45, b46) =
                                                                    a4
                                                                    in
                                                                    if b39
                                                                    then 
                                                                    if b40
                                                                    then []
                                                                    else 
                                                                    if b41
                                                                    then []
                                                                    else 
                                                                    if b42
                                                                    then []
                                                                    else 
                                                                    if b43
                                                                    then []
                                                                    else 
                                                                    if b44
                                                                    then 
                                                                    if b45
                                                                    then 
                                                                    if b46
                                                                    then []
                                                                    else 
                                                                    (match s4 with
                                                                    | EmptyString ->
                                                                    []
                                                                    | String (
                                                                    a5, s5) ->
                                                                    let Ascii (
                                                                    b47, b48,
                                                                    b49, b50,
                                                                    b51, b52,
                                                                    b53, b54) =
                                                                    a5
                                                                    in
                                                                    if b47
                                                                    then []
                                                                    else 
                                                                    if b48
                                                                    then []
                                                                    else 
                                                                    if b49
                                                                    then 
                                                                    if b50
                                                                    then 
                                                                    if b51
                                                                    then []
                                                                    else 
                                                                    if b52
                                                                    then 
                                                                    if b53
                                                                    then 
                                                                    if b54
                                                                    then []
                                                                    else 
                                                                    (match s5 with
                                                                    | EmptyString ->
                                                                    []
                                                                    | String (
                                                                    a6, s6) ->
                                                                    let Ascii (
                                                                    b55, b56,
                                                                    b57, b58,
                                                                    b59, b60,
                                                                    b61, b62) =
                                                                    a6
                                                                    in
                                                                    if b55
                                                                    then []
                                                                    else 
                                                                    if b56
                                                                    then []
                                                                    else 
                                                                    if b57
                                                                    then []
                                                                    else 
                                                                    if b58
                                                                    then []
                                                                    else 
                                                                    if b59
                                                                    then []
                                                                    else 
                                                                    if b60
                                                                    then 
                                                                    if b61
                                                                    then []
                                                                    else 
                                                                    if b62
                                                                    then []
                                                                    else 
                                                                    (match s6 with
                                                                    | EmptyString ->
                                                                    []
                                                                    | String (
                                                                    a7, s7) ->
                                                                    let Ascii (
                                                                    b63, b64,
                                                                    b65, b66,
                                                                    b67, b68,
                                                                    b69, b70) =
                                                                    a7
                                                                    in
                                                                    if b63
                                                                    then 
                                                                    if b64
                                                                    then []
                                                                    else 
                                                                    if b65
                                                                    then 
                                                                    if b66
                                                                    then 
                                                                    if b67
                                                                    then []
                                                                    else 
                                                                    if b68
                                                                    then []
                                                                    else 
                                                                    if b69
                                                                    then 
                                                                    if b70
                                                                    then []
                                                                    else 
                                                                    (match s7 with
                                                                    | EmptyString ->
                                                                    []
                                                                    | String (
                                                                    a8, s8) ->
                                                                    let Ascii (
                                                                    b71, b72,
                                                                    b73, b74,
                                                                    b75, b76,
                                                                    b77, b78) =
                                                                    a8
                                                                    in
                                                                    if b71
                                                                    then 
                                                                    if b72
                                                                    then 
                                                                    if b73
                                                                    then []
                                                                    else 
                                                                    if b74
                                                                    then []
                                                                    else 
                                                                    if b75
                                                                    then []
                                                                    else 
                                                                    if b76
                                                                    then []
                                                                    else 
                                                                    if b77
                                                                    then 
                                                                    if b78
                                                                    then []
                                                                    else 
                                                                    (match s8 with
                                                                    | EmptyString ->
                                                                    []
                                                                    | String (
                                                                    a9, s9) ->
                                                                    let Ascii (
                                                                    b79, b80,
                                                                    b81, b82,
                                                                    b83, b84,
                                                                    b85, b86) =
                                                                    a9
                                                                    in
                                                                    if b79
                                                                    then []
                                                                    else 
                                                                    if b80
                                                                    then []
                                                                    else 
                                                                    if b81
                                                                    then []
                                                                    else 
                                                                    if b82
                                                                    then []
                                                                    else 
                                                                    if b83
                                                                    then 
                                                                    if b84
                                                                    then []
                                                                    else 
                                                                    if b85
                                                                    then 
                                                                    if b86
                                                                    then []
                                                                    else 
                                                                    (match s9 with
                                                                    | EmptyString ->
                                                                    []
                                                                    | String (
                                                                    a10, s10) ->
                                                                    let Ascii (
                                                                    b87, b88,
                                                                    b89, b90,
                                                                    b91, b92,
                                                                    b93, b94) =
                                                                    a10
                                                                    in
                                                                    if b87
                                                                    then []
                                                                    else 
                                                                    if b88
                                                                    then []
                                                                    else 
                                                                    if b89
                                                                    then []
                                                                    else 
                                                                    if b90
                                                                    then []
                                                                    else 
                                                                    if b91
                                                                    then []
                                                                    else 
                                                                    if b92
                                                                    then 
                                                                    if b93
                                                                    then []
                                                                    else 
                                                                    if b94
                                                                    then []
                                                                    else 
                                                                    (match s10 with
                                                                    | EmptyString ->
                                                                    []
                                                                    | String (
                                                                    a11, s11) ->
                                                                    let Ascii (
                                                                    b95, b96,
                                                                    b97, b98,
                                                                    b99,
                                                                    b100,
                                                                    b101, b102) =
                                                                    a11
                                                                    in
                                                                    if b95
                                                                    then 
                                                                    if b96
                                                                    then 
                                                                    if b97
                                                                    then []
                                                                    else 
                                                                    if b98
                                                                    then []
                                                                    else 
                                                                    if b99
                                                                    then 
                                                                    if b100
                                                                    then 
                                                                    if b101
                                                                    then 
                                                                    if b102
                                                                    then []
                                                                    else 
                                                                    (match s11 with
                                                                    | EmptyString ->
                                                                    []
                                                                    | String (
                                                                    a12, s12) ->
                                                                    let Ascii (
                                                                    b103,
                                                                    b104,
                                                                    b105,
                                                                    b106,
                                                                    b107,
                                                                    b108,
                                                                    b109, b110) =
                                                                    a12
                                                                    in
                                                                    if b103
                                                                    then 
                                                                    if b104
                                                                    then []
                                                                    else 
                                                                    if b105
                                                                    then 
                                                                    if b106
                                                                    then []
                                                                    else 
                                                                    if b107
                                                                    then []
                                                                    else 
                                                                    if b108
                                                                    then 
                                                                    if b109
                                                                    then 
                                                                    if b110
                                                                    then []
                                                                    else 
                                                                    (match s12 with
                                                                    | EmptyString ->
                                                                    []
                                                                    | String (
                                                                    a13, s13) ->
                                                                    let Ascii (
                                                                    b111,
                                                                    b112,
                                                                    b113,
                                                                    b114,
                                                                    b115,
                                                                    b116,
                                                                    b117, b118) =
                                                                    a13
                                                                    in
                                                                    if b111
                                                                    then []
                                                                    else 
                                                                    if b112
                                                                    then 
                                                                    if b113
                                                                    then []
                                                                    else 
                                                                    if b114
                                                                    then []
                                                                    else 
                                                                    if b115
                                                                    then 
                                                                    if b116
                                                                    then 
                                                                    if b117
                                                                    then 
                                                                    if b118
                                                                    then []
                                                                    else 
                                                                    (match s13 with
                                                                    | EmptyString ->
                                                                    []
                                                                    | String (
                                                                    a14, s14) ->
                                                                    let Ascii (
                                                                    b119,
                                                                    b120,
                                                                    b121,
                                                                    b122,
                                                                    b123,
                                                                    b124,
                                                                    b125, b126) =
                                                                    a14
                                                                    in
                                                                    if b119
                                                                    then []
                                                                    else 
                                                                    if b120
                                                                    then 
                                                                    if b121
                                                                    then 
                                                                    if b122
                                                                    then []
                                                                    else 
                                                                    if b123
                                                                    then 
                                                                    if b124
                                                                    then 
                                                                    if b125
                                                                    then 
                                                                    if b126
                                                                    then []
                                                                    else 
                                                                    (match s14 with
                                                                    | EmptyString ->
                                                                    []
                                                                    | String (
                                                                    a15, s15) ->
                                                                    let Ascii (
                                                                    b127,
                                                                    b128,
                                                                    b129,
                                                                    b130,
                                                                    b131,
                                                                    b132,
                                                                    b133, b134) =
                                                                    a15
                                                                    in
                                                                    if b127
                                                                    then 
                                                                    if b128
                                                                    then []
                                                                    else 
                                                                    if b129
                                                                    then 
                                                                    if b130
                                                                    then []
                                                                    else 
                                                                    if b131
                                                                    then []
                                                                    else 
                                                                    if b132
                                                                    then 
                                                                    if b133
                                                                    then 
                                                                    if b134
                                                                    then []
                                                                    else 
                                                                    (match s15 with
                                                                    | EmptyString ->
                                                                    []
                                                                    | String (
                                                                    a16, s16) ->
                                                                    let Ascii (
                                                                    b135,
                                                                    b136,
                                                                    b137,
                                                                    b138,
                                                                    b139,
                                                                    b140,
                                                                    b141, b142) =
                                                                    a16
                                                                    in
                                                                    if b135
                                                                    then []
                                                                    else 
                                                                    if b136
                                                                    then 
                                                                    if b137
                                                                    then []
                                                                    else 
                                                                    if b138
                                                                    then []
                                                                    else 
                                                                    if b139
                                                                    then 
                                                                    if b140
                                                                    then 
                                                                    if b141
                                                                    then 
                                                                    if b142
                                                                    then []
                                                                    else 
                                                                    (match s16 with
                                                                    | EmptyString ->
                                                                    []
                                                                    | String (
                                                                    a17, s17) ->
                                                                    let Ascii (
                                                                    b143,
                                                                    b144,
                                                                    b145,
                                                                    b146,
                                                                    b147,
                                                                    b148,
                                                                    b149, b150) =
                                                                    a17
                                                                    in
                                                                    if b143
                                                                    then 
                                                                    if b144
                                                                    then 
                                                                    if b145
                                                                    then []
                                                                    else 
                                                                    if b146
                                                                    then []
                                                                    else 
                                                                    if b147
                                                                    then 
                                                                    if b148
                                                                    then 
                                                                    if b149
                                                                    then 
                                                                    if b150
                                                                    then []
                                                                    else 
                                                                    (match s17 with
                                                                    | EmptyString ->
                                                                    []
                                                                    | String (
                                                                    a18, s18) ->
                                                                    let Ascii (
                                                                    b151,
                                                                    b152,
                                                                    b153,
                                                                    b154,
                                                                    b155,
                                                                    b156,
                                                                    b157, b158) =
                                                                    a18
                                                                    in
                                                                    if b151
                                                                    then []
                                                                    else 
                                                                    if b152
                                                                    then []
                                                                    else 
                                                                    if b153
                                                                    then []
                                                                    else 
                                                                    if b154
                                                                    then []
                                                                    else 
                                                                    if b155
                                                                    then []
                                                                    else 
                                                                    if b156
                                                                    then 
                                                                    if b157
                                                                    then []
                                                                    else 
                                                                    if b158
                                                                    then []
                                                                    else 
                                                                    (match s18 with
                                                                    | EmptyString ->
                                                                    []
                                                                    | String (
                                                                    a19, s19) ->
                                                                    let Ascii (
                                                                    b159,
                                                                    b160,
                                                                    b161,
                                                                    b162,
                                                                    b163,
                                                                    b164,
                                                                    b165, b166) =
                                                                    a19
                                                                    in
                                                                    if b159
                                                                    then 
                                                                    if b160
                                                                    then []
                                                                    else 
                                                                    if b161
                                                                    then 
                                                                    if b162
                                                                    then []
                                                                    else 
                                                                    if b163
                                                                    then []
                                                                    else 
                                                                    if b164
                                                                    then 
                                                                    if b165
                                                                    then 
                                                                    if b166
                                                                    then []
                                                                    else 
                                                                    (match s19 with
                                                                    | EmptyString ->
                                                                    []
                                                                    | String (
                                                                    a20, s20) ->
                                                                    let Ascii (
                                                                    b167,
                                                                    b168,
                                                                    b169,
                                                                    b170,
                                                                    b171,
                                                                    b172,
                                                                    b173, b174) =
                                                                    a20
                                                                    in
                                                                    if b167
                                                                    then []
                                                                    else 
                                                                    if b168
                                                                    then []
                                                                    else 
                                                                    if b169
                                                                    then []
                                                                    else 
                                                                    if b170
                                                                    then 
                                                                    if b171
                                                                    then 
                                                                    if b172
                                                                    then 
                                                                    if b173
                                                                    then 
                                                                    if b174
                                                                    then []
                                                                    else 
                                                                    (match s20 with
                                                                    | EmptyString ->
                                                                    []
                                                                    | String (
                                                                    a21, s21) ->
                                                                    let Ascii (
                                                                    b175,
                                                                    b176,
                                                                    b177,
                                                                    b178,
                                                                    b179,
                                                                    b180,
                                                                    b181, b182) =
                                                                    a21
                                                                    in
                                                                    if b175
                                                                    then 
                                                                    if b176
                                                                    then []
                                                                    else 
                                                                    if b177
                                                                    then []
                                                                    else 
                                                                    if b178
                                                                    then 
                                                                    if b179
                                                                    then []
                                                                    else 
                                                                    if b180
                                                                    then 
                                                                    if b181
                                                                    then 
                                                                    if b182
                                                                    then []
                                                                    else 
                                                                    (match s21 with
                                                                    | EmptyString ->
                                                                    []
                                                                    | String (
                                                                    a22, s22) ->
                                                                    let Ascii (
                                                                    b183,
                                                                    b184,
                                                                    b185,
                                                                    b186,
                                                                    b187,
                                                                    b188,
                                                                    b189, b190) =
                                                                    a22
                                                                    in
                                                                    if b183
                                                                    then 
                                                                    if b184
                                                                    then 
                                                                    if b185
                                                                    then []
                                                                    else 
                                                                    if b186
                                                                    then []
                                                                    else 
                                                                    if b187
                                                                    then 
                                                                    if b188
                                                                    then 
                                                                    if b189
                                                                    then 
                                                                    if b190
                                                                    then []
                                                                    else 
                                                                    (match s22 with
                                                                    | EmptyString ->
                                                                    []
                                                                    | String (
                                                                    a23, s23) ->
                                                                    let Ascii (
                                                                    b191,
                                                                    b192,
                                                                    b193,
                                                                    b194,
                                                                    b195,
                                                                    b196,
                                                                    b197, b198) =
                                                                    a23
                                                                    in
                                                                    if b191
                                                                    then []
                                                                    else 
                                                                    if b192
                                                                    then []
                                                                    else 
                                                                    if b193
                                                                    then 
                                                                    if b194
                                                                    then []
                                                                    else 
                                                                    if b195
                                                                    then 
                                                                    if b196
                                                                    then 
                                                                    if b197
                                                                    then 
                                                                    if b198
                                                                    then []
                                                                    else 
                                                                    (match s23 with
                                                                    | EmptyString ->
                                                                    { content =
                                                                    (String
                                                                    ((Ascii
                                                                    (true,
                                                                    true,
                                                                    true,
                                                                    false,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (true,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (false,
                                                                    false,
                                                                    true,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (false,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (true,
                                                                    false,
                                                                    true,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (false,
                                                                    true,
                                                                    false,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (false,
                                                                    false,
                                                                    false,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    false,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (false,
                                                                    true,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (true,
                                                                    false,
                                                                    true,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (false,
                                                                    false,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (true,
                                                                    true,
                                                                    true,
                                                                    true,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (false,
                                                                    false,
                                                                    false,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    false,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (false,
                                                                    false,
                                                                    true,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (true,
                                                                    false,
                                                                    true,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (false,
                                                                    true,
                                                                    true,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (true,
                                                                    true,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (false,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (true,
                                                                    false,
                                                                    false,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (false,
                                                                    true,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (true,
                                                                    true,
                                                                    false,
                                                                    true,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (true,
                                                                    true,
                                                                    true,
                                                                    true,
                                                                    false,
                                                                    true,
                                                                    false,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (false,
                                                                    true,
                                                                    true,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (true,
                                                                    false,
                                                                    false,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (true,
                                                                    true,
                                                                    false,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (false,
                                                                    false,
                                                                    true,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (true,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    false,
                                                                    true,
                                                                    false,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (true,
                                                                    true,
                                                                    false,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (false,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (true,
                                                                    false,
                                                                    true,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (true,
                                                                    true,
                                                                    false,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (true,
                                                                    true,
                                                                    false,
                                                                    true,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (true,
                                                                    false,
                                                                    true,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (false,
                                                                    true,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (true,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    false,
                                                                    true,
                                                                    false,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (true,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (true,
                                                                    true,
                                                                    false,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (false,
                                                                    false,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (false,
                                                                    false,
                                                                    false,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    false,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (false,
                                                                    true,
                                                                    true,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (true,
                                                                    false,
                                                                    true,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (false,
                                                                    true,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (true,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (false,
                                                                    true,
                                                                    true,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (true,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (true,
                                                                    false,
                                                                    true,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (false,
                                                                    false,
                                                                    true,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    EmptyString))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))));
                                                                    source_url =
                                                                    (String
                                                                    ((Ascii
                                                                    (false,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (false,
                                                                    false,
                                                                    true,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (false,
                                                                    false,
                                                                    true,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (false,
                                                                    false,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (true,
                                                                    true,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (false,
                                                                    true,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    true,
                                                                    false,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (true,
                                                                    true,
                                                                    true,
                                                                    true,
                                                                    false,
                                                                    true,
                                                                    false,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (true,
                                                                    true,
                                                                    true,
                                                                    true,
                                                                    false,
                                                                    true,
                                                                    false,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (true,
                                                                    true,
                                                                    true,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (true,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (false,
                                                                    false,
                                                                    true,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (false,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (true,
                                                                    false,
                                                                    true,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (false,
                                                                    true,
                                                                    false,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (false,
                                                                    true,
                                                                    true,
                                                                    true,
                                                                    false,
                                                                    true,
                                                                    false,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (true,
                                                                    true,
                                                                    false,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (true,
                                                                    true,
                                                                    true,
                                                                    true,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (true,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (true,
                                                                    true,
                                                                    true,
                                                                    true,
                                                                    false,
                                                                    true,
                                                                    false,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (false,
                                                                    false,
                                                                    true,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (true,
                                                                    false,
                                                                    true,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (false,
                                                                    true,
                                                                    true,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (true,
                                                                    true,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (false,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (true,
                                                                    false,
                                                                    false,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (false,
                                                                    true,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (true,
                                                                    true,
                                                                    false,
                                                                    true,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (true,
                                                                    true,
                                                                    true,
                                                                    true,
                                                                    false,
                                                                    true,
                                                                    false,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (false,
                                                                    true,
                                                                    true,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (true,
                                                                    false,
                                                                    false,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (true,
                                                                    true,
                                                                    false,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (false,
                                                                    false,
                                                                    true,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (true,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    false,
                                                                    true,
                                                                    false,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (true,
                                                                    true,
                                                                    false,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (false,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (true,
                                                                    false,
                                                                    true,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (true,
                                                                    true,
                                                                    false,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (true,
                                                                    true,
                                                                    false,
                                                                    true,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (true,
                                                                    false,
                                                                    true,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (false,
                                                                    true,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (true,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    false,
                                                                    true,
                                                                    false,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (true,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (true,
                                                                    true,
                                                                    false,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    (String
                                                                    ((Ascii
                                                                    (false,
                                                                    false,
                                                                    false,
                                                                    false,
                                                                    true,
                                                                    true,
                                                                    true,
                                                                    false)),
                                                                    EmptyString))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))));
                                                                    verified =
                                                                    true;
                                                                    timestamp =
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    (succ
                                                                    0)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))) }::[]
                                                                    | String (
                                                                    _, _) ->
                                                                    [])
                                                                    else []
                                                                    else []
                                                                    else []
                                                                    else [])
                                                                    else []
                                                                    else []
                                                                    else []
                                                                    else []
                                                                    else [])
                                                                    else []
                                                                    else []
                                                                    else []
                                                                    else [])
                                                                    else []
                                                                    else []
                                                                    else []
                                                                    else [])
                                                                    else []
                                                                    else []
                                                                    else []
                                                                    else [])
                                                                    else [])
                                                                    else []
                                                                    else []
                                                                    else []
                                                                    else []
                                                                    else [])
                                                                    else []
                                                                    else []
                                                                    else []
                                                                    else [])
                                                                    else []
                                                                    else []
                                                                    else []
                                                                    else [])
                                                                    else []
                                                                    else []
                                                                    else []
                                                                    else []
                                                                    else [])
                                                                    else []
                                                                    else []
                                                                    else []
                                                                    else [])
                                                                    else []
                                                                    else []
                                                                    else []
                                                                    else [])
                                                                    else []
                                                                    else []
                                                                    else []
                                                                    else []
                                                                    else [])
                                                                    else [])
                                                                    else []
                                                                    else [])
                                                                    else []
                                                                    else []
                                                                    else [])
                                                                    else []
                                                                    else []
                                                                    else []
                                                                    else [])
                                                                    else [])
                                                                    else []
                                                                    else []
                                                                    else []
                                                                    else [])
                                                                    else []
                                                                    else []
                                                                    else [])
                                                                    else []
                                                                    else []
                                                                    else []
                                                                    else [])
                                                                    else []
                                                                    else []
                                                                    else []
                                                                    else [])
                                                                    else []
                                                                    else []
                                                                    else []
                                                                    else []
                                                                    else [])
                                                                    else []
                                                                   else []
                                                       else []
                                             else [])
                                else []
                      else []
       else []
  else []

(** val check_claim : claim -> (bool, string) prod **)

let check_claim claim0 =
  let config0 = { confidence_threshold = (succ (succ (succ (succ (succ (succ
    (succ (succ (succ (succ (succ (succ (succ (succ (succ (succ (succ (succ
    (succ (succ (succ (succ (succ (succ (succ (succ (succ (succ (succ (succ
    (succ (succ (succ (succ (succ (succ (succ (succ (succ (succ (succ (succ
    (succ (succ (succ (succ (succ (succ (succ (succ (succ (succ (succ (succ
    (succ (succ (succ (succ (succ (succ (succ (succ (succ (succ (succ (succ
    (succ (succ (succ (succ (succ (succ (succ (succ (succ (succ (succ (succ
    (succ (succ
    0))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))));
    require_verification = true }
  in
  let result = verify_claim config0 lookup_evidence claim0 in
  let message =
    if result
    then String ((Ascii (false, true, false, false, false, true, true,
           true)), (String ((Ascii (false, false, true, true, true, false,
           false, true)), (String ((Ascii (true, false, true, false, false,
           false, false, true)), (String ((Ascii (false, false, false, false,
           false, true, false, false)), (String ((Ascii (true, true, false,
           false, false, false, true, false)), (String ((Ascii (false, false,
           true, true, false, true, true, false)), (String ((Ascii (true,
           false, false, false, false, true, true, false)), (String ((Ascii
           (true, false, false, true, false, true, true, false)), (String
           ((Ascii (true, false, true, true, false, true, true, false)),
           (String ((Ascii (false, false, false, false, false, true, false,
           false)), (String ((Ascii (false, true, true, false, true, true,
           true, false)), (String ((Ascii (true, false, true, false, false,
           true, true, false)), (String ((Ascii (false, true, false, false,
           true, true, true, false)), (String ((Ascii (true, false, false,
           true, false, true, true, false)), (String ((Ascii (false, true,
           true, false, false, true, true, false)), (String ((Ascii (true,
           false, false, true, false, true, true, false)), (String ((Ascii
           (true, false, true, false, false, true, true, false)), (String
           ((Ascii (false, false, true, false, false, true, true, false)),
           (String ((Ascii (false, false, false, false, false, true, false,
           false)), (String ((Ascii (true, true, true, false, true, true,
           true, false)), (String ((Ascii (true, false, false, true, false,
           true, true, false)), (String ((Ascii (false, false, true, false,
           true, true, true, false)), (String ((Ascii (false, false, false,
           true, false, true, true, false)), (String ((Ascii (false, false,
           false, false, false, true, false, false)), (String ((Ascii (true,
           true, false, false, true, true, true, false)), (String ((Ascii
           (true, false, true, false, true, true, true, false)), (String
           ((Ascii (false, true, true, false, false, true, true, false)),
           (String ((Ascii (false, true, true, false, false, true, true,
           false)), (String ((Ascii (true, false, false, true, false, true,
           true, false)), (String ((Ascii (true, true, false, false, false,
           true, true, false)), (String ((Ascii (true, false, false, true,
           false, true, true, false)), (String ((Ascii (true, false, true,
           false, false, true, true, false)), (String ((Ascii (false, true,
           true, true, false, true, true, false)), (String ((Ascii (false,
           false, true, false, true, true, true, false)), (String ((Ascii
           (false, false, false, false, false, true, false, false)), (String
           ((Ascii (true, false, true, false, false, true, true, false)),
           (String ((Ascii (false, true, true, false, true, true, true,
           false)), (String ((Ascii (true, false, false, true, false, true,
           true, false)), (String ((Ascii (false, false, true, false, false,
           true, true, false)), (String ((Ascii (true, false, true, false,
           false, true, true, false)), (String ((Ascii (false, true, true,
           true, false, true, true, false)), (String ((Ascii (true, true,
           false, false, false, true, true, false)), (String ((Ascii (true,
           false, true, false, false, true, true, false)),
           EmptyString)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
    else String ((Ascii (false, true, false, false, false, true, true,
           true)), (String ((Ascii (true, false, true, true, true, false,
           false, true)), (String ((Ascii (false, false, true, true, false,
           false, false, true)), (String ((Ascii (false, false, false, false,
           false, true, false, false)), (String ((Ascii (true, true, false,
           false, false, false, true, false)), (String ((Ascii (false, false,
           true, true, false, true, true, false)), (String ((Ascii (true,
           false, false, false, false, true, true, false)), (String ((Ascii
           (true, false, false, true, false, true, true, false)), (String
           ((Ascii (true, false, true, true, false, true, true, false)),
           (String ((Ascii (false, false, false, false, false, true, false,
           false)), (String ((Ascii (false, false, true, true, false, true,
           true, false)), (String ((Ascii (true, false, false, false, false,
           true, true, false)), (String ((Ascii (true, true, false, false,
           false, true, true, false)), (String ((Ascii (true, true, false,
           true, false, true, true, false)), (String ((Ascii (true, true,
           false, false, true, true, true, false)), (String ((Ascii (false,
           false, false, false, false, true, false, false)), (String ((Ascii
           (true, true, false, false, true, true, true, false)), (String
           ((Ascii (true, false, true, false, true, true, true, false)),
           (String ((Ascii (false, true, true, false, false, true, true,
           false)), (String ((Ascii (false, true, true, false, false, true,
           true, false)), (String ((Ascii (true, false, false, true, false,
           true, true, false)), (String ((Ascii (true, true, false, false,
           false, true, true, false)), (String ((Ascii (true, false, false,
           true, false, true, true, false)), (String ((Ascii (true, false,
           true, false, false, true, true, false)), (String ((Ascii (false,
           true, true, true, false, true, true, false)), (String ((Ascii
           (false, false, true, false, true, true, true, false)), (String
           ((Ascii (false, false, false, false, false, true, false, false)),
           (String ((Ascii (false, true, true, false, true, true, true,
           false)), (String ((Ascii (true, false, true, false, false, true,
           true, false)), (String ((Ascii (false, true, false, false, true,
           true, true, false)), (String ((Ascii (true, false, false, true,
           false, true, true, false)), (String ((Ascii (false, true, true,
           false, false, true, true, false)), (String ((Ascii (true, false,
           false, true, false, true, true, false)), (String ((Ascii (true,
           false, true, false, false, true, true, false)), (String ((Ascii
           (false, false, true, false, false, true, true, false)), (String
           ((Ascii (false, false, false, false, false, true, false, false)),
           (String ((Ascii (true, false, true, false, false, true, true,
           false)), (String ((Ascii (false, true, true, false, true, true,
           true, false)), (String ((Ascii (true, false, false, true, false,
           true, true, false)), (String ((Ascii (false, false, true, false,
           false, true, true, false)), (String ((Ascii (true, false, true,
           false, false, true, true, false)), (String ((Ascii (false, true,
           true, true, false, true, true, false)), (String ((Ascii (true,
           true, false, false, false, true, true, false)), (String ((Ascii
           (true, false, true, false, false, true, true, false)),
           EmptyString)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
  in
  Pair (result, message)

(** val example_verified_claim : (bool, string) prod **)

let example_verified_claim =
  check_claim (String ((Ascii (true, true, false, false, true, false, true,
    false)), (String ((Ascii (true, false, true, false, false, true, true,
    false)), (String ((Ascii (false, true, true, false, true, true, true,
    false)), (String ((Ascii (true, false, true, false, false, true, true,
    false)), (String ((Ascii (false, true, false, false, true, true, true,
    false)), (String ((Ascii (true, false, false, false, false, true, true,
    false)), (String ((Ascii (false, false, true, true, false, true, true,
    false)), (String ((Ascii (false, false, false, false, false, true, false,
    false)), (String ((Ascii (true, false, true, true, false, false, true,
    false)), (String ((Ascii (true, true, false, false, false, false, true,
    false)), (String ((Ascii (false, false, false, false, true, false, true,
    false)), (String ((Ascii (false, false, false, false, false, true, false,
    false)), (String ((Ascii (true, true, false, false, true, true, true,
    false)), (String ((Ascii (true, false, true, false, false, true, true,
    false)), (String ((Ascii (false, true, false, false, true, true, true,
    false)), (String ((Ascii (false, true, true, false, true, true, true,
    false)), (String ((Ascii (true, false, true, false, false, true, true,
    false)), (String ((Ascii (false, true, false, false, true, true, true,
    false)), (String ((Ascii (true, true, false, false, true, true, true,
    false)), (String ((Ascii (false, false, false, false, false, true, false,
    false)), (String ((Ascii (true, false, true, false, false, true, true,
    false)), (String ((Ascii (false, false, false, true, true, true, true,
    false)), (String ((Ascii (true, false, false, true, false, true, true,
    false)), (String ((Ascii (true, true, false, false, true, true, true,
    false)), (String ((Ascii (false, false, true, false, true, true, true,
    false)), EmptyString))))))))))))))))))))))))))))))))))))))))))))))))))

(** val example_unverified_claim : (bool, string) prod **)

let example_unverified_claim =
  check_claim (String ((Ascii (true, false, false, false, false, false, true,
    false)), (String ((Ascii (true, false, false, true, false, false, true,
    false)), (String ((Ascii (false, false, false, false, false, true, false,
    false)), (String ((Ascii (true, true, true, false, true, true, true,
    false)), (String ((Ascii (true, false, false, true, false, true, true,
    false)), (String ((Ascii (false, false, true, true, false, true, true,
    false)), (String ((Ascii (false, false, true, true, false, true, true,
    false)), (String ((Ascii (false, false, false, false, false, true, false,
    false)), (String ((Ascii (true, true, false, false, true, true, true,
    false)), (String ((Ascii (true, true, true, true, false, true, true,
    false)), (String ((Ascii (false, false, true, true, false, true, true,
    false)), (String ((Ascii (false, true, true, false, true, true, true,
    false)), (String ((Ascii (true, false, true, false, false, true, true,
    false)), (String ((Ascii (false, false, false, false, false, true, false,
    false)), (String ((Ascii (true, false, false, false, false, true, true,
    false)), (String ((Ascii (false, false, true, true, false, true, true,
    false)), (String ((Ascii (false, false, true, true, false, true, true,
    false)), (String ((Ascii (false, false, false, false, false, true, false,
    false)), (String ((Ascii (false, false, false, false, true, true, true,
    false)), (String ((Ascii (false, true, false, false, true, true, true,
    false)), (String ((Ascii (true, true, true, true, false, true, true,
    false)), (String ((Ascii (false, true, false, false, false, true, true,
    false)), (String ((Ascii (false, false, true, true, false, true, true,
    false)), (String ((Ascii (true, false, true, false, false, true, true,
    false)), (String ((Ascii (true, false, true, true, false, true, true,
    false)), (String ((Ascii (true, true, false, false, true, true, true,
    false)), (String ((Ascii (false, false, false, false, false, true, false,
    false)), (String ((Ascii (false, false, true, false, true, true, true,
    false)), (String ((Ascii (true, true, true, true, false, true, true,
    false)), (String ((Ascii (true, false, true, true, false, true, true,
    false)), (String ((Ascii (true, true, true, true, false, true, true,
    false)), (String ((Ascii (false, true, false, false, true, true, true,
    false)), (String ((Ascii (false, true, false, false, true, true, true,
    false)), (String ((Ascii (true, true, true, true, false, true, true,
    false)), (String ((Ascii (true, true, true, false, true, true, true,
    false)),
    EmptyString))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
