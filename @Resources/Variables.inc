[Variables]
BoardCol=7
BoardRow=6
LowerPadding=20
DropY=5
DropHeight=50
HoleInnerRadius=1
InnerRadius=7
DiscRadius=20
DiscSpacing=15
; Player 1
DiscName1=Red
DiscColor1=255,55,55
; Player 2
DiscName2=Yellow
DiscColor2=255,255,55



; Dont edit below

BoardW=#BoardCol# * #DiscRadius# * 2 + (#BoardCol# + 1) * #DiscSpacing#
BoardH=#BoardRow# * #DiscRadius# * 2 + (#BoardRow# + 1) * #DiscSpacing#

SkinWidth=#BoardW#
SkinHeight=#DropHeight# + #BoardH# + #LowerPadding#
