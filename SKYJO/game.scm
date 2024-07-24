; Motley Sundry :: Game Models :: SKYJO :: game.scm
; Copyright (C) 2024 Donald R Anderson
;
; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU Affero General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU Affero General Public License for more details.
;
; You should have received a copy of the GNU Affero General Public License
; along with this program.  If not, see <https://www.gnu.org/licenses/>.

(define cards '#s8(
    -2 -2 -2 -2 -2
    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    -1 1 2 3 4 5 6 7 8 9 10 11 12
    -1 1 2 3 4 5 6 7 8 9 10 11 12
    -1 1 2 3 4 5 6 7 8 9 10 11 12
    -1 1 2 3 4 5 6 7 8 9 10 11 12
    -1 1 2 3 4 5 6 7 8 9 10 11 12
    -1 1 2 3 4 5 6 7 8 9 10 11 12
    -1 1 2 3 4 5 6 7 8 9 10 11 12
    -1 1 2 3 4 5 6 7 8 9 10 11 12
    -1 1 2 3 4 5 6 7 8 9 10 11 12
    -1 1 2 3 4 5 6 7 8 9 10 11 12))

(define-structure game draw-pile discard-pile players first-player)

; Create a new initialized game structure.
(define (new-game num-players)
    ; Allocate structure
    (define game (make-game
        (s8vector-to-list (s8vector-rand (s8vector-dup cards)))  ;draw-pile
        '() ;discard-pile
        (make-vector num-players) ;players
        0 ;first player
    ))
    
    ; Populate players vector
    (define (set-player id)
        (if (< id num-players)
            (begin
                (vector-set! (game-players game) id (new-player id))
                (set-player (+ id 1))))
    )
    (set-player 0)
    game
)  

(define (game-pop-draw-pile game)
    (define card (car (game-draw-pile game)))
    (game-draw-pile-set! game (cdr (game-draw-pile game)))
    card
)

; Turns up two cards for each player.
; Returns first player id.
(define (game-deal-hands game num-players)
    (define players (game-players game))
    (define (deal-card num cnt)
        (if (< cnt num)
            (let(
                (player (vector-ref players (remainder cnt num-players))))
                (s8vector-set!(player-cards player) (floor (/ cnt num-players)) (game-pop-draw-pile game))
                (deal-card num (+ cnt 1))
            )))

    (deal-card (* 12 num-players) 0)
    (game-flip-two game num-players)

)

(define (game-flip-two game num-players)
    (define players (game-players game))
    (define (flip-two cnt max max-player)
            (if (< cnt num-players)
                (let(
                    (total (run-player (vector-ref players cnt) game sim-stats "flip-two")))
                    (if (> total max)
                        (flip-two (+ cnt 1) total cnt)
                        (flip-two (+ cnt 1) max max-player))
                )
                max-player; Return the player with the highest total
            ))
    (flip-two 0 -1 0)
)

(define (run-game game sim-stats num-players)
    (define first-player (game-deal-hands game num-players))
    ; Run plays until one player turns up their last card
    (define (run-plays num id)
        (if (> num *game-play-bound*)
            (begin
                (display "Exceeded *game-play-bound*")
                (exit 1))
            (if (run-player (vector-ref (game-players game) id) game sim-stats "draw-phase-1")
                (run-plays  (+ num 1) (remainder (+ id 1) num-players))
                (run-two-rounds game sim-stats num-players id))))
    
    (run-plays 0 first-player)
)

(define (run-two-rounds game sim-stats num-players skip-player)
    (run-one-round game sim-stats num-players skip-player)
    (run-one-round game sim-stats num-players skip-player)
)
    
(define (run-one-round game sim-stats num-players skip-player)
    (define (run-round num id)
        (if (< num (- num-players 1))
            (begin 
                (run-player (vector-ref (game-players game) id) game sim-stats "draw-phase-2")
                (run-round  (+ num 1) (remainder (+ id 1) num-players)))))

    (run-round 0 (remainder (+ skip-player 1) num-players))
)



