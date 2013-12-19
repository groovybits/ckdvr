#include <unistd.h>
#include <features.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>
#include <inttypes.h>
#include <sys/ioctl.h>
#include <sys/time.h>
#include <math.h>
//#include "/usr/src/linux/include/linux/videodev2.h"
#define VIDIOC_S_INPUT              _IOWR ('V', 39, int)

#include "/opt/dvr/include/ivtv-ext-api.h"

void setup_encoder(void);

#define VIDEO_DEV "/dev/video0"
#define MAX_INPUT_LINE 256
#define SHOW_LINE_COUNT 0
#define VERBOSE 1

int main(int argc, char *argv[])
{
  int line_count = 0, start_write = 0;
  int fdout = -1, fdin = -1;
  char *line = NULL;
  char *output_file = NULL;
  int strsize, i, j;
  int seconds = 0;

  /*******************/
  /* Check Arguments */
  /*******************/
  if(argc > 1) {
    for(i = 1; argv[i] && (i <= argc); i++) {
      if((strncmp(argv[i], "-", 1) == 0
         && (strlen(argv[i]) == 1))) {
        exit(1);
      } else if((strncmp(argv[i], "-", 1) == 0) && (argv[i][1] == '\0'))
        continue;
      else if(strncmp(argv[i], "/", 1) == 0) {
        /* File location */
        strsize = strlen(argv[i]);
        output_file = malloc(strsize + 1);
        if(output_file == NULL)
          continue;
        strncpy(output_file, argv[i], strsize + 1);
        continue;
      } else {
        /* Recording Time */
        for(j = 0; argv[i][j] != '\0'; j++) {
          if(isdigit(argv[i][j]) == 0) {
            /* Bad Argument Given */
            fprintf(stderr, "program: ERROR: bad option! %s\n", argv[i]);
            fprintf(stderr, "Usage: program [seconds] [mpegfile]\n");
            exit(1);
          }
        }
        seconds = (int) atoi(argv[i]);
        if(VERBOSE)
          printf("Recording for %d Seconds\n", seconds);
      }
    }
  } else {
    fprintf(stderr, "Usage: program [seconds] [mpegfile]\n");
    exit(1);
  }

  /* Setup Codec */
  setup_encoder();

  /* Time the Recording */
  alarm(seconds);

  /* Setup Environment */
  umask(022);
 
  /* Allocate input line */
  line = malloc(MAX_INPUT_LINE + 1);
  if(line == NULL)
    exit(1);
 
  /* Open Video Input */
  if ( (fdin = open(VIDEO_DEV, O_RDONLY) ) < 0 ) {
    fprintf(stderr, "Failed to open %s: %s\n", VIDEO_DEV, strerror(errno));
    exit(1);
  }

  /* Open Mpeg Output */
  if ( (fdout = open(output_file, O_CREAT|O_TRUNC|O_WRONLY) ) < 0 ) {
    fprintf(stderr, "Failed to open %s: %s\n", output_file, strerror(errno));
    exit(1);
  }
  chmod(output_file, 0644);

  /* Read from Video Input while Writing to MPEG2 File */
  while(read(fdin, line, MAX_INPUT_LINE) > 0) {
    line_count++;

    /* Start Late to avoid bad Encoder Startup */
    if(line_count > 10000)
      start_write = 1;

    /* Write Data to MPEG2 File */
    if(start_write == 1)
      write(fdout, line, MAX_INPUT_LINE);

    if(SHOW_LINE_COUNT)
      printf("%d\n", line_count);
  }

  /* Close Files */
  close(fdin);
  close(fdout);

  return 0;
}


void setup_encoder(void) {
  int fd = -1;
  struct ivtv_ioctl_codec in_codec;
  int input = 5;
  char *device = strdup("/dev/video0");

  /* Open Device */
  if ( (fd = open(device, O_RDWR) ) < 0 ) {
    fprintf(stderr, "Failed to open %s: %s\n", device, strerror(errno));
    return;
  }
  free(device);

  /* Setup Input Port */
  if (ioctl(fd, VIDIOC_S_INPUT, &input) < 0)
    fprintf(stderr, "ioctl: VIDIOC_S_INPUT failed\n");

  /* Setup Codecs */
  if (ioctl(fd, IVTV_IOC_G_CODEC, &in_codec) < 0)
          fprintf(stderr, "ioctl: IVTV_IOC_G_CODEC failed\n");
  else {
          in_codec.aspect       = 2;
          in_codec.bitrate_mode = 0;
          in_codec.bitrate      = 8000000;
          in_codec.bitrate_peak = 16000000;
          in_codec.stream_type  = 14;
          in_codec.framerate    = 0;
          in_codec.framespergop = 15;
          in_codec.bframes      = 3;
          in_codec.gop_closure  = 1;
          in_codec.audio_bitmask= 0xe9;
          in_codec.dnr_mode     = 0;
          in_codec.dnr_type     = 0;
          in_codec.dnr_spatial  = 0;
          in_codec.dnr_temporal = 0;
          in_codec.pulldown     = 0;
          if (ioctl(fd, IVTV_IOC_S_CODEC, &in_codec) < 0)
                  fprintf(stderr, "ioctl: IVTV_IOC_S_CODEC failed\n");
  }
  close(fd);
  return;
}
