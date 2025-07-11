10 REM THIS IS A TEST OF TRSNIC CONNECTING TO WHOIS
12 H$ = "whois.iana.org"
13 PRINT "ENTER DOMAIN TO QUERY"
14 INPUT Q$
15 REM OPEN A TCP/IP SOCKET
20 OUT 236,16  	:REM ENABLE MODEL III BUS
25 OUT 31,1
30 OUT 31,1		:REM SOCKET COMMAND
40 OUT 31,1		:REM USE IPV4
50 OUT 31,1		:REM
57 GOSUB 1000
60 Y=INP(31)	:REM GET THE STATUS
70 IF Y <> 0 THEN PRINT "ERROR OPENING SOCKET": GOTO 500
80 SOCKFD=INP(31)	:REM STORE THE SOCKET FILE DESCRIPTOR
90 PRINT "THE SOCKET IS OPEN "
100 REM CONNECT TO THE SERVER
105 OUT 31,1
110 OUT 31,3	:REM CONNECT COMMAND
115 OUT 31,SOCKFD
117 L = LEN(H$)
118 FOR T = 1 TO L
119 T$ = MID$(H$,T,1)
120 OUT 31,ASC(T$)
121 NEXT T
122 OUT 31,0	:REM NULL ENDS HOSTNAME
123 OUT 31,43	:REM PORT LSB
124 OUT 31,0	:REM PORT MSB
125 GOSUB 1000
130 Y = INP(31)
140 IF Y <> 0 THEN PRINT "ERROR CONNECTING TO WHOIS SERVER": GOTO 500
150 PRINT "YOU ARE CONNECTED TO WHOIS SERVER"
160 REM SEND QUERY
166 L = LEN(Q$)
167 OUT 31,1
170 OUT 31,4
171 OUT 31,SOCKFD
172 OUT 31,L+2:OUT 31,0: OUT 31,0: OUT 31,0
180 FOR T = 1 TO L:T$=MID$(Q$,T,1):OUT 31,ASC(T$):NEXT T
184 OUT 31,13
185 OUT 31,10
186 GOSUB 1000
187 FOR T = 1 TO 5: Y=INP(31): NEXT T
190 PRINT "RECEIVING DATA FROM WHOIS..."
200 REM RECEIVE THE DATA
201 OUT 31,1
202 OUT 31,6
204 OUT 31,SOCKFD
206 OUT 31,0	:REM USE BLOCKING FOR NIST DAYTIME SERVICE
208 OUT 31,255:OUT 31,255:OUT 31,0:OUT 31,0		:REM DATA LENGTH REQUESTED
210 GOSUB 1000
220 Y = INP(31)
230 IF Y <> 0 THEN PRINT "ERROR RECEIVING": GOTO 500
240 L1 = INP(31):L2 = INP(31):L3 = INP(31):L4 = INP(31)
250 L = (L2 * 256) + L1
260 FOR T = 1 TO L: Y=INP(31): PRINT CHR$(Y);:NEXT T
300 PRINT 
310 PRINT "...DONE RECEIVING DATA FROM WHOIS"
500 REM CLOSE
505 OUT 31,1
510 OUT 31,8
520 OUT 31,SOCKFD
525 GOSUB 1000
530 Y = INP(31)
540 IF Y = 0 THEN PRINT "THE SOCKET IS CLOSED" ELSE PRINT "ERROR ON CLOSE"
550 END
1000 IF PEEK(293) = 73 THEN GOTO 1030
1010 IF (PEEK(14304) AND 32) <> 0 THEN GOTO 1010
1020 RETURN
1030 IF (INP(224) AND 8) <> 0 THEN GOTO 1030
1040 RETURN
