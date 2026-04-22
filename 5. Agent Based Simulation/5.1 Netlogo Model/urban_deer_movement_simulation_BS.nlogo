;The purpose of this code is to produce a simple model of deer movement across a landscape representing Oak Bay (British Columbia) and with a deployed camera array
;We will explore differences in movement and home range sizes for deer, and how those movements impact camera detections of each sex (female vs male)
;We will run scenarios of varying population sizes, mimicking the effect of immunocontraception treatment reducing population size
;The output of this model will be a detection history of individual deer at each camera, which will be used to estimate population density in R

;Andrew Barnas
;andrewbarnas@uvic.ca
;April 9th 2026
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;EXTENSIONS

;The csv extension is the only fancy one we need, for cleanly outputing data to csv files
extensions [csv]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;GLOBAL VARIABLES

globals[
  units               ;The size that each patch is meant to represent (in meteres) -> used for math on deer movement.
  output-filename     ;Name of the output file holding detection histories
]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BREEDS AND VARIABLES

;Camera agents
breed [cameras camera]

;Deer agents
breed [deers deer] ;yes I know (deers), grammer isn't my strong suit and "deers" is fun.

;Deer specific variables
deers-own[
 activity-center ;Location of the deer's home range center, used for making deer move in a general circulular home range
 sex             ;Female or Male
 hr-size         ;Variable home range size between sexes

 visited-patches ;A collection of all unique patches visited, used for calculating home range size
]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;SETUP PROCEDURE
;The following procedure sets up our simulated landscape, deploys a relatively evenly spaced camera grid, and produces a population of deer
;It also sets up output files if needed

to setup
  ;Clean slate
  clear-all
  ;random-seed 420 ;removing random seed since we deal with this in R now
  reset-ticks
  stop-inspecting-dead-agents

  if collect-data = TRUE[
  ;File Setup: Create a unique filename for this run based on the number of deer
  set output-filename (word "outputs/deer_detections_" number-deer  "_rep" behaviorspace-run-number ".csv")

  ; Write the Header Row
  csv:to-file output-filename (list (list "camera_id" "xcor" "ycor" "tick" "deer_id" "sex" "number-deer" "run_num"))
  ]


  ;Making a general rectangle shaped world to represent Oak Bay, but flipped lengthways for convenience (makes no analytical difference)
  resize-world -0 399 0 199
  set-patch-size 5 ;just for visualization
  ;Create a green landscape, with some variation to identify individual patches (purely aesthetic)
  ask patches [set pcolor green + random-float 1]

  ;Quick notes on patch scale which will be used for math on deer movement
  ; 10km^2 = 10,000,000 m^2.
  ;Number of patches = 400*200 = 80,000
  ; Area of one patch = 10,000,000 / 80,000 = 125 m^2
  ; Side of one patch = sqrt(125) = ~11.18 meters
  set units sqrt (10000000 / count patches)

  ;Create randomly dispersed deer on the landscape
  create-deers number-deer[
   set shape "moose" ;note you will have to import this from the shapes library (easy and worth it in my opinion)
   set size 4
   setxy random-xcor random-ycor
   set activity-center patch-here   ;activity center is where they are randomly spawned
   set sex one-of ["male" "female"]

    ;Fisher et al. 2024 reports 0.64km^2 home range for female deer.
    ;Assuming a circular home range --> 640,000m^2
    ;radius ~ 451 meters for females, then double it for males (assumption of this model)

    set hr-size ifelse-value (sex = "female") [ 450 ] [900 ]
    ;males in pink because it looks good on me (a male)
    set color ifelse-value (sex = "female") [blue] [pink]

    set visited-patches no-patches ; Initialize as an empty agentset
    pen-down
  ]

  ;Seperate procuedure to make a camera grid
  make-camera-grid

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;DEPLOY CAMERA GRID;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to make-camera-grid

  ; Calculate how many cameras to put on each axis (square root of total)
  ; This assumes number-cameras is a perfect square (e.g., 25, 49, 100).
  ; If not, it will round and fill the space as best it can.
  ;Note in our case the average is 35, but here we are using 36 for convenience
  let cams-per-side sqrt number-cameras

  ; Calculate spacing based on world dimensions
  let x-spacing (world-width / cams-per-side)
  let y-spacing (world-height / cams-per-side)

  ; Nested loops to place cameras at intervals
  let x (min-pxcor + x-spacing / 2)
  while [x < max-pxcor] [
    let y (min-pycor + y-spacing / 2)
    while [y < max-pycor] [
      create-cameras 1 [
        setxy x y
        set shape "square"
        set color black
        set size 4
      ]
      set y (y + y-spacing)
    ]
    set x (x + x-spacing)
  ]

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; GO PROCEDURE ;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;This procedure makes the deer move around the landscape, cameras detect deer if they cross into
;their detection zone. The simulation will run continuously unless data is being exported. If data
;is being collected, simulation runs for 43,200 ticks (minutes) which represents 30 days of 1 minute timesteps
;At the end, data is exported from cameras
to go

  ;Procedure to move deer around in their home range
  move-deers

  ;only write data files if the switch is flipped
  ;makes it more convenient for testing
  if collect-data = TRUE[
    ;Only included a stop condition if we are collecting data, otherwise leaving it open for testing purposes
    if ticks = 43200 [
      ;Spit out data on camera operability
      camera-operability
      stop]

  ;Continuously, have the cameras report the deer they are observing
  file-open output-filename
  cameras-detect
  file-close
  ]

  ;move the simulation forward one timestep
  tick
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; PROCEDURES CALLED BY GO;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;DEER MOVEMENT PROCEDURE;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Simple movement procedure. Deer can move around in a correlated random walk
;Once every hour they have a probabalistic procedure to turn around and face their activity center
;rather than a hard limit, this keeps deer from having an artificial hard line, and reduces having to roll the
;dice on turning back every time step.
to move-deers

