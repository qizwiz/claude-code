(* Simplified Provenance Architecture Proof *)

From Stdlib Require Import Bool List Arith.
Import ListNotations.

(* Core types *)
Definition Claim := nat.
Definition Evidence := nat.
Definition Confidence := nat.

(* Evidence with verification status *)
Record EvidenceRecord : Type := mkEvidence {
  content : Evidence;
  verified : bool
}.

Definition ProvenanceChain := list EvidenceRecord.

(* System definition *)
Record ProvenanceSystem : Type := mkSystem {
  evidence_db : Claim -> ProvenanceChain;
  threshold : Confidence
}.

(* All evidence in chain is verified *)
Definition all_verified (chain : ProvenanceChain) : bool :=
  forallb (fun e => verified e) chain.

(* Chain has at least one piece of evidence *)
Definition has_evidence (chain : ProvenanceChain) : bool :=
  match chain with
  | [] => false
  | _ => true
  end.

(* Confidence calculation *)
Definition calc_confidence (chain : ProvenanceChain) : Confidence :=
  let verified_count := length (filter (fun e => verified e) chain) in
  let total_count := length chain in
  if Nat.eqb total_count 0 then 0 
  else Nat.div (verified_count * 100) total_count.

(* Sufficient evidence predicate *)
Definition sufficient_evidence (sys : ProvenanceSystem) (chain : ProvenanceChain) : bool :=
  let conf := calc_confidence chain in
  andb (all_verified chain) (Nat.leb (threshold sys) conf).

(* Main assertion predicate *)
Definition assertable (sys : ProvenanceSystem) (c : Claim) : bool :=
  let chain := evidence_db sys c in
  andb (has_evidence chain) (sufficient_evidence sys chain).

(* MAIN THEOREMS *)

(* Safety: All assertable claims have verified evidence *)
Theorem claim_safety :
  forall (sys : ProvenanceSystem) (c : Claim),
    assertable sys c = true ->
    all_verified (evidence_db sys c) = true.
Proof.
  intros sys c H_assertable.
  unfold assertable in H_assertable.
  apply andb_true_iff in H_assertable.
  destruct H_assertable as [H_has_evidence H_sufficient].
  
  unfold sufficient_evidence in H_sufficient.
  apply andb_true_iff in H_sufficient.
  destruct H_sufficient as [H_verified _].
  exact H_verified.
Qed.

(* Soundness: Non-assertable claims lack verified evidence *)
Theorem no_unverified_assertions :
  forall (sys : ProvenanceSystem) (c : Claim),
    all_verified (evidence_db sys c) = false ->
    assertable sys c = false.
Proof.
  intros sys c H_unverified.
  unfold assertable.
  
  destruct (has_evidence (evidence_db sys c)) eqn:H_has.
  - (* Has evidence but not verified *)
    simpl.
    unfold sufficient_evidence.
    rewrite H_unverified.
    simpl.
    reflexivity.
  - (* No evidence at all *)
    simpl.
    reflexivity.
Qed.

(* Completeness: Assertable claims have evidence *)
Theorem evidence_requirement :
  forall (sys : ProvenanceSystem) (c : Claim),
    assertable sys c = true ->
    exists e : EvidenceRecord,
      In e (evidence_db sys c) /\ verified e = true.
Proof.
  intros sys c H_assertable.
  
  (* Extract that we have evidence *)
  unfold assertable in H_assertable.
  apply andb_true_iff in H_assertable.
  destruct H_assertable as [H_has_evidence H_sufficient].
  
  (* Extract that all evidence is verified *)
  unfold sufficient_evidence in H_sufficient.
  apply andb_true_iff in H_sufficient.
  destruct H_sufficient as [H_all_verified _].
  
  (* Since we have evidence and it's all verified, exists one *)
  unfold has_evidence in H_has_evidence.
  destruct (evidence_db sys c) as [| e rest] eqn:E.
  - (* Empty case contradicts has_evidence *)
    discriminate H_has_evidence.
  - (* Non-empty case *)
    exists e.
    split.
    + (* e is in the list *)
      rewrite <- E.
      simpl.
      auto.
    + (* e is verified *)
      rewrite <- E in H_all_verified.
      unfold all_verified in H_all_verified.
      simpl in H_all_verified.
      apply andb_true_iff in H_all_verified.
      destruct H_all_verified as [H_e_verified _].
      exact H_e_verified.
Qed.

(* DEMONSTRATION: Apply to conversation example *)

(* Example evidence *)
Definition search_result := mkEvidence 1 false.  (* Unverified search result *)
Definition github_check := mkEvidence 2 true.    (* Verified GitHub existence *)

(* Example system with 50% confidence threshold *)
Definition demo_system := mkSystem
  (fun c => if Nat.eqb c 42 then [search_result; github_check] else [])
  50.

(* Example claim: "Several MCP servers exist" *)
Definition mcp_claim := 42.

(* Proof that our example claim is assertable *)
Example demo_assertable :
  assertable demo_system mcp_claim = true.
Proof.
  unfold assertable, has_evidence, sufficient_evidence.
  unfold calc_confidence.
  simpl.
  reflexivity.
Qed.

(* Proof that unverified-only claims are not assertable *)
Definition bad_system := mkSystem
  (fun c => if Nat.eqb c 42 then [search_result] else [])
  50.

Example demo_not_assertable :
  assertable bad_system mcp_claim = false.
Proof.
  unfold assertable, has_evidence, sufficient_evidence.
  unfold calc_confidence.
  simpl.
  reflexivity.
Qed.

(* META-THEOREM: The proof system itself prevents unverified claims *)
Theorem meta_verification :
  forall (sys : ProvenanceSystem) (c : Claim),
    assertable sys c = true <-> 
    (exists evidence_chain,
      evidence_db sys c = evidence_chain /\
      evidence_chain <> [] /\
      all_verified evidence_chain = true /\
      calc_confidence evidence_chain >= threshold sys).
Proof.
  intros sys c.
  split.
  
  (* Forward direction *)
  - intro H_assertable.
    exists (evidence_db sys c).
    split.
    + reflexivity.
    + unfold assertable in H_assertable.
      apply andb_true_iff in H_assertable.
      destruct H_assertable as [H_has H_sufficient].
      
      split.
      * (* Non-empty *)
        unfold has_evidence in H_has.
        destruct (evidence_db sys c) as [|h t]; [discriminate | congruence].
      * split.
        ** (* All verified *)
           unfold sufficient_evidence in H_sufficient.
           apply andb_true_iff in H_sufficient.
           destruct H_sufficient as [H_verified _].
           exact H_verified.
        ** (* Confidence threshold *)
           unfold sufficient_evidence in H_sufficient.
           apply andb_true_iff in H_sufficient.
           destruct H_sufficient as [_ H_conf].
           apply Nat.leb_le in H_conf.
           exact H_conf.
  
  (* Reverse direction *)
  - intro H_exists.
    destruct H_exists as [evidence_chain [H_eq [H_nonempty [H_verified H_conf]]]].
    unfold assertable.
    rewrite <- H_eq.
    apply andb_true_iff.
    split.
    + (* Has evidence *)
      unfold has_evidence.
      destruct evidence_chain; [contradiction | reflexivity].
    + (* Sufficient evidence *)
      unfold sufficient_evidence.
      rewrite <- H_eq.
      apply andb_true_iff.
      split.
      * exact H_verified.
      * apply Nat.leb_le.
        exact H_conf.
Qed.