{-# OPTIONS  --safe --without-K #-}

module Semantics.Category.EndoFunctor.Strong.Pointed where

open import Semantics.Category.Base
open import Semantics.Category.Cartesian
open import Semantics.Category.EndoFunctor.Base
open import Semantics.Category.EndoFunctor.Pointed
open import Semantics.Category.EndoFunctor.Strong.Base

open import Relation.Binary using (Reflexive; Symmetric; Transitive; IsEquivalence; Setoid)
import Relation.Binary.Reasoning.Setoid as EqReasoning

open import Level using (0ℓ ; suc)

record IsLStrongPointed ℓ {C : LCategory ℓ} {isCartesian : IsLCartesian ℓ C}
  (F : LEndoFunctor ℓ C) (isStrong : IsLStrong ℓ isCartesian F) (isPointed : IsLPointed ℓ F) : Set (suc ℓ) where
  open LCategory C
  open IsLCartesian isCartesian
  open LEndoFunctor F
  open IsLStrong isStrong renaming (red-dia' to red-dia1')
  open IsLPointed isPointed

  field
    strength-point : {P Q : Obj} → strength[ P , Q ] ∘ id'[ P ] ×'-map point[ Q ] ≈̇ point[ P ×' Q ]

  red-dia2' : {P Q R : Obj} → (φ : P →̇ Q) (ψ : P ×' Q →̇ R) → letin' (return' φ) ψ ≈̇  return' (ψ ∘ ⟨ id' , φ ⟩' )
  red-dia2' φ ψ = let open EqReasoning (→̇-setoid _ _) in begin
    (map ψ ∘ strength) ∘ ⟨ id' , point ∘ φ ⟩'
      ≈⟨ ∘-assoc _ _ _ ⟩
    map ψ ∘ strength ∘ ⟨ id' , point ∘ φ ⟩'
      ≈˘⟨ ∘-pres-≈̇-right _ (∘-pres-≈̇-right _ (⟨,⟩'-pres-≈̇-left (∘-unit-left _ _) _)) ⟩
    map ψ ∘ strength ∘ ⟨ id' ∘ id' , point ∘ φ ⟩'
      ≈˘⟨ ∘-pres-≈̇-right _ (∘-pres-≈̇-right _ (×'-map-∘-⟨,⟩' _ _ _ _)) ⟩
    map ψ ∘ strength ∘ ((id' ×'-map point) ∘ ⟨ id' , φ ⟩')
      ≈˘⟨ ∘-pres-≈̇-right _ (∘-assoc _ _ _) ⟩
    map ψ ∘ (strength ∘ (id' ×'-map point)) ∘ ⟨ id' , φ ⟩'
      ≈⟨ ∘-pres-≈̇-right _ (∘-pres-≈̇-left strength-point _) ⟩
    map ψ ∘ point ∘ ⟨ id' , φ ⟩'
      ≈˘⟨ ∘-assoc _ _ _ ⟩
    (map ψ ∘ point) ∘ ⟨ id' , φ ⟩'
      ≈˘⟨ ∘-pres-≈̇-left (point-natural ψ) _ ⟩
    (point ∘ ψ) ∘ ⟨ id' , φ ⟩'
      ≈⟨ ∘-assoc _ _ _ ⟩
    point ∘ ψ ∘ ⟨ id' , φ ⟩' ∎

IsStrongPointed = IsLStrongPointed (suc 0ℓ)
module IsStrongPointed = IsLStrongPointed