ask deers [
    ;This is a rough approximation for how far to move deer each 1-minute timestep. Does not account for diel variation, differences in behaviour. Simply an average.
    ; Roden-Reynolds et al. 2022 Urban Ecosystems: average cumulative distance moved for white-tailed deer in sub-urban environment = 2.1km
    ; 1440 minutes (ticks) in a day, need to move 2100 m over the day
    let daily-dist 2100 ;(2100 meters aka 2.1 km)
    let meters-per-tick (daily-dist / 1440)

    ; SEX-SPECIFIC DECISION INTERVALS
    ; Males check every 1 hours (120 min), females every 1 hour (60 min)
   ; let interval ifelse-value (sex = "male") [ 480 ] [ 240 ]

    ;Once an hour, deer agents check to see if they have exceeded their sex-specific home range radius
    ;This lets agents wander and sometimes exceed their radius (behavioural variation) rather than a hard wall
    ;This also prevents deer from artificially remaining close to activity-center (if we were to check every time step)
     let interval 60
    if ticks mod interval = 0 [
      ;Check the distance from where they are standing to their activity center
      let dist-meters (distance activity-center * units)

      ;Probabilistic chance to turn around and head back in the general direction of their activity center
      ;Higher chance of returning the further they are from activity center
      ;But always return to activity center if they have exceeded their home range radius
      ifelse (random-float hr-size < dist-meters)
        ;turn and face your activity center, but wiggle a bit (not a straight line home)
        [ face activity-center rt (random 20) - 10]
        ;If not, continue on a random wiggly correlated walk
        [ rt (random 80) - 40 ]
    ]

    ;One additional "safety" feature. If deer are at the edge of the world, I don't want them to just sit there
    ;stuck trying to move forward. So here they sense if they are at the edge and make either a hard right or left
   ; Calculate the intended distance once to use in both check and movement
    let move-dist (meters-per-tick / units)


   ;NEED TO TEST THIS BLOCK!!!
    ; If the deer cannot move the full distance without hitting the edge
 ;   if not can-move? move-dist [
        ; Face their activity center to get back on track
  ;      face activity-center
   ;     ; Add a random wiggle so they don't all take the same path back
    ;    rt (random 60) - 30
    ;]

    ;Move forward an amount to equate to an average daily distance of 2.1km
    forward move-dist
  ]

end





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;CAMERA DETECTION PROCEDURE;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;This procedure has camera agents record if a deer agent is within their cone-shaped detection zone
;Cameras will output their data on deer detections if collect-data = TRUE

