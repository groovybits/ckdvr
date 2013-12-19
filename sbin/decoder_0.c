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

void setup_decoder(void);

#define VIDEO_FIFO "/opt/dvr/lock/dec_fifo.0"
//#define VIDEO_DEV "/dev/video1"
#define VIDEO_DEV "/dev/em8300_mv-0"

#define MAX_INPUT_LINE 65535
#define SHOW_LINE_COUNT 0
#define VERBOSE 1

#define ASPECT	2 
#define BMODE 	0
#define BRATE	8000000
#define BPEAK	16000000
#define STREAM	14
#define FRATE	0
#define FPGOP	15
#define BFRAMES	3
#define GOPCL	1
#define AUDIO	0xe9
#define DNRMODE	0
#define DNRTYPE	0
#define DNRSPAT	0
#define DNRTEMP	0
#define PDOWN	0

int main(int argc, char *argv[])
{
  int line_count = 0;
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
  }

  /* Setup Codec */
  setup_decoder();

  /* Time the Recording */
  alarm(seconds);

  /* Setup Environment */
  umask(022);
 
  /* Allocate input line */
  line = malloc(MAX_INPUT_LINE + 1);
  if(line == NULL)
    exit(1);
 
  /* Open MPEG FIFO Input */
  if ( (fdin = open(VIDEO_FIFO, O_RDONLY) ) < 0 ) {
    fprintf(stderr, "Failed to open %s: %s\n", 
	VIDEO_FIFO, strerror(errno));
    exit(1);
  }

  /* Open Video Decoder Output */
  if ( (fdout = open(VIDEO_DEV, O_WRONLY) ) < 0 ) {
    fprintf(stderr, "Failed to open %s: %s\n", 
	VIDEO_DEV, strerror(errno));
    exit(1);
  }

  /* Read from Video Input while Writing to MPEG2 File */
  while(read(fdin, line, MAX_INPUT_LINE) > 0) {
    line_count++;

    /* Write Data to MPEG2 File */
    write(fdout, line, MAX_INPUT_LINE);

    if(SHOW_LINE_COUNT)
      printf("%d\n", line_count);
  }

  /* Close Files */
  close(fdin);
  close(fdout);

  return 0;
}


void setup_decoder(void) {
  /*
  int fd = -1;
  struct ivtv_ioctl_codec in_codec;
  int input = 5;
  char *device = strdup("/dev/video0");
  */

  /* Open Device */
  /*
  if ( (fd = open(device, O_RDWR) ) < 0 ) {
    fprintf(stderr, "Failed to open %s: %s\n", device, strerror(errno));
    return;
  }
  free(device);

  */
  /* Setup Input Port */
  /*
  if (ioctl(fd, VIDIOC_S_INPUT, &input) < 0)
    fprintf(stderr, "ioctl: VIDIOC_S_INPUT failed\n");

  */
  /* Setup Codecs */
  /*
  if (ioctl(fd, IVTV_IOC_G_CODEC, &in_codec) < 0)
          fprintf(stderr, "ioctl: IVTV_IOC_G_CODEC failed\n");
  else {
          in_codec.aspect       = ASPECT;
          in_codec.bitrate_mode = BMODE;
          in_codec.bitrate      = BRATE;
          in_codec.bitrate_peak = BPEAK;
          in_codec.stream_type  = STREAM;
          in_codec.framerate    = FRATE;
          in_codec.framespergop = FPGOP;
          in_codec.bframes      = BFRAMES;
          in_codec.gop_closure  = GOPCL;
          in_codec.audio_bitmask= AUDIO;
          in_codec.dnr_mode     = DNRMODE;
          in_codec.dnr_type     = DNRTYPE;
          in_codec.dnr_spatial  = DNRSPAT;
          in_codec.dnr_temporal = DNRTEMP;
          in_codec.pulldown     = PDOWN;
          if (ioctl(fd, IVTV_IOC_S_CODEC, &in_codec) < 0)
                  fprintf(stderr, "ioctl: IVTV_IOC_S_CODEC failed\n");
  }
  close(fd);
  */
  return;
}
