; Motley Sundry :: Game Models :: SKYJO :: player.scm
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


(define-structure player
    id              ;integer player id, unique in context
    round           ;reference to the containing round round
    hand            ;reference to the players hand
    strat           ;lambda reference to the assigned strategy
    points          ;integer points the player scored for the round, updated at the end of the round
)

; Create a new initialized player structure.
(define (new-player id round)
    ; Allocate structure
    (make-player
        id                                  ;id
        round                               ;round
        (new-hand)                          ;hand
        (get-player-strat id)               ;strat
        0                                   ;points
    ))  

; Returns the index of the largest open card or #f if there are no open cards.
 (define (player-get-largest-open-card player)
    (hand-get-largest-open-card (player-get-hand player))
 )

;;;;;;;;;;;;;;;;;;;;;;;;;
; PLAYER STRATEGY CALLS
;;;;;;;;;;;;;;;;;;;;;;;;;

; Returns the string label of the strategy or #f on failure.
(define (player-strat-label player)
    ((player-strat player) player "get-label") 
)

; Returns #t if the play was executed or #f otherwise.
(define (player-flip-two player)
    ;(print (list "flip-two: player:" (player-id player)))
    ((player-strat player) player "flip-two") 
)

; Returns #t if the play was executed or #f otherwise.
(define (player-play-phase1 player)
    ;(print (list "play-phase1: player:" (player-id player)))
    ((player-strat player) player "play-phase1")
    (player-remove-matching-columns! player)
    (player-any-cards-hidden? player)

)

; Returns #t if the play was executed or #f otherwise.
(define (player-play-phase2 player)
    ;(print (list "play-phase2: player:" (player-id player)))
    ((player-strat player) player "play-phase2")
    (player-remove-matching-columns! player)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PLAYER STRATEGY CALLBACKS
;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Replaces a players card with a card-value.
; It is used for a card that has been taken from the draw pile.
(define (player-replace-card-with-draw-card! player card-id card-value)
    (deck-push-discard-pile! (player-get-deck player) (player-get-card-value player card-id))
    (player-set-card-value! player card-id card-value)
    (if(player-is-card-hidden? player card-id)
        (player-set-card-open! player card-id)) 
)

; Replaces a players card by poping the top card off the discard pile.
; The discard top is viewable by the strategy so it is popped here.
(define (player-replace-card-from-discard! player card-id)
    (let ((card-value (deck-pop-discard-pile! (player-get-deck player))))
        (deck-push-discard-pile! (player-get-deck player) (player-get-card-value player card-id))
        (player-set-card-value! player card-id card-value)
        (if(player-is-card-hidden? player card-id)
            (player-set-card-open! player card-id)))
)

; Discard a card-value
; It is used for a card that has been taken from the draw pile.
(define (player-discard-draw-card! player card-value)
    (deck-push-discard-pile! (player-get-deck player) card-value)
    (hand-open-first-hidden-card! (player-hand player))
)

;;;;;;;;;;;;;;;;;;
; PLAYER GETTERS
;;;;;;;;;;;;;;;;;;

(define (player-get-hand player)
    (player-hand player)
)

(define (player-get-deck player)
    (round-deck (player-round player))
)

(define (player-get-game player)
    (round-game (player-round player))
)

(define (player-get-round player)
    (player-round player)
)

(define (player-get-card-sum player)
    (hand-card-sum (player-hand player))
)

(define (player-get-card-value player card-id)
    (hand-get-card-value (player-get-hand player) card-id)
)
(define (player-get-first-hidden-card player)
    (hand-get-first-hidden-card (player-get-hand player))
)

;;;;;;;;;;;;;;;;;;
; PLAYER QUERIES
;;;;;;;;;;;;;;;;;;

(define (player-any-cards-open? player)
    (hand-any-cards-open? (player-get-hand player))
)

(define (player-any-cards-hidden? player)
    (hand-any-cards-hidden? (player-get-hand player))
)

(define (player-any-cards-removed? player)
    (hand-any-cards-removed? (player-get-hand player))
)

(define (player-is-card-open? player card-id)
    (hand-is-card-open? (player-hand player) icard-idd)
)

(define (player-is-card-hidden? player card-id)
    (hand-is-card-hidden? (player-hand player) card-id)
)

(define (player-is-card-removed? player card-id)
    (hand-is-card-removed? (player-hand player) icard-idd)
)

; Validate the players's consistency
(define (player-is-valid? player)
    (hand-is-valid? (player-hand player))
)

;;;;;;;;;;;;;;;;;;
; PLAYER SETTERS
;;;;;;;;;;;;;;;;;;

(define (player-set-card-value! player card-id card-value)
    (hand-set-card-value! (player-hand player) card-id card-value)
)

(define (player-set-card-open! player card-id)
    (hand-set-card-open! (player-hand player) card-id)
)

(define (player-set-card-hidden! player card-id)
    (hand-set-card-hidden! (player-hand player) card-id)
)

(define (player-set-card-removed! player card-id)
    (hand-set-card-removed! (player-hand player) card-id)
)

; PLAYER PRINT
(define (player-print player tab)
    (display tab)(print "--- Player ---")
    (display tab)(print (list "id:      " (player-id player)))
    (display tab)(print (list "Strategy:" (player-strat-label player)))
    (hand-print (player-hand player) (string-append tab "  "))
    (newline)
)

(define (player-print-round player tab)
    (round-print (player-round player) "")
)

(define (player-remove-matching-columns! player)
    (hand-remove-matching-columns! (player-hand player) (round-deck (player-round player)))
)

