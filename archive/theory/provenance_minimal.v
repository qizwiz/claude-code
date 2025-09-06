(* Minimal Provenance Architecture Proof *)

From Stdlib Require Import Bool.

(* Core definitions *)
Definition Claim := bool.
Definition Evidence := bool.

Record ProvenanceSystem := {
  has_evidence : Claim -> bool;
  evidence_verified : Claim -> bool
}.

(* Assertion predicate: can only assert claims with verified evidence *)
Definition assertable (sys : ProvenanceSystem) (c : Claim) : bool :=
  andb (has_evidence sys c) (evidence_verified sys c).

(* MAIN THEOREM: Safety property *)
Theorem claim_safety :
  forall (sys : ProvenanceSystem) (c : Claim),
    assertable sys c = true ->
    evidence_verified sys c = true.
Proof.
  intros sys c H_assertable.
  unfold assertable in H_assertable.
  apply andb_true_iff in H_assertable.
  destruct H_assertable as [H_has H_verified].
  exact H_verified.
Qed.

(* SOUNDNESS: Unverified claims cannot be asserted *)
Theorem no_unverified_assertions :
  forall (sys : ProvenanceSystem) (c : Claim),
    evidence_verified sys c = false ->
    assertable sys c = false.
Proof.
  intros sys c H_unverified.
  unfold assertable.
  rewrite H_unverified.
  destruct (has_evidence sys c); simpl; reflexivity.
Qed.

(* DEMONSTRATION: Our conversation example *)
Definition conversation_system := {|
  has_evidence := fun c => c;  (* true = "I found search results" *)
  evidence_verified := fun c => negb c  (* false = "but didn't verify them" *)
|}.

Definition mcp_claim := true.  (* "Several MCP servers exist" *)

(* Proof that unverified claims are blocked *)
Example unverified_blocked :
  assertable conversation_system mcp_claim = false.
Proof.
  unfold assertable.
  simpl.
  reflexivity.
Qed.

(* Only verified claims can be asserted *)
Definition verified_system := {|
  has_evidence := fun c => c;
  evidence_verified := fun c => c  (* Actually verified *)
|}.

Example verified_allowed :
  assertable verified_system mcp_claim = true.
Proof.
  unfold assertable.
  simpl.
  reflexivity.
Qed.

(* META-PROOF: This prevents the exact problem in our conversation *)
Theorem prevents_false_claims :
  forall (sys : ProvenanceSystem),
    (forall c, assertable sys c = true -> evidence_verified sys c = true) ->
    (forall c, evidence_verified sys c = false -> assertable sys c = false).
Proof.
  intros sys H_safety c H_unverified.
  destruct (assertable sys c) eqn:E.
  - (* If assertable, then verified by safety *)
    apply H_safety in E.
    rewrite H_unverified in E.
    discriminate.
  - (* If not assertable, we're done *)
    reflexivity.
Qed.