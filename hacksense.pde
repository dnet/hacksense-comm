// pinout
#define BTN_M 14
#define BTN_P 15

// button debouncing
#include <Bounce.h>
Bounce bouncer_m = Bounce(BTN_M, 10);
Bounce bouncer_p = Bounce(BTN_P, 10);

// serial comm
#define READ 0x80

// internal states
char ucounter; // state adjusted by the user
char scounter; // last state received from server

// LED display
#define NDIGITS 4
#define NMAP 25
unsigned long lastep = micros(); // last digit change
char digits[NDIGITS]; // currently displayed content
char digit = 0; // currently lit digit
char digitmap[NMAP][9] = { // digits
	"01111110",
	"10110000",
	"21101101",
	"31111001",
	"40110011",
	"51011011",
	"61011111",
	"71110000",
	"81111111",
	"91111011",
	";1000010", // upper-left corner (⸢)
	"?0011000", // lower-right corner (⸥)
	"H0110111",
	".0000000", // empty digit
	"q1000000", // clock states
	"w1100000",
	"e1110000",
	"r1111000",
	"t1111100",
	"z1111110",
	"a0111110",
	"s0011110",
	"d0001110",
	"f0000110",
	"g0000010"
};

// LED "clock"
char clockpos;
unsigned int cpcount;
char clockseq[] = ".......qwertzasdfg.";
#define CPLIMIT 200 /* delay between clockseq items (ms) */

void setup() {
	for (int i = 2; i <= 12; i++) {
		pinMode(i, OUTPUT);
	}
	pinMode(BTN_P, INPUT);
	pinMode(BTN_M, INPUT);
	digitalWrite(BTN_P, HIGH); // enable internal pullup resistors
	digitalWrite(BTN_M, HIGH);
	digits[0] = ';'; // startup logo (⸢HS⸥)
	digits[1] = 'H';
	digits[2] = '5';
	digits[3] = '?';
	setcp(0);
	Serial.begin(9600);
	recv_state();
	digits[1] = '.'; // always empty
}

void loop() {
	if (bouncer_m.update() && bouncer_m.read() == HIGH && ucounter > 0) {
		ucounter--;
		setcp(0);
	}
	if (bouncer_p.update() && bouncer_p.read() == HIGH && ucounter < 99) {
		ucounter++;
		setcp(0);
	}
	digits[0] = clockseq[clockpos];
	digits[2] = floor(ucounter / 10) + '0';
	if (digits[2] == '0') digits[2] = '.'; // do not display 0x
	digits[3] = ucounter % 10 + '0';
	stepleds();
	if (scounter != ucounter && millis() - cpcount > CPLIMIT) {
		if (clockpos == strlen(clockseq) - 1) { // timeout -> submit
			setcp(0);
			scounter = ucounter;
			Serial.print(scounter, BYTE);
			recv_state();
		} else { // spin the clock
			setcp(clockpos + 1);
		}
	}
}

void recv_state() {
	while (!Serial.available()) {
		Serial.print(READ, BYTE);
		unsigned long start = millis();
		while (millis() - start < 500) stepleds();
	}
	ucounter = scounter = Serial.read();
	while (Serial.available()) {
		Serial.read(); // clear the buffer
	}
}

void stepleds() {
	unsigned long now = micros();
	if (now - lastep > 4000) {
		lastep = now;
	} else {
		return; // every digit is lit for 4 ms
	}
	for (int i = 0; i < NDIGITS; i++) { // select digit
		digitalWrite(i + 2, digit == i ? HIGH : LOW);
	}
	for (int i = 0; i < NMAP; i++) { // look up the character
		if (digitmap[i][0] == digits[digit]) { // if found...
			for (int j = 0; j < 7; j++) { // ...set it segment by segment
				digitalWrite(j + 6, digitmap[i][j + 1] == '1' ? LOW : HIGH);
			}
		}
	}
	if (++digit == NDIGITS) digit = 0; // next digit
}

void setcp(char val) {
	cpcount = millis();
	clockpos = val;
}
