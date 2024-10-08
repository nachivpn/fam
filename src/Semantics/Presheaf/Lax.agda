{-# OPTIONS --safe --without-K #-}
open import Relation.Binary.PropositionalEquality using (_≡_; subst; cong; cong₂) renaming (refl to ≡-refl; sym to ≡-sym; trans to ≡-trans)
open import Semantics.Kripke.Frame using (IFrame ; MFrame)

module Semantics.Presheaf.Lax
  {C    : Set}
  {_⊆_  : (Γ Δ : C) → Set}
  {IF   : IFrame C _⊆_}
  {_R_  : (Γ Δ : C) → Set}
  (MF  : MFrame IF _R_)
  (let open MFrame MF)
  where

open import Data.Product using (∃; _×_; _,_; -,_) renaming (proj₁ to fst; proj₂ to snd)
open import Data.Product using () renaming (∃ to Σ; _×_ to _∧_)

open import Relation.Binary using (Reflexive; Symmetric; Transitive; IsEquivalence; Setoid)
import Relation.Binary.Reasoning.Setoid as EqReasoning

open import Semantics.Presheaf.Base IF
open import Semantics.Presheaf.CartesianClosure IF
open import Semantics.Presheaf.Possibility.Base MF public

open import Semantics.Category.Base
open import Semantics.Category.Cartesian
open import Semantics.Category.EndoFunctor.Base

private
  variable
    Γ Γ' Γ'' : C
    Δ Δ' Δ'' : C
    θ θ' θ'' : C
    𝒫 𝒫' : Psh
    𝒬 𝒬' : Psh
    ℛ ℛ' ℛ'' : Psh

-- type \bigcirc or \ci5 for ◯
record ◯'-Fam (𝒫 : Psh) (Γ : C) : Set where
  constructor elem
  field
      fun     : {Γ' : C} → (w : Γ ⊆ Γ') → ◇'-Fam 𝒫 Γ'
      natural : (w : Γ ⊆ Γ') (w' : Γ' ⊆ Γ'')
        → wk[ ◇' 𝒫 ] w' (fun w) ≋[ ◇' 𝒫 ] fun (⊆-trans w w')

open ◯'-Fam renaming (fun to apply-◯) public

record _◯'-≋_ {𝒫 : Psh} {Γ : C} (f f' : ◯'-Fam 𝒫 Γ) : Set where
    constructor proof
    field
      pw : {Γ' : C} → (w : Γ ⊆ Γ') → (f .apply-◯ w) ◇'-≋[ 𝒫 ] (f' .apply-◯ w)

open _◯'-≋_ using (pw) public

◯'-≋-refl : Reflexive (_◯'-≋_ {𝒫} {Γ})
◯'-≋-refl = proof λ _w → ◇'-≋-refl

◯'-≋-sym : Symmetric (_◯'-≋_ {𝒫} {Γ})
◯'-≋-sym = λ f≋f' → proof λ w → ◇'-≋-sym (f≋f' .pw w)

◯'-≋-trans : Transitive (_◯'-≋_ {𝒫} {Γ})
◯'-≋-trans = λ f≋f' f'≋f'' → proof λ w → ◇'-≋-trans (f≋f' .pw w) (f'≋f'' .pw w)

≡-to-◯'-≋ : {x y : ◯'-Fam 𝒫 Γ} → x ≡ y → x ◯'-≋ y
≡-to-◯'-≋ ≡-refl = ◯'-≋-refl

◯'-≋[]-syn : (𝒫 : Psh) → (x y : ◯'-Fam 𝒫 Γ) → Set
◯'-≋[]-syn {Γ = Γ} 𝒫 = _◯'-≋_ {𝒫} {Γ}

syntax ◯'-≋[]-syn 𝒫 x y = x ◯'-≋[ 𝒫 ] y

---------------------
-- ◯' 𝒫 is a presheaf
---------------------

