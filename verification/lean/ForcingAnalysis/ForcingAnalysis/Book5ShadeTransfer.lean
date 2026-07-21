/- Book5ShadeTransfer.lean — shade transport and golden radial-step kernel. -/
import ForcingAnalysis.Book4A
import ForcingAnalysis.Book5Reciprocity

namespace ForcingAnalysis.Book5ShadeTransfer

/-- Exact preservation of radius preserves every shade normalization. -/
theorem shade_preserved_of_radius_preserved {Radius Shade : Type*}
    (shade : Radius → Shade) {radius transferredRadius : Radius}
    (h : transferredRadius = radius) :
    shade transferredRadius = shade radius := by
  rw [h]

/-- Preserving radial order is weaker than preserving radial values and hence
does not by itself preserve shade. -/
theorem radial_order_alone_does_not_preserve_shade :
    ∃ transfer : ℕ → ℕ, StrictMono transfer ∧ transfer 1 ≠ 1 := by
  refine ⟨fun radius => radius + 1, ?_, by norm_num⟩
  intro first second h
  exact Nat.add_lt_add_right h 1

/-- On the golden spiral, the logarithm of the radius increases by exactly
`log φ` at every discrete mode transition. -/
theorem golden_logRadius_step (r0 : ℝ) (hr0 : 0 < r0) (n : ℕ) :
    Real.log (Book4A.spiralMagnitude Book4A.goldenRatio r0 (n + 1)) -
      Real.log (Book4A.spiralMagnitude Book4A.goldenRatio r0 n) =
        Real.log Book4A.goldenRatio := by
  have hcurrent : 0 < Book4A.spiralMagnitude Book4A.goldenRatio r0 n := by
    simp only [Book4A.spiralMagnitude]
    exact mul_pos (pow_pos Book4A.goldenRatio_pos n) hr0
  rw [Book4A.spiralMagnitude_recurrence]
  rw [Real.log_mul Book4A.goldenRatio_pos.ne' hcurrent.ne']
  ring

/-- A standard bounded shade normalization. -/
noncomputable def normalizedShade (reference radius : ℝ) : ℝ :=
  radius / (radius + reference)

/-- Multiplicative radius steps do not remain multiplicative shade steps after
bounded normalization: doubling radius from one to two does not double shade. -/
theorem normalized_shade_is_not_multiplicative :
    normalizedShade 1 2 ≠ 2 * normalizedShade 1 1 := by
  norm_num [normalizedShade]

/-- Balanced reciprocity selects the golden radial growth rate. -/
theorem balanced_reciprocity_paints_golden_rate :
    Book5.reciprocityRate 1 = Real.goldenRatio :=
  Book5.reciprocityRate_one

/-- At zero reciprocal weight the spectral growth rate is one, so the radial
coordinate has no multiplicative growth. -/
theorem extraction_has_unit_radial_rate :
    Book5.reciprocityRate 0 = 1 :=
  Book5.reciprocityRate_zero


/-! ## Executable shade interfaces

Shade is treated here as an observer-readable control coordinate. A carrier can
change representation while remaining faithful only when decoding after
transport agrees with decoding before transport. -/

/-- A representation change with source and target shade decoders. -/
structure ShadeInterface (Source Carrier Shade : Type*) where
  encode : Source → Carrier
  sourceShade : Source → Shade
  carrierShade : Carrier → Shade

namespace ShadeInterface

variable {Source Middle Target Shade : Type*}

/-- The semantic commuting-square condition for shade-preserving execution. -/
def Faithful (I : ShadeInterface Source Carrier Shade) : Prop :=
  ∀ source, I.carrierShade (I.encode source) = I.sourceShade source

/-- Faithful interfaces compose through an intermediate carrier. -/
def comp (second : ShadeInterface Middle Target Shade)
    (first : ShadeInterface Source Middle Shade)
    (_hdecoder : second.sourceShade = first.carrierShade) :
    ShadeInterface Source Target Shade where
  encode := second.encode ∘ first.encode
  sourceShade := first.sourceShade
  carrierShade := second.carrierShade

