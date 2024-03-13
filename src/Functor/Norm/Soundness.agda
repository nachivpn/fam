{-# OPTIONS --safe --without-K #-}
module Functor.Norm.Soundness where

open import Data.Unit using (⊤ ; tt)
open import Data.Product using (Σ; _×_; _,_; -,_ ; proj₁ ; proj₂) 
open import Relation.Binary.PropositionalEquality using (_≡_ ; refl ; sym ; trans ; cong ; cong₂)

open import Functor.Term
open import Functor.Term.Reduction hiding (single)
open import Functor.Term.NormalForm
open import Functor.Term.Conversion

open import Functor.Norm

Tm'- : Ty → Psh
Tm'- a = record
          { Fam           = λ Γ → Tm Γ a
          ; _≋_           = _≈_
          ; ≋-equiv       = λ _ → ≈-is-equiv
          ; wk            = wkTm
          ; wk-pres-≋     = wkTm-pres-≈
          ; wk-pres-refl  = λ x → ≡-to-≈ (wkTm-pres-⊆-refl x)
          ; wk-pres-trans = λ w w' x → ≡-to-≈ (wkTm-pres-⊆-trans w w' x)
          }

embNe : Ne'- a →̇ Tm'- a
embNe = record
  { fun     = embNe-fun
  ; pres-≋  = λ p≋p' → ≡-to-≈ (cong embNe-fun p≋p')
  ; natural = λ w n → ≡-to-≈ (embNe-nat w n)
  }

embNf : Nf'- a →̇ Tm'- a
embNf = record
  { fun     = embNf-fun
  ; pres-≋  = λ p≋p' → ≡-to-≈ (cong embNf-fun p≋p')
  ; natural = λ w n → ≡-to-≈ (embNf-nat w n)
  }

reifyTm : (a : Ty) → Ty'- a →̇ Tm'- a
reifyTm a = embNf ∘ reify a

quotTm : Sub'- Γ →̇ Ty'- a → Tm Γ a
quotTm {Γ} {a} f = reifyTm a .apply (f .apply (idEnv Γ))

import Semantics.Presheaf.Possibility as ◇m
import Semantics.Presheaf.Base as PB
import Relation.Binary.Construct.Closure.ReflexiveTransitive as RT

