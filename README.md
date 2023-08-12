# Heartbeat-sensor-pic18F4
CODE EXPLANATION :
as you Can see in the Code above,we have used timer1 to reCieve pulses
and timer0 to aChieve the desired delay.
Timer0 has been initialized in main for 1ms.then loading timer1 with 00h.
After starting both timers simultaneously,timer1 starts takes external pulses
from Tock1 which is portc pin 0. As Timer0 reaches 1ms.
Interrupt flag gets high.vector table which was checking for the interrupt
flag, when it gets high it stops the program in main and jumps to isr. In my
code, the main task is in isr. Now we have made a logic since 3 seconds is
max limit timer can achieve, so we have made a loop which will run 5 times
to achieve the desired delay.notice that timer1 is still taking pulses so as
soon as the Timer0 reaches 15 seconds, both timers are turned off and we
have a value in tmr1 which is in hex we need to convert it to bcd because we
need decimal valu to be displayed on seven segment. Also this conversion
reduces the number of bit combinations for example, in hex we have 0 to
and in decimal we have only 10.

After converting to bcd, we separate higher bit and lowerbit to make it easy
for us to identify what respective value we have to send to 7 segment to
display the respective number.
Since we can only achieve 34 pulses in 15 seconds while any healthy human
has heartbeat of more than 60 so by amplifng the pulse by 3 will help us
achieve the nearly real heartbeat
After separation of higher and lower bit, there&#39;s a logic to select which value
should be send to the 7 segment to display the respective number. Finally
when the selected values are stored in g1 and g2 (GPR), we send them on
portd which is connected to 7 segment.
7 segment display value is achieved through logic not with a decoder.
It also checks for the user to stop the display and start talking pulses again.

HARDWARE PERSPECTIVE:

On hardware, we have used ir diode and photo diode to give pulses to
timer1.The Heart Beat signal is obtained by LED and LDR combination.
Pulses form hands interrupts the light reaching the LDR and this signal is
read by microcontroller.