/-- A chain of faithful lower-order transports remains faithful when the
intermediate observer-readable decoder is shared. -/
theorem faithful_comp
    (first : ShadeInterface Source Middle Shade)
    (second : ShadeInterface Middle Target Shade)
    (hFirst : first.Faithful) (hSecond : second.Faithful)
    (hdecoder : second.sourceShade = first.carrierShade) :
    (second.comp first hdecoder).Faithful := by
  intro source
  change second.carrierShade (second.encode (first.encode source)) =
    first.sourceShade source
  rw [hSecond]
  rw [hdecoder]
  exact hFirst source

/-- Identity representation is a faithful boundary. -/
def identity (Source Shade : Type*) (shade : Source → Shade) :
    ShadeInterface Source Source Shade where
  encode := id
  sourceShade := shade
  carrierShade := shade

theorem identity_faithful (shade : Source → Shade) :
    (identity Source Shade shade).Faithful := by
  intro source
  rfl

end ShadeInterface

/-- Shade and shadow price form a joint observer-readable control signal. -/
structure ControlSignal (Shade : Type*) where
  shade : Shade
  shadowPrice : ℝ

/-- A carrier faithfully executes both the normalized shade instruction and its
resource shadow price only when the joint signal commutes. -/
def FaithfulControlTransport {Source Carrier Shade : Type*}
    (encode : Source → Carrier)
    (sourceSignal : Source → ControlSignal Shade)
    (carrierSignal : Carrier → ControlSignal Shade) : Prop :=
  ∀ source, carrierSignal (encode source) = sourceSignal source

/-- Joint signal fidelity exposes both component equalities. -/
theorem faithfulControlTransport_components
    {Source Carrier Shade : Type*}
    {encode : Source → Carrier}
    {sourceSignal : Source → ControlSignal Shade}
    {carrierSignal : Carrier → ControlSignal Shade}
    (h : FaithfulControlTransport encode sourceSignal carrierSignal)
    (source : Source) :
    (carrierSignal (encode source)).shade = (sourceSignal source).shade ∧
      (carrierSignal (encode source)).shadowPrice =
        (sourceSignal source).shadowPrice := by
  rw [h source]
  exact ⟨rfl, rfl⟩

/-- Exact radius preservation constructs a faithful interface for every shade
normalization and every shadow-price readout simultaneously. -/
theorem radius_preservation_implies_control_fidelity
    {Radius Carrier Shade : Type*}
    (encode : Radius → Carrier) (decodeRadius : Carrier → Radius)
    (shade : Radius → Shade) (shadowPrice : Radius → ℝ)
    (hRadius : ∀ radius, decodeRadius (encode radius) = radius) :
    FaithfulControlTransport encode
      (fun radius => ⟨shade radius, shadowPrice radius⟩)
      (fun carrier =>
        ⟨shade (decodeRadius carrier), shadowPrice (decodeRadius carrier)⟩) := by
  intro radius
  change ControlSignal.mk (shade (decodeRadius (encode radius)))
      (shadowPrice (decodeRadius (encode radius))) =
    ControlSignal.mk (shade radius) (shadowPrice radius)
  rw [hRadius radius]

/-- Preserving shade alone does not certify the associated shadow price. -/
theorem shade_without_shadow_price_is_not_control_fidelity :
    let encode : ℕ → ℕ := id
    let source : ℕ → ControlSignal Bool := fun _ => ⟨true, 0⟩
    let carrier : ℕ → ControlSignal Bool := fun _ => ⟨true, 1⟩
    (∀ n, (carrier (encode n)).shade = (source n).shade) ∧
      ¬ FaithfulControlTransport encode source carrier := by
  dsimp
  constructor
  · intro n
    rfl
  · intro h
    have := congrArg ControlSignal.shadowPrice (h 0)
    norm_num at this

/-- A strictly monotone recoding preserves order but can still violate the
commuting shade semantics expected by a lower-order executor. -/
theorem monotone_encoding_not_semantically_faithful :
    let interface : ShadeInterface ℕ ℕ ℕ :=
      { encode := fun radius => radius + 1
        sourceShade := id
        carrierShade := id }
    StrictMono interface.encode ∧ ¬ interface.Faithful := by
  dsimp [ShadeInterface.Faithful]
  constructor
  · intro first second h
    exact Nat.add_lt_add_right h 1
  · intro h
    have := h 0
    norm_num at this

end ForcingAnalysis.Book5ShadeTransfer