◯'_ : (𝒫 : Psh) → Psh
◯' 𝒫 = record
  { Fam           = ◯'-Fam 𝒫
  ; _≋_           = _◯'-≋_
  ; ≋-equiv       = ≋-equiv
  ; wk            = wk
  ; wk-pres-≋     = wk-pres-≋
  ; wk-pres-refl  = wk-pres-refl
  ; wk-pres-trans = wk-pres-trans
  }
  where

    ≋-equiv : (Γ : C) → IsEquivalence (_◯'-≋_ {𝒫} {Γ})
    ≋-equiv = λ w → record
      { refl  = ◯'-≋-refl
      ; sym   = ◯'-≋-sym
      ; trans = ◯'-≋-trans
      }

    wk : Γ ⊆ Γ' → ◯'-Fam 𝒫 Γ → ◯'-Fam 𝒫 Γ'
    wk w f = record
      { fun = λ w' → f .apply-◯ (⊆-trans w w')
      ; natural = λ w' w'' → let open EqReasoning ≋[ ◇' 𝒫 ]-setoid in begin
        wk[ ◇' 𝒫 ] w'' (f .apply-◯ (⊆-trans w w'))
          ≈⟨ f .natural (⊆-trans w w') w'' ⟩
        f .apply-◯ (⊆-trans (⊆-trans w w') w'')
          ≡⟨ cong (f .apply-◯) (⊆-trans-assoc w w' w'') ⟩
        f .apply-◯ (⊆-trans w (⊆-trans w' w'')) ∎ }

    abstract
      wk-pres-≋ : (w : Γ ⊆ Γ') {f f' : ◯'-Fam 𝒫 Γ} (f≋f' : f ◯'-≋ f') → wk w f ◯'-≋ wk w f'
      wk-pres-≋ w f≋f' = proof λ w' → f≋f' .pw (⊆-trans w w')

      wk-pres-refl : (f : ◯'-Fam 𝒫 Γ) → wk ⊆-refl f ◯'-≋ f
      wk-pres-refl f = proof (λ w → ≡-to-◇'-≋ (cong (f .apply-◯) (⊆-trans-unit-left w)))

      wk-pres-trans : (w : Γ ⊆ Γ') (w' : Γ' ⊆ Γ'') (f : ◯'-Fam 𝒫 Γ) → wk (⊆-trans w w') f ◯'-≋ wk w' (wk w f)
      wk-pres-trans w w' f = proof (λ w'' → ≡-to-◇'-≋ (cong (f .apply-◯) (⊆-trans-assoc w w' w'')))

---------------------------
-- ◯' is a presheaf functor
---------------------------

◯'-map_ : (t : 𝒫 →̇ 𝒬) → (◯' 𝒫 →̇ ◯' 𝒬)
◯'-map_ {𝒫} {𝒬} = λ t → record
    { fun     = λ p → record
      { fun     = λ w → (◇'-map t) .apply (p .apply-◯ w)
      ; natural = λ w w' → let open EqReasoning ≋[ ◇' 𝒬 ]-setoid in begin
         wk[ ◇' 𝒬 ] w' ((◇'-map t) .apply (p .apply-◯ w))
          ≈⟨ (◇'-map t) .natural w' (p .apply-◯ w) ⟩
        (◇'-map t) .apply (wk[ ◇' 𝒫 ] w' (p .apply-◯ w))
          ≈⟨ (◇'-map t) .apply-≋ (p .natural w w') ⟩
        (◇'-map t) .apply (p .apply-◯ (⊆-trans w w')) ∎ }
    ; pres-≋  = λ p≋p' → proof λ w → (◇'-map t) .apply-≋ (p≋p' .pw w)
    ; natural = λ w p → proof λ w' → ≋[ ◇' 𝒬 ]-refl
    }

◯'-is-PshFunctor : EndoFunctor PshCat
◯'-is-PshFunctor = record
  { ℱ'_            = ◯'_
  ; map_        = ◯'-map_
  ; map-pres-≈̇  = ◯'-map-pres-≈̇
  ; map-pres-id = ◯'-map-pres-id
  ; map-pres-∘  = ◯'-map-pres-∘
  }
  where
  abstract
    ◯'-map-pres-≈̇ : {t t' : 𝒫 →̇  𝒬} → t ≈̇ t' → ◯'-map t ≈̇ ◯'-map t'
    ◯'-map-pres-≈̇ t≈̇t' = record { proof = λ p → proof λ w → ◇'-map-fun-pres-≈̇ t≈̇t' (p .apply-◯ w) }

    ◯'-map-pres-id : ◯'-map id'[ 𝒫 ] ≈̇ id'
    ◯'-map-pres-id = record { proof = λ _p → proof λ _w → ◇'-≋-refl }

    ◯'-map-pres-∘ : (t' : 𝒬 →̇ ℛ) (t : 𝒫 →̇ 𝒬) → ◯'-map (t' ∘ t) ≈̇ ◯'-map t' ∘ ◯'-map t
    ◯'-map-pres-∘ _t' _t = record { proof = λ _p → proof λ w → ◇'-≋-refl }

-------------------------------------------------------
-- Presheaf functors ◯' and ◇' are naturally isomorphic
-------------------------------------------------------

module ◯'≅◇' where

  ◯'≅◇'-forth[_] : (𝒫 : Psh) → ◯' 𝒫 →̇ ◇' 𝒫
  ◯'≅◇'-forth[ 𝒫 ] = record
    { fun     = λ ◯p → ◯p .apply-◯ ⊆-refl
    ; pres-≋  = λ ◯p≋◯p' → ◯p≋◯p' .pw ⊆-refl
    ; natural = λ w p → let open EqReasoning ≋[ ◇' 𝒫 ]-setoid in
      begin
      wk[ ◇' 𝒫 ] w (p .apply-◯ ⊆-refl)
        ≈⟨ p .natural ⊆-refl w ⟩
      p .apply-◯ (⊆-trans ⊆-refl w)
        ≡⟨ cong (p .apply-◯) (≡-trans (⊆-trans-unit-left _) (≡-sym (⊆-trans-unit-right _))) ⟩
      p .apply-◯ (⊆-trans w ⊆-refl)
        ≡⟨⟩
      wk[ ◯' 𝒫 ] w p .apply-◯ ⊆-refl ∎ }

  -- ◯'≅◇'-forth[_] is a natural transformation (in the category of presheaf functors)
  ◯'≅◇'-forth-nat : (f : 𝒫 →̇ 𝒬) → ◯'≅◇'-forth[ 𝒬 ] ∘ ◯'-map f ≈̇  (◇'-map f) ∘ ◯'≅◇'-forth[ 𝒫 ]
  ◯'≅◇'-forth-nat {𝒫} {𝒬} f = record { proof = λ p → ◇'-≋-refl }

  ◯'≅◇'-back[_] : (𝒫 : Psh) → ◇' 𝒫 →̇ ◯' 𝒫
  ◯'≅◇'-back[ 𝒫 ] = record
    { fun     = λ ◇p → record
      { fun     = λ w → wk[ ◇' 𝒫 ] w ◇p
      ; natural = λ i i' → ≋[ ◇' 𝒫 ]-sym (wk[ ◇' 𝒫 ]-pres-trans i i' ◇p) }
    ; pres-≋  = λ ◇p≋◇p' → proof (λ w → wk[ ◇' 𝒫 ]-pres-≋ w ◇p≋◇p')
    ; natural = λ w ◇p → proof (λ w' → wk[ ◇' 𝒫 ]-pres-trans w w' ◇p) }

  -- ◯'≅◇'-back[_] is a natural transformation (in the category of presheaf functors)
  ◯'≅◇'-back-nat : (f : 𝒫 →̇ 𝒬) → ◯'≅◇'-back[ 𝒬 ] ∘ ◇'-map f ≈̇  (◯'-map f) ∘ ◯'≅◇'-back[ 𝒫 ]
  ◯'≅◇'-back-nat {𝒫} {𝒬} f = record
    { proof = λ p → proof λ w → let open EqReasoning ≋[ ◇' 𝒬 ]-setoid in begin
      wk[ ◇' 𝒬 ] w ((◇'-map f) .apply p)
        ≈⟨ (◇'-map f) .natural w p ⟩
      (◇'-map f) .apply (wk[ ◇' 𝒫 ] w p) ∎
    }

  --
  -- ◯'≅◇'-forth and ◯'≅◇'-back are component-wise isomorphic
  --

  ◯'≅◇'-back-left-inverse : ◯'≅◇'-back[ 𝒫 ] ∘ ◯'≅◇'-forth[ 𝒫 ] ≈̇ id'[ ◯' 𝒫 ]
  ◯'≅◇'-back-left-inverse {𝒫} = record
    { proof = λ p → proof λ w → let open EqReasoning ≋[ ◇' 𝒫 ]-setoid in begin
        wk[ ◇' 𝒫 ] w (p .apply-◯ ⊆-refl)
          ≈⟨ ◯'≅◇'-forth[ 𝒫 ] .natural w p ⟩
        p .apply-◯ (⊆-trans w ⊆-refl)
          ≡⟨ cong (p .apply-◯) (⊆-trans-unit-right w) ⟩
        p .apply-◯ w ∎
    }


  ◯'≅◇'-back-right-inverse : ◯'≅◇'-forth[ 𝒫 ] ∘ ◯'≅◇'-back[ 𝒫 ] ≈̇ id'[ ◇' 𝒫 ]
  ◯'≅◇'-back-right-inverse {𝒫} = record { proof = wk[ ◇' 𝒫 ]-pres-refl }
