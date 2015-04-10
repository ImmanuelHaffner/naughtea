#include <stdlib.h>
#include <stdio.h>
#include <err.h>
#include <unistd.h>
#include <sys/wait.h>

#define ICON "/usr/share/naughtea/icon.jpg"


void usage(char const *name) {
    printf("USAGE:\n    %s <TIME>\n", name);
}

unsigned parse_time(char const *str) {
    int consumed;
    char c;
    unsigned time = 0, tmp;

    if (sscanf(str, "%u%n", &tmp, &consumed) < 1)
        errx(EXIT_FAILURE, "illegal time '%s'", str);

    do {
        str += consumed;
        switch ((c = *str++)) {
            default: errx(EXIT_FAILURE, "illegal time foramt '%c'", c);
            case 'h': tmp *= 60;
            case 'm': tmp *= 60;
            case 's':;
        }
        time += tmp;
    } while (sscanf(str, "%u%n", &tmp, &consumed) >= 1);

    return time;
}

int main(int argc, char **argv) {
    if (2 != argc) {
        usage(argv[0]);
        exit(EXIT_FAILURE);
    }

    unsigned time = parse_time(argv[1]);

    pid_t pid;
    if ((pid = fork())) {
        /* Parent */
    } else {
        /* Child */
        sleep(time);
        execl("/usr/bin/notify-send", "notify-send",
                "--urgency=normal",
                "--expire-time=0",                  /* show permanent */
                "--icon="ICON,                      /* show teapot image */
                "Tea-time :)",                      /* notify requires a non-empty message */
                NULL);
    }

    exit(EXIT_SUCCESS);
}
