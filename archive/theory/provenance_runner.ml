open Provenance_system

(* Convert OCaml string to Coq string *)
let rec string_of_ocaml s =
  if String.length s = 0 then EmptyString
  else String (char_of_ocaml s.[0], string_of_ocaml (String.sub s 1 (String.length s - 1)))

and char_of_ocaml c =
  let code = Char.code c in
  Ascii ((code land 1) != 0,
         (code land 2) != 0,
         (code land 4) != 0,
         (code land 8) != 0,
         (code land 16) != 0,
         (code land 32) != 0,
         (code land 64) != 0,
         (code land 128) != 0)

(* Main function to test claims *)
let test_claim claim =
  Printf.printf "Testing claim: \"%s\"\n" claim;
  let coq_claim = string_of_ocaml claim in
  let result = check_claim coq_claim in
  let (verified, msg) = get_result result in
  Printf.printf "Result: %s\n" msg;
  Printf.printf "Verified: %b\n\n" verified;
  verified

(* Test cases *)
let () =
  Printf.printf "🔍 PROVENANCE VERIFICATION SYSTEM\n";
  Printf.printf "================================\n\n";
  
  (* Test verified claim *)
  let claim1 = "Several MCP servers exist" in
  let result1 = test_claim claim1 in
  
  (* Test unverified claim *)  
  let claim2 = "AI will solve all problems tomorrow" in
  let result2 = test_claim claim2 in
  
  (* Summary *)
  Printf.printf "📊 SUMMARY:\n";
  Printf.printf "Claim 1 (\"%s\"): %s\n" claim1 (if result1 then "✅ VERIFIED" else "❌ BLOCKED");
  Printf.printf "Claim 2 (\"%s\"): %s\n" claim2 (if result2 then "✅ VERIFIED" else "❌ BLOCKED");
  
  Printf.printf "\n🎯 This demonstrates the mathematical model preventing unverified claims!\n"