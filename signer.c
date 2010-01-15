#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "hmac/hmac_sha2.h"

#define KEYFILE "hacksense.key"

int main(int argc, char **argv) {
	char *key, output[SHA256_DIGEST_SIZE], i, *info;
	int infolen;
	long keysize;

	if (argc < 2) {
		fprintf(stderr, "Usage: %s <message>\n", argv[0]);
		return 1;
	}

	infolen = strlen(argv[1]);
	info = argv[1];

	FILE *keyfile = fopen(KEYFILE, "r");
	if (!keyfile) {
		perror(KEYFILE);
		return 1;
	}

	fseek(keyfile, 0L, SEEK_END);
	keysize = ftell(keyfile);
	key = (char *)malloc(keysize);
	if (!key) {
		perror("Key allocation");
		fclose(keyfile);
		return 1;
	}

	fseek(keyfile, 0L, SEEK_SET);
	fread(key, keysize, 1, keyfile);
	fclose(keyfile);

	hmac_sha256(key, keysize, info, infolen, output, sizeof(output));
	printf("%s!", info);
	for (i = 0; i < sizeof(output); i++) {
		printf("%02hhx", output[i]);
	}
	putchar('\n');

	return 0;
}
