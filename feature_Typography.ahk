; Override CapsLock to provide multiple alternate input sets.
;
; Each mode replaces a set of keys to conveniently type special characters.
; All modes by default last for only a single typed character, or can be
; toggled on by holding `Shift` while pressing their hotkey then toggled
; off by pressing `CapsLock` again.

#NoEnv
#SingleInstance Force
SendMode Input
SetWorkingDir % A_ScriptDir
#Persistent
#KeyHistory 0
#NoTrayIcon

; Optional, prevent capslock light during hotkeys
SetCapsLockState AlwaysOff

LOCK_MODE := {OFF: 0, SUBSCRIPT: 1, SUPERSCRIPT: 2, GREEK: 3, MISC: 4}
currentLockMode := LOCK_MODE.OFF



;;;; Hotkeys


; Passthroughs for common native hotkeys that must work in every lock mode
~^a::return
~^s::return

; Disable all modes
CapsLock::currentLockMode := LOCK_MODE.OFF

CapsLock & Up::
  currentLockMode := LOCK_MODE.SUPERSCRIPT
  if not GetKeyState("Shift", "P") {
    autoClearLockMode()
  }
  return

CapsLock & Down::
  currentLockMode := LOCK_MODE.SUBSCRIPT
  if not GetKeyState("Shift", "P") {
    autoClearLockMode()
  }
  return

CapsLock & G::
  currentLockMode := LOCK_MODE.GREEK
  if not GetKeyState("Shift", "P") {
    autoClearLockMode()
  }
  return

CapsLock & -:: ; hyphen/minus key
  currentLockMode := LOCK_MODE.MISC
  if not GetKeyState("Shift", "P") {
    autoClearLockMode()
  }
  return



;;;; Functions


autoClearLockMode() {
  ; Wait for 1 text character, 10 seconds, or CapsLock
  Input, ignored, L1 T10 V, {CapsLock}
  global currentLockMode
  currentLockMode := LOCK_MODE.OFF
}



;;;; Lock mode definitions

#If currentLockMode == LOCK_MODE.SUPERSCRIPT
0::⁰
1::¹
2::²
3::³
4::⁴
5::⁵
6::⁶
7::⁷
8::⁸
9::⁹

#If currentLockMode == LOCK_MODE.SUBSCRIPT
0::₀
1::₁
2::₂
3::₃
4::₄
5::₅
6::₆
7::₇
8::₈
9::₉

#If currentLockMode == LOCK_MODE.GREEK
; Listed in order of Greek alphabet, unintuitive hotkeys are marked with *
A::Α ; Alpha
a::α
B::Β ; Beta
b::β
G::Γ ; Gamma
g::γ
D::Δ ; Delta
d::δ
E::Ε ; Epsilon
e::ε
Z::Ζ ; Zeta
z::ζ
H::Η ; Eta
h::η
T::Θ ; Theta
t::θ
I::Ι ; Iota
i::ι
K::Κ ; Kappa
k::κ
L::Λ ; Lambda
l::λ
M::Μ ; Mu
m::μ
N::Ν ; Nu
n::ν
X::Ξ ; Xi
x::ξ
O::Ο ; Omicron
o::ο
P::Π ; Pi
p::π
R::Ρ ; Rho
r::ρ
S::Σ ; Sigma
s::σ
w::ς ; (word-final) *
J::Τ ; Tau          *
j::τ ;              *
U::Υ ; Upsilon
u::υ
F::Φ ; Phi
f::φ
V::Χ ; Chi          *
v::χ ;              *
Y::Ψ ; Psi          *
y::ψ ;              *
Q::Ω ; Omega        *
q::ω ;              *

#If currentLockMode == LOCK_MODE.MISC
g::† ; dagger
G::‡ ; double dagger
-::— ; hyphen -> em dash

#If
