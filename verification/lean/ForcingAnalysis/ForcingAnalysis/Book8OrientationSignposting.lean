/- Book8OrientationSignposting.lean — directed cognition and audience coordinates. -/
import Mathlib

namespace ForcingAnalysis.Book8OrientationSignposting

/-- The four stages in Book 8's directed symbolic-cognition cycle. -/
inductive Stage where
  | observe
  | project
  | reflect
  | update
  deriving DecidableEq, Repr

/-- The source-order successor: observe -> project -> reflect -> update -> observe. -/
def next : Stage → Stage
  | .observe => .project
  | .project => .reflect
  | .reflect => .update
  | .update => .observe

/-- The opposite traversal, kept distinct from the canonical successor. -/
def previous : Stage → Stage
  | .observe => .update
  | .update => .reflect
  | .reflect => .project
  | .project => .observe

theorem next_four (stage : Stage) : next (next (next (next stage))) = stage := by
  cases stage <;> rfl

theorem previous_next (stage : Stage) : previous (next stage) = stage := by
  cases stage <;> rfl

theorem next_previous (stage : Stage) : next (previous stage) = stage := by
  cases stage <;> rfl

/-- An audience may display the canonical direction with the same or opposite
coordinate orientation. This changes signs, not the underlying process. -/
inductive Orientation where
  | aligned
  | reversed
  deriving DecidableEq, Repr

def encode (orientation : Orientation) (change : ℝ) : ℝ :=
  match orientation with
  | .aligned => change
  | .reversed => -change

/-- Encoding twice in the same ± orientation recovers the canonical value. -/
theorem encode_involutive (orientation : Orientation) (change : ℝ) :
    encode orientation (encode orientation change) = change := by
  cases orientation <;> simp [encode]

/-- Audience transport is explicit conjugation through the canonical frame. -/
def transport (source target : Orientation) (displayedChange : ℝ) : ℝ :=
  encode target (encode source displayedChange)

theorem transport_preserves_canonical_change
    (source target : Orientation) (change : ℝ) :
    transport source target (encode source change) = encode target change := by
  simp [transport, encode_involutive]

/-- Opposite audience signs agree only for a zero change. A raw sign conflict
therefore cannot be patched by choosing one display convention globally. -/
theorem opposite_signs_agree_iff_zero (change : ℝ) :
    encode .aligned change = encode .reversed change ↔ change = 0 := by
  constructor
  · intro h
    simp only [encode] at h
    linarith
  · intro h
    subst change
    simp [encode]

/-- A positive canonical change appears negative in the reversed audience
frame; the orientation witness is required to interpret its sign. -/
theorem reversed_display_of_positive {change : ℝ} (hchange : 0 < change) :
    encode .reversed change < 0 := by
  simpa [encode] using neg_lt_zero.mpr hchange

/-- Presentation orientation may reverse the displayed arrows, but it may not
silently redefine the source's canonical
ext` operation. -/
def displayedNext (orientation : Orientation) : Stage → Stage :=
  match orientation with
  | .aligned => next
  | .reversed => previous

theorem displayedNext_differs_across_orientations :
    displayedNext .aligned .observe ≠ displayedNext .reversed .observe := by
  decide

end ForcingAnalysis.Book8OrientationSignposting