to cameras-detect

  ;https://www.trailcampro.com/blogs/reviews/browning-dark-ops-pro-x-1080-review?srsltid=AfmBOop7aLLPE9kSFUsLOChS4EpYVGLwnJi3aszDHGOw8kJIEf1Biit8
  ;detection range 90ft @46.8 detection angle (90 feet ~ 27.4 meters)
  ask cameras [
    let range-in-patches (27.4 / units)
    let targets deers in-cone range-in-patches 46.8

    ;If the camera detects any deer
    if any? targets [
      ;Briefly flash yellow (kind of hard to see but still useful for inspecting
      set color yellow

      ; Capture the camera's coordinates and ID once to avoid redundant calls inside the deer loop
      let cam-id who
      let cam-x xcor
      let cam-y ycor

      ; Loop through every deer currently in the cone -handy if multiple deer are in the zone
      ask targets [
        ; Prepare a row: [camera_id, xcor, ycor, tick, deer_id, sex, number-deer]
        ; Note: number-deer is a global variable from the interface/setup (helps keep track of simulation size for redundancy)
        let new-row (list cam-id cam-x cam-y ticks who sex number-deer behaviorspace-run-number)

        ; Convert the list to a CSV-formatted string and write it
        file-print csv:to-row new-row
      ]
    ]

    ;Turn the camera back to black
    set color black
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;CAMERA OPERABILITY PROCEDURE;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;This procedure produces a file at the end of the simulation which reports the camera operability data needed for estimating density

to camera-operability
 ; let operability-filename "camera_operability.csv"
  ;File name based on the number of deer
  ;Annoying because its the same grid, but the camera agents end up having different identities
  let operability-filename (word "outputs/camera_operability_" number-deer "_rep" behaviorspace-run-number ".csv")

  ;Create/Overwrite the file with just the header row
  csv:to-file operability-filename (list (list "camera_id" "xcor" "ycor" "ticks" "run_num" "number_deer"))

  ;Open the file to append the camera data
  file-open operability-filename

  ask cameras [
    let cam-id who
    let cam-x xcor
    let cam-y ycor

    ;Create the data list for this specific camera
    let new-row (list cam-id cam-x cam-y ticks behaviorspace-run-number number-deer)

    ;Use file-print to append the row to the opened file
    file-print csv:to-row new-row
  ]

  ;Close the file so it saves correctly
  file-close
end


;Fin.
@#$#@#$#@
GRAPHICS-WINDOW
245
13
2253
1022
-1
-1
5.0
1
10
1
1
1
0
0
0
1
0
399
0
199
0
0
1
ticks
30.0

BUTTON
23
50
86
83
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
22
153
85
186
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
15
376
188
409
number-deer
number-deer
0
500
200.0
10
1
NIL
HORIZONTAL

SWITCH
13
468
131
501
collect-data
collect-data
0
1
-1000

SLIDER
16
279
189
312
number-cameras
number-cameras
0
50
40.0
1
1
NIL
HORIZONTAL

TEXTBOX
23
29
238
55
Initialize the landscape and agents
11
0.0
1

TEXTBOX
22
132
237
158
Run the model
11
0.0
1

TEXTBOX
22
225
237
268
The number of cameras in the grid (actual will be the closest square number, e.g. 40 --> 36)
11
0.0
1

TEXTBOX
15
343
230
372
The number of deer agents on the landscape
11
0.0
1

TEXTBOX
15
442
230
468
Set \"on\" if you want to output data
11
0.0
1

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

moose
false
0
Polygon -7500403 true true 196 228 198 297 180 297 178 244 166 213 136 213 106 213 79 227 73 259 50 257 49 229 38 197 26 168 26 137 46 120 101 122 147 102 181 111 217 121 256 136 294 151 286 169 256 169 241 198 211 188
Polygon -7500403 true true 74 258 87 299 63 297 49 256
Polygon -7500403 true true 25 135 15 186 10 200 23 217 25 188 35 141
Polygon -7500403 true true 270 150 253 100 231 94 213 100 208 135
Polygon -7500403 true true 225 120 204 66 207 29 185 56 178 27 171 59 150 45 165 90
Polygon -7500403 true true 225 120 249 61 241 31 265 56 272 27 280 59 300 45 285 90

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="replicates" repetitions="10" runMetricsEveryStep="false">
    <setup>random-seed behaviorspace-run-number 
setup</setup>
    <go>go</go>
    <enumeratedValueSet variable="collect-data">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-deer">
      <value value="400"/>
      <value value="360"/>
      <value value="300"/>
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-cameras">
      <value value="40"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
