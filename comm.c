#include <fcntl.h>
#include <termios.h>
#include <stdio.h>
#include <string.h>
#include <sys/wait.h>

#define BAUDRATE B9600
#define PORT "/dev/tts/1"
#define WRITE 2
#define SCRIPT_D "./state.sh %d"
#define SCRIPT_S "./state.sh %s"
#define SLEN 16

int main(int argc, char** argv)
{
	struct termios oldtio, newtio;
	char buf;
	int fd;
	char state = 0;
	char script[SLEN];

	fd = open(PORT, O_RDWR | O_NOCTTY);
	if (fd < 0)
	{
		perror(PORT);
		return 1;
	}

	tcgetattr(fd, &oldtio);

	bzero(&newtio, sizeof(newtio));
	newtio.c_cflag = BAUDRATE | CS8 | CLOCAL | CREAD;
	newtio.c_iflag = IGNPAR;
	newtio.c_oflag = 0;
	newtio.c_lflag = 0;
	newtio.c_cc[VTIME] = 0;
	newtio.c_cc[VMIN] = 1;

	tcflush(fd, TCIFLUSH);
	tcsetattr(fd, TCSANOW, &newtio);

	snprintf(script, SLEN, SCRIPT_S, "get");
	state = WEXITSTATUS(system(script));
	printf("Loaded state %d\n", state);

	while (1) {
		read(fd, &buf, 1);
		printf("Buffer: 0x%hhx :: ", buf);
		if ((buf & WRITE) == WRITE) {
			state = buf & 1;
			printf("State changed to %d\n", state);
			snprintf(script, SLEN, SCRIPT_D, state);
			system(script);
		} else {
			write(fd, &state, 1);
			printf("State sent (%d)\n", state);
		}
	}

	usleep(0);
	tcsetattr(fd, TCSANOW, &oldtio);
	return 0;
}
