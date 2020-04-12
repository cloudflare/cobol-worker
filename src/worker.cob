       IDENTIFICATION DIVISION.
       PROGRAM-ID. worker.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
           01 RAND-NUM PIC 9(2).
           01 CURRENT-TIME.
                  05 T-HOURS PIC 99.
                  05 T-MINS PIC 99.
                  05 T-SECS PIC 99.
                  05 T-MS PIC 999.
           01 PLAYER-CHOICE PIC X(8) VALUE ZERO.
           01 COMPUTER-CHOICE PIC X(10) VALUE ZERO.
           01 CHOICE-IND PIC 9.
           01 BLAH PIC 99.
           01 HTTP-OK PIC A(3) VALUE '200'.
           01 HTTP-BAD-REQUEST PIC A(3) VALUE '400'.
           01 ERROR-NO-INPUT PIC A(24) VALUE 'please provide your pick'.
           01 ARG-VALUE PIC S9(9) BINARY.
           01 ARG-NAME PIC A(4) VALUE 'pick'.
           01 ROCK PIC A(8) VALUE 'rock'.
           01 SCISSORS PIC A(8) VALUE 'scissors'.
           01 PAPER PIC A(8) VALUE 'paper'.
           01 CHOICES.
                  05 CHOICE PIC A(8) OCCURS 3 TIMES.
           01 RESULT PIC X(24) VALUE "lose".
       PROCEDURE DIVISION.
           CALL "get_http_form" USING ARG-NAME RETURNING ARG-VALUE.
           EVALUATE TRUE
               WHEN ARG-VALUE = 1
                   MOVE 'rock' TO PLAYER-CHOICE
               WHEN ARG-VALUE = 2
                   MOVE 'scissors' TO PLAYER-CHOICE
               WHEN ARG-VALUE = 3
                   MOVE 'paper' TO PLAYER-CHOICE
               WHEN OTHER
                   MOVE ERROR-NO-INPUT TO RESULT
                   PERFORM RETURN-ERROR
                   STOP RUN
           END-EVALUATE
           DISPLAY "player: " PLAYER-CHOICE
           MOVE ROCK TO CHOICE(1).
           MOVE SCISSORS TO CHOICE(2).
           MOVE PAPER TO CHOICE(3).
           ACCEPT CURRENT-TIME FROM TIME.
           COMPUTE RAND-NUM = FUNCTION RANDOM (T-MS) * 100.
           DIVIDE RAND-NUM BY 3 GIVING BLAH REMAINDER CHOICE-IND.
           MOVE CHOICE(CHOICE-IND + 1) TO COMPUTER-CHOICE.
           IF PLAYER-CHOICE = COMPUTER-CHOICE
               MOVE "tie" TO RESULT
           END-IF.
           IF PLAYER-CHOICE = 'rock' AND COMPUTER-CHOICE = 'scissors'
               MOVE "win" TO RESULT
           END-IF.
           IF PLAYER-CHOICE = 'scissors' AND COMPUTER-CHOICE = 'paper'
               MOVE "win" TO RESULT
           END-IF.
           IF PLAYER-CHOICE = 'paper' AND COMPUTER-CHOICE = 'rock'
               MOVE "win" TO RESULT
           END-IF.
           CALL "set_http_status" USING HTTP-OK.
           PERFORM SEND-JSON.
           STOP RUN.
       RETURN-ERROR.
           CALL "set_http_status" USING HTTP-BAD-REQUEST
           PERFORM SEND-JSON.
       SEND-JSON.
           CALL "append_http_body" USING "{"
           CALL "append_http_body" USING '"result":'
           CALL "append_http_body" USING '"'
           CALL "append_http_body" USING RESULT
           CALL "append_http_body" USING '"'
           CALL "append_http_body" USING ',"player":'
           IF PLAYER-CHOICE = ZERO
               CALL "append_http_body" USING "null"
           ELSE
               CALL "append_http_body" USING '"'
               CALL "append_http_body" USING PLAYER-CHOICE
               CALL "append_http_body" USING '"'
           END-IF.
           CALL "append_http_body" USING ',"computer":'
           IF COMPUTER-CHOICE = ZERO
               CALL "append_http_body" USING "null"
           ELSE
               CALL "append_http_body" USING '"'
               CALL "append_http_body" USING COMPUTER-CHOICE
               CALL "append_http_body" USING '"'
           END-IF.
           CALL "append_http_body" USING "}".
