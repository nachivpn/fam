{-# OPTIONS  --safe --without-K #-}

module Semantics.Category.EndoFunctor.Strong.Multiplicative where

open import Semantics.Category.Base
open import Semantics.Category.Cartesian
open import Semantics.Category.EndoFunctor.Base
open import Semantics.Category.EndoFunctor.Multiplicative
open import Semantics.Category.EndoFunctor.Strong.Base

open import Relation.Binary using (Reflexive; Symmetric; Transitive; IsEquivalence; Setoid)
import Relation.Binary.Reasoning.Setoid as EqReasoning

record IsStrongMultiplicative {C : Category} {isCartesian : IsCartesian C}
  (F : EndoFunctor C) (isStrong : IsStrong isCartesian F) (isMultiplicative : IsMultiplicative F) : Set₂ where
  open Category C
  open IsCartesian isCartesian
  open EndoFunctor F
  open IsStrong isStrong renaming (letin' to sletin' ; letin'-nat₂ to sletin'-nat₂)
  open IsMultiplicative isMultiplicative

  field
    strength-mult :{P Q : Obj} → mult[ P ×' Q ] ∘ map (strength[ P , Q ]) ∘ strength[ P , ℱ' Q ]
      ≈̇ strength[ P , Q ] ∘ (id'[ P ] ×'-map mult[ Q ])

  letin' : {P Q R : Obj} (φ : P →̇ ℱ' Q) → (ψ : (P ×' Q) →̇ ℱ' R) → P →̇ ℱ' R
  letin' {_} {_} {R} φ ψ = mult[ R ] ∘ sletin' φ ψ

  abstract
    comm-dia' : {P Q R S : Obj} (φ : P →̇ ℱ' Q) (ψ : (P ×' Q) →̇ ℱ' R) (ϕ : (P ×' R) →̇ ℱ' S)
      → sletin' (letin' φ ψ) ϕ ≈̇ letin' φ (sletin' ψ (ϕ ∘ (π₁' ×'-map id')))
    comm-dia' {P} {Q} {R} {S} φ ψ ϕ = let
      f : P →̇ ℱ' (P ×' Q)
      f = strength[ P , Q ] ∘ ⟨ id' , φ ⟩'
      open EqReasoning (→̇-setoid P (ℱ' ℱ' S)) in begin
      sletin' (letin' φ ψ) ϕ
        -- defn.
        ≡⟨⟩
      (map ϕ ∘ strength) ∘ ⟨ id' , mult ∘ sletin' φ ψ ⟩'
        -- cartesian crunching
        ≈˘⟨ ∘-pres-≈̇-right _ (≈̇-trans (×'-map-∘-⟨,⟩' _ _ _ _) (⟨,⟩'-pres-≈̇-left (id'-unit-left _ _) _)) ⟩
      (map ϕ ∘ strength) ∘ id' ×'-map mult ∘ ⟨ id' , sletin' φ ψ ⟩'
        -- assoc
        ≈⟨ ≈̇-trans (∘-assoc _ _ _) (∘-pres-≈̇-right _ (≈̇-sym (∘-assoc _ _ _ ))) ⟩
      map ϕ ∘ (strength[ P , R ] ∘ id' ×'-map mult) ∘ ⟨ id' , sletin' φ ψ ⟩'
        -- strong multiplicative
        ≈˘⟨ ∘-pres-≈̇-right _ (∘-pres-≈̇-left strength-mult _) ⟩
      map ϕ ∘ (mult[ P ×' R ]  ∘ map strength[ P , R ] ∘ strength[ P , ℱ' R ]) ∘ ⟨ id' , sletin' φ ψ ⟩'
        -- assoc.
        ≈⟨ ∘-pres-≈̇-right _ (∘-assoc _ _ _) ⟩
      map ϕ ∘ mult  ∘ (map strength[ P , R ] ∘ strength) ∘ ⟨ id' , sletin' φ ψ ⟩'
        -- defn.
        ≡⟨⟩
      map ϕ ∘ mult  ∘ sletin' (sletin' φ ψ) strength
        -- strength
        ≈⟨ ∘-pres-≈̇-right _ (∘-pres-≈̇-right _ (red-dia' _ _ _)) ⟩
      map ϕ ∘ mult ∘ sletin' φ (strength ∘ ⟨ π₁' , ψ ⟩')
        -- defn.
        ≡⟨⟩
      map ϕ ∘ mult ∘ ((map (strength ∘ ⟨ π₁' , ψ ⟩') ∘ strength) ∘ ⟨ id' , φ ⟩')
        -- assoc.
        ≈⟨ ∘-pres-≈̇-right _ (∘-pres-≈̇-right _ (∘-assoc _ _ _)) ⟩
      map ϕ ∘ mult  ∘ map (strength ∘ ⟨ π₁' , ψ ⟩') ∘ (strength) ∘ ⟨ id' , φ ⟩'
        -- defn.
        ≡⟨⟩
      map ϕ ∘ mult  ∘ map (strength ∘ ⟨ π₁' , ψ ⟩') ∘ f
        -- assoc.
          ≈˘⟨ ∘-pres-≈̇-right _ (∘-assoc _ _ _) ⟩
      map ϕ ∘ (mult ∘ map (strength ∘ ⟨ π₁' , ψ ⟩')) ∘ f
        -- cartesian crunching
        ≈˘⟨ ∘-pres-≈̇-right _ (∘-pres-≈̇-left (∘-pres-≈̇-right _ (map-pres-≈̇ (∘-pres-≈̇-right _
             (≈̇-trans (×'-map-∘-⟨,⟩' _ _ _ _) (⟨,⟩'-pres-≈̇ (id'-unit-right _ _) (id'-unit-left _ _)))))) _) ⟩
      map ϕ ∘ (mult ∘ map (strength ∘ ((π₁' ×'-map id') ∘ ⟨ id' , ψ ⟩'))) ∘ f
        -- functoriality
        ≈⟨ ∘-pres-≈̇-right _ (∘-pres-≈̇-left (∘-pres-≈̇-right _ (≈̇-trans
             (map-pres-∘ _ _)
             (≈̇-trans (∘-pres-≈̇-right _ (map-pres-∘ _ _)) (≈̇-sym (∘-assoc _ _ _))))) _) ⟩
      map ϕ ∘ (mult ∘ (map (strength) ∘ map (π₁' ×'-map id')) ∘ (map ⟨ id' , ψ ⟩')) ∘ f
        -- strength
        ≈⟨ ∘-pres-≈̇-right _ (∘-pres-≈̇-left (∘-pres-≈̇-right _ (∘-pres-≈̇-left (≈̇-trans
             (≈̇-sym (map-pres-∘ _ _))
             (≈̇-trans (map-pres-≈̇ (strength-natural₁ _)) (map-pres-∘ _ _))) _)) _) ⟩
      map ϕ ∘ (mult ∘ (map (map (π₁' ×'-map id')) ∘ (map strength)) ∘ (map ⟨ id' , ψ ⟩')) ∘ f
        -- assoc.
        ≈⟨ ∘-pres-≈̇-right _ (≈̇-trans
             (∘-assoc _ _ _) (≈̇-trans (∘-pres-≈̇-right _ (≈̇-trans (∘-assoc _ _ _) (∘-assoc _ _ _)))
             (≈̇-sym (∘-assoc _ _ _)))) ⟩
      map ϕ ∘ (mult[ P ×' R ] ∘ map (map (π₁' ×'-map id'))) ∘ (map strength[ P ×' Q , R ]) ∘ map ⟨ id' , ψ ⟩' ∘ f
        -- multiplicative
        ≈⟨ ∘-pres-≈̇-right _ (∘-pres-≈̇-left (mult-natural _) _) ⟩
      map ϕ ∘ (map (π₁' ×'-map id') ∘ mult[ (P ×' Q) ×' R ]) ∘ (map strength[ P ×' Q , R ]) ∘ map ⟨ id' , ψ ⟩' ∘ f
        --  assoc.
        ≈˘⟨ ≈̇-trans (∘-assoc _ _ _) (∘-pres-≈̇-right _ (∘-pres-≈̇-right _ (∘-assoc _ _ _))) ⟩
      (map ϕ ∘ map (π₁' ×'-map id') ∘ mult) ∘ (map strength ∘ map ⟨ id' , ψ ⟩') ∘ f
        -- functoriality
        ≈˘⟨ ∘-pres-≈̇
            (≈̇-trans (∘-pres-≈̇-left (map-pres-∘ _ _) _ ) (∘-assoc _ _ _))
            (∘-pres-≈̇-left (map-pres-∘ _ _) _) ⟩
      (map (ϕ ∘ π₁' ×'-map id') ∘ mult) ∘ map (strength ∘ ⟨ id' , ψ ⟩') ∘ f
        -- multiplicative
        ≈˘⟨ ∘-pres-≈̇-left (mult-natural _) _ ⟩
      (mult ∘ map (map (ϕ ∘ π₁' ×'-map id'))) ∘ map (strength ∘ ⟨ id' , ψ ⟩') ∘ f
        -- assoc.
        ≈⟨ ≈̇-trans (∘-assoc _ _ _) (∘-pres-≈̇-right _ (≈̇-sym (∘-assoc _ _ _))) ⟩
      mult ∘ (map (map (ϕ ∘ π₁' ×'-map id')) ∘ map (strength ∘ ⟨ id' , ψ ⟩')) ∘ f
        -- functoriality
        ≈˘⟨ ∘-pres-≈̇-right _ (∘-pres-≈̇-left (≈̇-trans (map-pres-≈̇ (∘-assoc _ _ _)) (map-pres-∘ _ _)) _) ⟩
      mult ∘ map ((map (ϕ ∘ π₁' ×'-map id') ∘ strength) ∘ ⟨ id' , ψ ⟩') ∘ f
        ≡⟨⟩
      mult ∘ map ((map (ϕ ∘ π₁' ×'-map id') ∘ strength) ∘ ⟨ id' , ψ ⟩') ∘ (strength ∘ ⟨ id' , φ ⟩')
        -- assoc.
        ≈˘⟨ ∘-pres-≈̇-right _ (∘-assoc _ _ _) ⟩
      mult ∘ ((map ((map (ϕ ∘ π₁' ×'-map id') ∘ strength) ∘ ⟨ id' , ψ ⟩')) ∘ strength) ∘ ⟨ id' , φ ⟩'
        -- defn.
        ≡⟨⟩
      letin' φ (sletin' ψ (ϕ ∘ (π₁' ×'-map id'))) ∎

    ass-dia' : {P Q R S : Obj} (φ : P →̇ ℱ' Q) (ψ : (P ×' Q) →̇ ℱ' R) (ϕ : (P ×' R) →̇ ℱ' S)
        → letin' (letin' φ ψ) ϕ ≈̇ letin' φ (letin' ψ (ϕ ∘ (π₁' ×'-map id'[ R ])))
    ass-dia' {P} {Q} {R} {S} φ ψ ϕ = let open EqReasoning (→̇-setoid P (ℱ' S)) in begin
      letin' (letin' φ ψ) ϕ
        -- defn. (of top-most letin')
        ≡⟨⟩
      mult ∘ sletin' (letin' φ ψ) ϕ
        -- sletin' commutes with letin' in a way
        ≈⟨ ∘-pres-≈̇-right _ (comm-dia' _ _ _) ⟩
      mult ∘ letin' φ (sletin' ψ (ϕ ∘ (π₁' ×'-map id')))
        -- defn.
        ≡⟨⟩
      mult ∘ mult[ ℱ' S ] ∘ sletin' φ (sletin' ψ (ϕ ∘ (π₁' ×'-map id')))
        -- assoc.
        ≈˘⟨ ∘-assoc _ _ _ ⟩
      (mult[ S ] ∘ mult[ ℱ' S ]) ∘ sletin' φ (sletin' ψ (ϕ ∘ (π₁' ×'-map id')))
        -- multiplicative (is assoc.)
        ≈˘⟨ ∘-pres-≈̇-left mult-assoc _ ⟩
      (mult[ S ] ∘ map mult[ S ]) ∘ sletin' φ (sletin' ψ (ϕ ∘ (π₁' ×'-map id')))
        -- assoc.
        ≈⟨ ∘-assoc _ _ _ ⟩
      mult[ S ] ∘ map mult[ S ] ∘ sletin' φ (sletin' ψ (ϕ ∘ (π₁' ×'-map id')))
        -- strength
        ≈⟨ ∘-pres-≈̇-right _ (sletin'-nat₂ _ _ _) ⟩
      mult ∘ sletin' φ (mult ∘ sletin' ψ (ϕ ∘ (π₁' ×'-map id')))
        -- defn.
        ≡⟨⟩
      letin' φ (letin' ψ (ϕ ∘ (π₁' ×'-map id'[ R ]))) ∎