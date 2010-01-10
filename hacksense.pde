// pinout
#define REDBTN 4
#define GREENBTN 5
#define REDLED 2
#define GREENLED 3

// states
#define RED 0
#define GREEN 1
#define UNKNOWN -1
#define MASK 1

// serial comm
#define WRITE 0x42
#define READ 0x40

char state = UNKNOWN;

void setup() {
	pinMode(REDBTN,   INPUT);
	pinMode(GREENBTN, INPUT);
	digitalWrite(REDBTN,   HIGH); // enable internal pullup resistors
	digitalWrite(GREENBTN, HIGH);
	pinMode(REDLED,   OUTPUT);
	pinMode(GREENLED, OUTPUT);
	digitalWrite(GREENLED, HIGH); // boot state: both LEDs lit
	digitalWrite(REDLED,   HIGH);
	Serial.begin(9600);
	recv_state();
	update_state();
}

void loop() {
	char ns = get_state();
	if (ns != UNKNOWN && ns != state) {
		state = UNKNOWN;
		update_state();
		Serial.print(WRITE | ns, BYTE);
		recv_state();
		update_state();
	}
}

void recv_state() {
	while (!Serial.available()) {
		Serial.print(READ, BYTE);
		delay(100);
	}
	state = Serial.read() & MASK;
	while (Serial.available()) {
		Serial.read(); // clear the buffer
	}
}

char get_state() {
	if (digitalRead(GREENBTN) == LOW) {
		return GREEN;
	} else if (digitalRead(REDBTN) == LOW) {
		return RED;
	} else {
		return UNKNOWN;
	}
}

void update_state() {
	digitalWrite(GREENLED, state == GREEN ? HIGH : LOW);
	digitalWrite(REDLED,   state == RED   ? HIGH : LOW);
}
