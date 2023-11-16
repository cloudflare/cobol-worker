       IDENTIFICATION DIVISION.
       PROGRAM-ID. worker.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
      *
           01 HTTP-OK            PIC X(03) VALUE '200'.
           01 HTTP-BAD-REQUEST   PIC X(03) VALUE '400'.
           01 HTTP-INTERNAL-ERR  PIC X(03) VALUE '500'.
           01 HTTP-RETURN        PIC X(03).
      *
           01 ERROR-NO-INPUT     PIC A(24) 
                                 VALUE 'please provide your pick'.
           01 ERROR-BAD-COMPUTE  PIC A(24) 
                                 VALUE 'internal error'.
      *
           01 ARG-NAME           PIC A(4)  VALUE 'pick'.
           01 ARG-VALUE          PIC S9(9) COMP-5.
      *
           01 CURRENT-TIME.
              05 T-HOURS         PIC 99.
              05 T-MINS          PIC 99.
              05 T-SECS          PIC 99.
              05 T-MS            PIC 999.
      *
           01 RAND-NUM           PIC 99.
           01 BLAH               PIC 99.
      *
           01 CHOICE-IND         PIC 9.
           01 PLAYER-CHOICE      PIC 9 VALUE ZERO.
           01 COMPUTER-CHOICE    PIC 9 VALUE ZERO.
      *
           01 CHOICE-ROCK        PIC 9 VALUE 1.
           01 CHOICE-SCISSORS    PIC 9 VALUE 2.
           01 CHOICE-PAPER       PIC 9 VALUE 3.
      *
           01 CHOICES.
              05 FILLER          PIC A(8)  VALUE "rock".
              05 FILLER          PIC A(8)  VALUE "scissors".
              05 FILLER          PIC A(8)  VALUE "paper".
           01 FILLER REDEFINES CHOICES.
              05 CHOICE          PIC A(8) OCCURS 3 TIMES.
      *
           01 RESULT             PIC X(24) VALUE "undefined".
      *
       PROCEDURE DIVISION.
      *
       MAIN.
           PERFORM GET-PLAYER-CHOICE
           IF CHOICE-IND  < 1 or > 3
              DISPLAY "bad player: " CHOICE-IND UPON SYSERR
              MOVE HTTP-BAD-REQUEST  TO HTTP-RETURN
              PERFORM SEND-STATUS
              MOVE ERROR-NO-INPUT    TO RESULT
              PERFORM SEND-JSON
              STOP RUN RETURNING 1
           END-IF
           MOVE CHOICE-IND TO PLAYER-CHOICE.
      *
           PERFORM GET-COMPUTER-CHOICE
           IF CHOICE-IND < 1 or > 3
              DISPLAY "bad computer: " CHOICE-IND UPON SYSERR
              MOVE HTTP-INTERNAL-ERR TO HTTP-RETURN
              PERFORM SEND-STATUS
              MOVE ERROR-BAD-COMPUTE TO RESULT
              PERFORM SEND-JSON
              STOP RUN RETURNING 1
           END-IF
           MOVE CHOICE-IND TO COMPUTER-CHOICE.
      *
           MOVE HTTP-OK           TO HTTP-RETURN
           PERFORM SEND-STATUS.
      *
      *    DISPLAY "player: " CHOICE (PLAYER-CHOICE)
           EVALUATE PLAYER-CHOICE  ALSO COMPUTER-CHOICE
              WHEN CHOICE-ROCK     ALSO CHOICE-SCISSORS
              WHEN CHOICE-SCISSORS ALSO CHOICE-PAPER
              WHEN CHOICE-PAPER    ALSO CHOICE-ROCK
                 MOVE "win"  TO RESULT
              WHEN OTHER
                 IF PLAYER-CHOICE = COMPUTER-CHOICE
                    MOVE "tie"  TO RESULT
                 ELSE
                    MOVE "lose" TO RESULT
                 END-IF
           END-EVALUATE.
      *
           PERFORM SEND-JSON.
           STOP RUN.
      *
       GET-PLAYER-CHOICE.
           CALL "get_http_form" USING ARG-NAME RETURNING ARG-VALUE.
           MOVE ARG-VALUE  TO CHOICE-IND.
      *
       GET-COMPUTER-CHOICE.
      *    COBOL 85 with intrinsic function amendment
           ACCEPT CURRENT-TIME FROM TIME.
           COMPUTE RAND-NUM = FUNCTION RANDOM (T-MS) * 100.
      *
      *    COBOL 2002+
      *    COMPUTE RAND-NUM = FUNCTION RANDOM (
      *                         FUNCTION SECONDS-PAST-MIDNIGHT()
      *                       ) * 100.
      *
           DIVIDE RAND-NUM BY 3 GIVING BLAH REMAINDER CHOICE-IND.
           ADD 1 TO CHOICE-IND.
      *
       SEND-STATUS.
           CALL "set_http_status"  USING HTTP-BAD-REQUEST.
      *
       SEND-JSON.
           CALL "append_http_body" USING "{"
           CALL "append_http_body" USING '"result":'
           CALL "append_http_body" USING '"'
           CALL "append_http_body" USING RESULT
           CALL "append_http_body" USING '"'
           CALL "append_http_body" USING ',"player":'
           MOVE PLAYER-CHOICE   TO CHOICE-IND
           PERFORM SEND-JSON-CHOICE
           CALL "append_http_body" USING ',"computer":'
           MOVE COMPUTER-CHOICE TO CHOICE-IND
           PERFORM SEND-JSON-CHOICE
           CALL "append_http_body" USING "}".
      *
       SEND-JSON-CHOICE.
           IF CHOICE-IND = ZERO
               CALL "append_http_body" USING "null"
           ELSE
               CALL "append_http_body" USING '"'
               CALL "append_http_body" USING CHOICE (CHOICE-IND)
               CALL "append_http_body" USING '"'
           END-IF.
