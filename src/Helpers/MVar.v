Require Extraction.
From Classes Require Import Classes.
From Array Require Export Array.
From stdpp Require Import countable.

Set Implicit Arguments.


Axiom mvar : Type -> Type.

(* Should not use these in code that will be extracted, they're just to be able
   to use them with various type classes that expect countability, solely for modeling
   semantics of operations *)
Declare Instance mvar_dec : EqDecision {T : Type & mvar T}.
Declare Instance mvar_countable : Countable {T : Type & mvar T}.

Extraction Language Haskell.

Extract Constant mvar "a" => "Control.Concurrent.MVar a".

(*
Definition test : mvar bool -> mvar bool := id.
Recursive Extraction test.
*)