module Core
  (collectTm    : {a : Ty} → ◇' (Tm'- a) →̇ Tm'- (◇ a))
  (collect-comm : {a : Ty} → collectTm ∘ ◇'-map embNf ≈̇ embNf ∘ collectNf {a})
  (register-exp : {a : Ty} → embNe ≈̇ collectTm {a} ∘ ◇'-map embNe ∘ register) 
  where

  ℒ : (a : Ty) → (t : Tm Γ a) → (x : Ty' Γ a) → Set
  ℒ {_} ι       t n =
    t ≈ reifyTm ι .apply n
  ℒ {Γ} (a ⇒ b) t f =
    ∀ {Γ' : Ctx} {u : Tm Γ' a} {x : Ty' Γ' a}
    → (w : Γ ⊆ Γ') → (uℒx : ℒ a u x) → ℒ b (app (wkTm w t) u) (f .apply w x)
  ℒ {_} (◇ a)   t (elem (Δ , r , x)) =
    Σ (Tm Δ a) λ u → t ≈ collectTm .apply (elem (Δ , r , u)) × ℒ a u x

  ℒₛ : {Γ : Ctx} (Δ : Ctx) → Sub Γ Δ → Sub' Γ Δ → Set
  ℒₛ []       []       tt              = ⊤
  ℒₛ (Δ `, a) (s `, t) (elem (δ , x)) = ℒₛ Δ s δ × ℒ a t x

  ℒ-prepend : (a : Ty) {t u : Tm Γ a} {x : Ty' Γ a}
    → t ≈ u → ℒ a u x → ℒ a t x
  ℒ-prepend ι       t≈u uLn
    = ≈-trans t≈u uLn
  ℒ-prepend (a ⇒ b) t≈u uLf
    = λ w uLy → ℒ-prepend b (cong-app1≈ (wk[ Tm'- (a ⇒ b) ]-pres-≋ w t≈u)) (uLf w uLy)
  ℒ-prepend (◇ a)   t≈u (u' , u≈_ , u'Lx)
    = u' , ≈-trans t≈u u≈_ , u'Lx 

  ℒ-build   : (a : Ty) → {t : Tm Γ a} {x : Ty' Γ a} → ℒ a t x → t ≈ reifyTm a .apply x
  ℒ-reflect : (a : Ty) (n : Ne Γ a) → ℒ a (embNe .apply n) (reflect a .apply n)
  
  ℒ-build ι        tLx
    = tLx
  ℒ-build (a ⇒ b)  tLx
    = ≈-trans (exp-fun _) (cong-lam (ℒ-build b (tLx freshWk (ℒ-reflect a (var zero)))))
  ℒ-build (◇ a)    {x = elem (Δ , r , x)} tr@(u , t≈_ , uLx)
    = ≈-trans t≈_ (≈-trans (collectTm .apply-≋ (proof (refl , refl , ℒ-build a uLx))) (collect-comm .apply-≋ _))

  ℒ-reflect ι       n = ≈-refl
  ℒ-reflect (a ⇒ b) n = λ w uLx → ℒ-prepend b (cong-app≈ (embNe .natural w _) (ℒ-build a uLx)) (ℒ-reflect b (app (wkNe w n) (reify a .apply _)))
  ℒ-reflect (◇ a)   n = var zero , register-exp .apply-≋ n , ℒ-reflect a (var zero)

  ℒ-cast : {t u : Tm Γ a} {x : Ty' Γ a}
       → (t≡u : t ≡ u)
       → (uℒx : ℒ a u x)
       → ℒ a t x
  ℒ-cast refl uLx = uLx
 
  wkTm-pres-ℒ : {t : Tm Γ a} {x : Ty' Γ a}
    → (w : Γ ⊆ Γ')
    → (tLx : ℒ a t x)
    → ℒ a (wkTm w t) (wkTy' a w x)
  wkTm-pres-ℒ {a = ι}     {x = x} w tLn
    = ≈-trans (wkTm-pres-≈ w tLn) (embNf .natural w (reify _ .apply x))
  wkTm-pres-ℒ {a = a ⇒ b} {t = t} w tLf
    = λ w' y → ℒ-cast (cong₂ app (sym (wkTm-pres-⊆-trans w w' t)) refl) (tLf (w ∙ w') y)
  wkTm-pres-ℒ {a = ◇ a}  {x = elem (Δ , r , x)}         w (u , tr , uLx)
    = wkTm (factor⊆ w r) u
      , ≈-trans (wkTm-pres-≈ w tr) (collectTm .natural w (elem (Δ , r , u)))
      , wkTm-pres-ℒ (factor⊆ w r) uLx

  --
  wkSub-pres-ℒₛ : {s : Sub Γ Δ} {δ : Sub' Γ Δ}
    → (w : Γ ⊆ Γ')
    → (sLδ : ℒₛ Δ s δ)
    → ℒₛ Δ (wkSub w s) (wkSub' Δ w δ)
  wkSub-pres-ℒₛ {Δ = []} {s = []}     w p
    = tt 
  wkSub-pres-ℒₛ {Δ = _Δ `, a} {s = _s `, t}  w (sLδ , tLx)
    = wkSub-pres-ℒₛ w sLδ , wkTm-pres-ℒ w tLx

  -- 
  idℒₛ : ∀ Δ → ℒₛ Δ idₛ (idEnv Δ)
  idℒₛ []       = tt
  idℒₛ (Δ `, a) = wkSub-pres-ℒₛ freshWk (idℒₛ Δ) , ℒ-reflect a (var zero)

  --
  Fund : Tm Δ a → Set
  Fund {Δ} {a} t = ∀ {Γ} {s : Sub Γ Δ} {δ : Sub' Γ Δ}
    → (sLδ : ℒₛ Δ s δ) → ℒ a (substTm s t) (eval t .apply δ)

  --  
  fund : (t : Tm Δ a) → Fund t
  fund t = {!!} 

  --
  quotTm-retracts-eval : (t : Tm Γ a) → t ≈ quotTm (eval t)
  quotTm-retracts-eval t = ℒ-build _ (ℒ-prepend _ (≡-to-≈ (sym (substTm-pres-idₛ t))) (fund t (idℒₛ _)))
  
  -- normalization is sound
  norm-sound : {t u : Tm Γ a} → norm t ≡ norm u → t ≈ u
  norm-sound {Γ} {a} {t} {u} nt≡nu = ≈-trans
    (quotTm-retracts-eval t)
    (≈-trans
      (≡-to-≈ (cong (embNf .apply) nt≡nu))
      (≈-sym (quotTm-retracts-eval u)))

