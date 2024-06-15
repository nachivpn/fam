{-# OPTIONS --safe --without-K #-}
open import Relation.Binary.PropositionalEquality using (_≡_)
open import Data.Product using (∃; _×_; _,_; -,_) renaming (proj₁ to fst; proj₂ to snd)

module Semantics.Kripke.Frame where

-- Intuitionistic Frame
record IFrame (W : Set) (_⊆_ : W → W → Set) : Set where
  field
    ⊆-trans            : ∀ {w w' w'' : W} → (i : w ⊆ w') → (i' : w' ⊆ w'') → w ⊆ w''
    ⊆-trans-assoc      : ∀ {w w' w'' w''' : W} (i : w ⊆ w') (i' : w' ⊆ w'') (i'' : w'' ⊆ w''') → ⊆-trans (⊆-trans i i') i'' ≡ ⊆-trans i (⊆-trans i' i'')
    ⊆-refl             : ∀ {w : W} → w ⊆ w
    ⊆-refl-unit-right  : ∀ {w w' : W} (i : w ⊆ w') → ⊆-trans ⊆-refl i ≡ i
    ⊆-refl-unit-left   : ∀ {w w' : W} (i : w ⊆ w') → ⊆-trans i ⊆-refl ≡ i

record MFrame {W : Set} {_⊆_ : W → W → Set} (IF : IFrame W _⊆_) (_R_ : W → W → Set) : Set where

  open IFrame IF public

  --
  -- Factorisation conditions
  --
  
  field
      factor : {w w' v : W} → w ⊆ w' → w R v → ∃ λ v' → w' R v' × v ⊆ v'

  factorW : {w w' v : W} → (i : w ⊆ w') (r : w R v) → W       ; factorW  w r = factor w r .fst
  factorR : {w w' v : W} → (i : w ⊆ w') (r : w R v) → w' R _  ; factorR  w r = factor w r .snd .fst
  factor⊆ : {w w' v : W} → (i : w ⊆ w') (r : w R v) → v ⊆ _   ; factor⊆ w r = factor w r .snd .snd

  field
    factor-pres-⊆-refl  : {w v : W}
      → (m : w R v) → factor ⊆-refl m ≡ (v , m , ⊆-refl)
    factor-pres-⊆-trans : {w w' w'' v : W} → (i : w ⊆ w') (i' : w' ⊆ w'') (m : w R v)
      → factor (⊆-trans i i') m ≡ (-, (factorR i' (factorR i m) , (⊆-trans (factor⊆ i m) (factor⊆ i' (factorR i m)))))  

-- Inclusive, reflexive and transitive factorising frames
module _ {W : Set} {_⊆_ : W → W → Set} {_R_ : W → W → Set} {IF : IFrame W _⊆_} (MF : MFrame IF _R_) where

  open MFrame MF

  record InclusiveMFrame : Set where
    field
      R-to-⊆             : {w v : W} → w R v → w ⊆ v
      factor-pres-R-to-⊆ : {w w' v : W} → (i : w ⊆ w') → (m : w R v) → (⊆-trans i (R-to-⊆ (factorR i m))) ≡ ⊆-trans (R-to-⊆ m) (factor⊆ i m)

  record ReflexiveMFrame : Set where    
    field
      R-refl             : {w : W} → w R w
      factor-pres-R-refl : {w w' : W} (i : w ⊆ w') → factor i R-refl ≡ (w' , R-refl , i)

    R-refl[_] : (w : W) → w R w ; R-refl[ w ] = R-refl {w}
    
  record TransitiveMFrame : Set where
    field
      R-trans             : {w w' w'' : W} → w R w' → w' R w'' → w R w''
      factor-pres-R-trans : {w w' u v : W} (i : w ⊆ w') (m : w R v) (m' : v R u)
        → factor i (R-trans m m') ≡ ((-, ((R-trans (factorR i m) (factorR (factor⊆ i m) m')) , factor⊆ (factor⊆ i m) m'))) 


